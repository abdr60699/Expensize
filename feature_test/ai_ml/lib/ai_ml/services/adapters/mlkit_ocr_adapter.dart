import 'dart:io';
import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../models/model_info.dart';
import '../../models/ocr_result.dart';
import '../../errors/ai_ml_exceptions.dart';
import 'model_adapter.dart';

/// Google ML Kit adapter for OCR
class MlKitOcrAdapter extends OcrAdapter {
  final ModelInfo modelInfo;
  final List<String>? supportedLanguages;

  TextRecognizer? _recognizer;
  bool _isInitialized = false;

  MlKitOcrAdapter({
    required this.modelInfo,
    this.supportedLanguages,
  });

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<ModelInfo> info() async {
    return modelInfo;
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _recognizer = TextRecognizer();
      _isInitialized = true;
    } catch (e, stackTrace) {
      throw InitializationException(
        'Failed to initialize ML Kit OCR adapter',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> dispose() async {
    await _recognizer?.close();
    _recognizer = null;
    _isInitialized = false;
  }

  @override
  Future<OcrResult> recognize(File imageFile) async {
    if (!_isInitialized || _recognizer == null) {
      throw InferenceException('Adapter not initialized');
    }

    final startTime = DateTime.now();

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _recognizer!.processImage(inputImage);

      final blocks = <OcrBlock>[];

      for (final textBlock in recognizedText.blocks) {
        final boundingBox = textBlock.boundingBox;
        final cornerPoints = textBlock.cornerPoints
            .map((p) => Offset(p.x.toDouble(), p.y.toDouble()))
            .toList();

        blocks.add(OcrBlock(
          text: textBlock.text,
          confidence: _estimateConfidence(textBlock),
          boundingBox: boundingBox,
          cornerPoints: cornerPoints,
        ));
      }

      final inferenceTime = DateTime.now().difference(startTime).inMilliseconds;

      return OcrResult(
        text: recognizedText.text,
        blocks: blocks,
        inferenceTimeMs: inferenceTime,
        modelId: modelInfo.id,
      );
    } catch (e, stackTrace) {
      throw InferenceException(
        'Failed to perform OCR',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<OcrResult> recognizeFromBytes(List<int> imageBytes) async {
    // ML Kit requires a file or image metadata
    // For now, we'll throw an exception suggesting to use recognize() with a file
    throw UnsupportedOperationException(
      'ML Kit OCR requires a file. Use recognize() method instead.',
    );
  }

  /// Estimates confidence score for a text block
  /// ML Kit doesn't provide confidence scores directly, so we estimate based on text quality
  double _estimateConfidence(TextBlock block) {
    // Simple heuristic: longer blocks with more recognized characters = higher confidence
    // This is a placeholder - in production, you might use other heuristics
    if (block.text.isEmpty) return 0.0;

    // Check for common OCR issues
    final hasSpecialChars = RegExp(r'[^\w\s.,!?-]').hasMatch(block.text);
    final avgWordLength = block.text.split(' ').fold(0, (sum, word) => sum + word.length) /
        block.text.split(' ').length;

    double confidence = 0.8; // Base confidence

    if (hasSpecialChars) confidence -= 0.1;
    if (avgWordLength < 2) confidence -= 0.2;
    if (block.text.length < 3) confidence -= 0.1;

    return confidence.clamp(0.0, 1.0);
  }
}
