import 'package:on_device_extraction/on_device_extraction.dart';

class ModelFile {
  const ModelFile(this.name, this.size, this.sha256);

  final String name;
  final int size;
  final String sha256;
}

class SpeechModel {
  const SpeechModel({
    required this.id,
    required this.arch,
    required this.baseUrl,
    required this.files,
  });

  static const tinyStreaming = SpeechModel(
    id: 'tiny-streaming-en',
    arch: MoonshineArch.tinyStreaming,
    baseUrl:
        'https://huggingface.co/moonshine-ai/moonshine-voice-assets/resolve/'
        '0bf2f2e5aff22e6fbba4300b00a4e00bbc4f8aae/model/tiny-streaming-en/quantized_26_08_21',
    files: [
      ModelFile(
        'adapter.ort',
        1319664,
        '22ecc949e146c49667fda28d102d4e30749a107dc88a396292aa8f277ef1347c',
      ),
      ModelFile(
        'cross_kv.ort',
        1287544,
        '143a36667b8d05fd9d04e8c337b7ee121f37ef299aea6b3d82bdb3d3401950b4',
      ),
      ModelFile(
        'decoder_kv.ort',
        32583720,
        '8852553f312adb6c9aa4d17418015049b30f412209ee569d336548c0044627de',
      ),
      ModelFile(
        'encoder.ort',
        7675440,
        'a8414e1a5dedf9f2093d7680601dd8a9b0433e7020260eafe0e370ead91134ca',
      ),
      ModelFile(
        'frontend.model.ort',
        23344,
        '5121b561417b638afce0c6c31b760e37c93cf97f80d9b0031aad1fe7b6f25d61',
      ),
      ModelFile(
        'frontend.weights.ort',
        2093464,
        '217da24ac6f522ebf02da8ef288e77d1ac68d50d4a6821433182e4fbf4204bbd',
      ),
      ModelFile(
        'streaming_config.json',
        509,
        '74fe5ddebd63b17caf59e8a3b18c17547ff7bce1642050edbb1c3962674f8950',
      ),
      ModelFile(
        'tokenizer.bin',
        249974,
        '6884b35fd6377d4c4d32336a0bc152f36b64d1e45b6503683cdc238250a8472d',
      ),
    ],
  );

  static const current = tinyStreaming;

  final String id;
  final MoonshineArch arch;
  final String baseUrl;
  final List<ModelFile> files;

  int get size => files.fold(0, (sum, file) => sum + file.size);

  String get sizeLabel => '${(size / 1000000).round()} MB';

  Uri url(ModelFile file) => Uri.parse('$baseUrl/${file.name}');
}
