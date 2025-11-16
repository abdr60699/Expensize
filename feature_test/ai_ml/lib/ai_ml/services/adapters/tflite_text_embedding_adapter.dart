import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../models/model_info.dart';
import '../../models/text_embedding.dart';
import '../../errors/ai_ml_exceptions.dart';
import 'model_adapter.dart';

/// TensorFlow Lite adapter for text embeddings
class TfliteTextEmbeddingAdapter extends TextEmbeddingAdapter {
  final ModelInfo modelInfo;
  final int maxSequenceLength;
  final Map<String, int>? vocabulary;

  Interpreter? _interpreter;
  bool _isInitialized = false;

  TfliteTextEmbeddingAdapter({
    required this.modelInfo,
    this.maxSequenceLength = 128,
    this.vocabulary,
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
      final options = InterpreterOptions();
      options.addDelegate(XNNPackDelegate());

      _interpreter = await Interpreter.fromAsset(
        modelInfo.id,
        options: options,
      );

      _isInitialized = true;
    } catch (e, stackTrace) {
      throw InitializationException(
        'Failed to initialize TFLite text embedding adapter',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }

  @override
  Future<TextEmbedding> embed(String text) async {
    if (!_isInitialized || _interpreter == null) {
      throw InferenceException('Adapter not initialized');
    }

    final startTime = DateTime.now();

    try {
      // Tokenize text
      final tokens = _tokenize(text);

      // Prepare input
      final input = Int32List(maxSequenceLength);
      for (int i = 0; i < tokens.length && i < maxSequenceLength; i++) {
        input[i] = tokens[i];
      }

      // Prepare output
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final embeddingSize = outputShape[1];
      final output = List.filled(embeddingSize, 0.0).reshape([1, embeddingSize]);

      // Run inference
      _interpreter!.run(input.reshape([1, maxSequenceLength]), output);

      final embedding = (output[0] as List).cast<double>();
      final inferenceTime = DateTime.now().difference(startTime).inMilliseconds;

      return TextEmbedding(
        vector: embedding,
        originalText: text,
        modelId: modelInfo.id,
        inferenceTimeMs: inferenceTime,
      );
    } catch (e, stackTrace) {
      throw InferenceException(
        'Failed to generate text embedding',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<TextEmbedding>> embedBatch(List<String> texts) async {
    // Simple implementation: process one by one
    // Can be optimized with batch processing
    final embeddings = <TextEmbedding>[];
    for (final text in texts) {
      embeddings.add(await embed(text));
    }
    return embeddings;
  }

  /// Tokenizes text to integer indices
  List<int> _tokenize(String text) {
    if (vocabulary == null) {
      // Simple character-level tokenization as fallback
      return text.codeUnits.take(maxSequenceLength).toList();
    }

    // Word-level tokenization using vocabulary
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    final tokens = <int>[];

    for (final word in words) {
      final token = vocabulary![word] ?? 0; // 0 for unknown
      tokens.add(token);
      if (tokens.length >= maxSequenceLength) break;
    }

    return tokens;
  }
}
