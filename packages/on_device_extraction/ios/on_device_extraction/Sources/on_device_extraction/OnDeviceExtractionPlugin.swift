import AVFoundation
import Flutter
import ImageIO
import MoonshineVoice
import Vision

public final class OnDeviceExtractionPlugin: NSObject, FlutterPlugin {
    private let queue = DispatchQueue(label: "on_device_extraction", qos: .userInitiated)
    private var transcriber: Transcriber?
    private var transcriberKey: String?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "on_device_extraction", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(OnDeviceExtractionPlugin(), channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [:]
        switch call.method {
        case "recognizeText":
            run(result) { try self.recognizeText(at: arguments["path"] as? String ?? "") }
        case "transcribe":
            run(result) {
                try self.transcribe(
                    at: arguments["path"] as? String ?? "",
                    modelPath: arguments["modelPath"] as? String ?? "",
                    arch: arguments["arch"] as? Int ?? -1)
            }
        case "release":
            run(result) {
                self.transcriber = nil
                self.transcriberKey = nil
                return nil
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func run(_ result: @escaping FlutterResult, _ work: @escaping () throws -> Any?) {
        queue.async {
            let value: Any?
            do {
                value = try work()
            } catch {
                value = FlutterError(
                    code: "extraction_failed", message: String(describing: error), details: nil)
            }
            DispatchQueue.main.async { result(value) }
        }
    }

    private func recognizeText(at path: String) throws -> String {
        guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil),
            let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else {
            throw ExtractionError.unreadable
        }
        let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        let orientation =
            (properties?[kCGImagePropertyOrientation] as? UInt32)
            .flatMap(CGImagePropertyOrientation.init(rawValue:)) ?? .up
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = true
        try VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:])
            .perform([request])
        return (request.results ?? [])
            .compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: "\n")
    }

    private func transcribe(at path: String, modelPath: String, arch: Int) throws -> String {
        let (samples, sampleRate) = try decode(URL(fileURLWithPath: path))
        let transcript = try loadedTranscriber(modelPath: modelPath, arch: arch)
            .transcribeWithoutStreaming(audioData: samples, sampleRate: sampleRate)
        return transcript.lines.map(\.text).joined(separator: " ")
    }

    private func loadedTranscriber(modelPath: String, arch: Int) throws -> Transcriber {
        let key = "\(modelPath)#\(arch)"
        if let transcriber, transcriberKey == key {
            return transcriber
        }
        transcriber = nil
        transcriberKey = nil
        guard arch >= 0, let modelArch = ModelArch(rawValue: UInt32(arch)) else {
            throw ExtractionError.unknownArch
        }
        let loaded = try Transcriber(modelPath: modelPath, modelArch: modelArch)
        transcriber = loaded
        transcriberKey = key
        return loaded
    }

    private func decode(_ url: URL) throws -> ([Float], Int32) {
        let file = try AVAudioFile(forReading: url)
        let format = file.processingFormat
        guard
            let buffer = AVAudioPCMBuffer(
                pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))
        else {
            throw ExtractionError.unreadable
        }
        try file.read(into: buffer)
        guard let channels = buffer.floatChannelData else {
            throw ExtractionError.unreadable
        }
        let frames = Int(buffer.frameLength)
        let count = Int(format.channelCount)
        var samples = [Float](repeating: 0, count: frames)
        for channel in 0..<count {
            let data = channels[channel]
            for frame in 0..<frames {
                samples[frame] += data[frame] / Float(count)
            }
        }
        return (samples, Int32(format.sampleRate))
    }
}

private enum ExtractionError: Error {
    case unreadable
    case unknownArch
}
