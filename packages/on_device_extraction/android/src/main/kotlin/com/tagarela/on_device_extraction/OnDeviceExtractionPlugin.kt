package com.tagarela.on_device_extraction

import ai.moonshine.voice.Transcriber
import android.content.Context
import android.media.AudioFormat
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.net.Uri
import android.os.Handler
import android.os.Looper
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.TextRecognizer
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class OnDeviceExtractionPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val worker: ExecutorService = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var recognizer: TextRecognizer? = null
    private var transcriber: Transcriber? = null
    private var transcriberKey: String? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "on_device_extraction")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        worker.execute { release() }
        worker.shutdown()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "recognizeText" -> run(result) { recognizeText(call.argument<String>("path")!!) }
            "transcribe" -> run(result) {
                transcribe(
                    call.argument<String>("path")!!,
                    call.argument<String>("modelPath")!!,
                    call.argument<Int>("arch")!!,
                )
            }
            "release" -> run(result) {
                release()
                null
            }
            else -> result.notImplemented()
        }
    }

    private fun run(result: MethodChannel.Result, work: () -> Any?) {
        worker.execute {
            try {
                val value = work()
                main.post { result.success(value) }
            } catch (e: Throwable) {
                main.post { result.error("extraction_failed", e.message, null) }
            }
        }
    }

    private fun recognizeText(path: String): String {
        val image = InputImage.fromFilePath(context, Uri.fromFile(File(path)))
        val client = recognizer
            ?: TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS).also { recognizer = it }
        return Tasks.await(client.process(image)).text
    }

    private fun transcribe(path: String, modelPath: String, arch: Int): String {
        val (samples, sampleRate) = decode(path)
        val transcript = transcriberFor(modelPath, arch).transcribeWithoutStreaming(samples, sampleRate)
        return transcript.lines.orEmpty().mapNotNull { it.text }.joinToString(" ")
    }

    private fun transcriberFor(modelPath: String, arch: Int): Transcriber {
        val key = "$modelPath#$arch"
        transcriber?.let { if (transcriberKey == key) return it }
        closeTranscriber()
        return Transcriber().also {
            it.loadFromFiles(modelPath, arch)
            transcriber = it
            transcriberKey = key
        }
    }

    private fun release() {
        recognizer?.close()
        recognizer = null
        closeTranscriber()
    }

    private fun closeTranscriber() {
        transcriber?.close()
        transcriber = null
        transcriberKey = null
    }

    private fun decode(path: String): Pair<FloatArray, Int> {
        val extractor = MediaExtractor()
        try {
            extractor.setDataSource(path)
            val track = (0 until extractor.trackCount).first {
                extractor.getTrackFormat(it).getString(MediaFormat.KEY_MIME)?.startsWith("audio/") == true
            }
            extractor.selectTrack(track)
            val format = extractor.getTrackFormat(track)
            val codec = MediaCodec.createDecoderByType(format.getString(MediaFormat.KEY_MIME)!!)
            try {
                codec.configure(format, null, null, 0)
                codec.start()
                return drain(extractor, codec, format)
            } finally {
                codec.release()
            }
        } finally {
            extractor.release()
        }
    }

    private fun drain(extractor: MediaExtractor, codec: MediaCodec, input: MediaFormat): Pair<FloatArray, Int> {
        var sampleRate = input.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        var channels = input.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
        var encoding = AudioFormat.ENCODING_PCM_16BIT
        val pcm = ByteArrayOutputStream()
        val info = MediaCodec.BufferInfo()
        var inputDone = false
        var idle = 0
        while (true) {
            if (!inputDone) {
                val index = codec.dequeueInputBuffer(TIMEOUT_US)
                if (index >= 0) {
                    val size = extractor.readSampleData(codec.getInputBuffer(index)!!, 0)
                    if (size < 0) {
                        codec.queueInputBuffer(index, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                        inputDone = true
                    } else {
                        codec.queueInputBuffer(index, 0, size, extractor.sampleTime, 0)
                        extractor.advance()
                    }
                }
            }
            val index = codec.dequeueOutputBuffer(info, TIMEOUT_US)
            if (index == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                val output = codec.outputFormat
                sampleRate = output.getInteger(MediaFormat.KEY_SAMPLE_RATE)
                channels = output.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
                if (output.containsKey(MediaFormat.KEY_PCM_ENCODING)) {
                    encoding = output.getInteger(MediaFormat.KEY_PCM_ENCODING)
                }
            } else if (index >= 0) {
                idle = 0
                val chunk = ByteArray(info.size)
                codec.getOutputBuffer(index)!!.get(chunk)
                pcm.write(chunk)
                codec.releaseOutputBuffer(index, false)
                if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) break
            } else if (inputDone && ++idle > MAX_IDLE_POLLS) {
                break
            }
        }
        return toMono(pcm.toByteArray(), channels, encoding) to sampleRate
    }

    private fun toMono(bytes: ByteArray, channels: Int, encoding: Int): FloatArray {
        val buffer = ByteBuffer.wrap(bytes).order(ByteOrder.nativeOrder())
        val isFloat = encoding == AudioFormat.ENCODING_PCM_FLOAT
        val frames = bytes.size / ((if (isFloat) 4 else 2) * channels)
        return FloatArray(frames) {
            var sum = 0f
            repeat(channels) { sum += if (isFloat) buffer.float else buffer.short / 32768f }
            sum / channels
        }
    }

    private companion object {
        const val TIMEOUT_US = 10_000L
        const val MAX_IDLE_POLLS = 100
    }
}
