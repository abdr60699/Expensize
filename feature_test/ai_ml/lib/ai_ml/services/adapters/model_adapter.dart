import 'dart:io';
import '../../models/model_info.dart';
import '../../models/image_classification_result.dart';
import '../../models/detected_object.dart';
import '../../models/ocr_result.dart';
import '../../models/text_embedding.dart';
import '../../models/text_classification_result.dart';

/// Base interface for ML model adapters
abstract class ModelAdapter {
  /// Gets information about this adapter's model
  Future<ModelInfo> info();

  /// Initializes the adapter
  Future<void> initialize();

  /// Disposes resources
  Future<void> dispose();

  /// Checks if the adapter is initialized
  bool get isInitialized;

  /// Runs inference (generic method)
  Future<T> runInference<T>(Map<String, dynamic> input);
}

/// Adapter for image classification models
abstract class ImageClassificationAdapter extends ModelAdapter {
  /// Classifies an image file
  Future<ImageClassificationResult> classify(
    File imageFile, {
    double threshold = 0.0,
  });

  /// Classifies image from bytes
  Future<ImageClassificationResult> classifyFromBytes(
    List<int> imageBytes, {
    double threshold = 0.0,
  });

  @override
  Future<T> runInference<T>(Map<String, dynamic> input) async {
    final file = input['file'] as File?;
    final bytes = input['bytes'] as List<int>?;
    final threshold = input['threshold'] as double? ?? 0.0;

    if (file != null) {
      return await classify(file, threshold: threshold) as T;
    } else if (bytes != null) {
      return await classifyFromBytes(bytes, threshold: threshold) as T;
    } else {
      throw ArgumentError('Either file or bytes must be provided');
    }
  }
}

/// Adapter for object detection models
abstract class ObjectDetectionAdapter extends ModelAdapter {
  /// Detects objects in an image file
  Future<List<DetectedObject>> detect(
    File imageFile, {
    double threshold = 0.5,
  });

  /// Detects objects in image from bytes
  Future<List<DetectedObject>> detectFromBytes(
    List<int> imageBytes, {
    double threshold = 0.5,
  });

  @override
  Future<T> runInference<T>(Map<String, dynamic> input) async {
    final file = input['file'] as File?;
    final bytes = input['bytes'] as List<int>?;
    final threshold = input['threshold'] as double? ?? 0.5;

    if (file != null) {
      return await detect(file, threshold: threshold) as T;
    } else if (bytes != null) {
      return await detectFromBytes(bytes, threshold: threshold) as T;
    } else {
      throw ArgumentError('Either file or bytes must be provided');
    }
  }
}

/// Adapter for OCR models
abstract class OcrAdapter extends ModelAdapter {
  /// Performs OCR on an image file
  Future<OcrResult> recognize(File imageFile);

  /// Performs OCR on image from bytes
  Future<OcrResult> recognizeFromBytes(List<int> imageBytes);

  @override
  Future<T> runInference<T>(Map<String, dynamic> input) async {
    final file = input['file'] as File?;
    final bytes = input['bytes'] as List<int>?;

    if (file != null) {
      return await recognize(file) as T;
    } else if (bytes != null) {
      return await recognizeFromBytes(bytes) as T;
    } else {
      throw ArgumentError('Either file or bytes must be provided');
    }
  }
}

/// Adapter for text embedding models
abstract class TextEmbeddingAdapter extends ModelAdapter {
  /// Generates embedding for text
  Future<TextEmbedding> embed(String text);

  /// Generates embeddings for multiple texts (batch)
  Future<List<TextEmbedding>> embedBatch(List<String> texts);

  @override
  Future<T> runInference<T>(Map<String, dynamic> input) async {
    final text = input['text'] as String?;
    final texts = input['texts'] as List<String>?;

    if (text != null) {
      return await embed(text) as T;
    } else if (texts != null) {
      return await embedBatch(texts) as T;
    } else {
      throw ArgumentError('Either text or texts must be provided');
    }
  }
}

/// Adapter for text classification models
abstract class TextClassificationAdapter extends ModelAdapter {
  /// Classifies text
  Future<TextClassificationResult> classify(
    String text, {
    double threshold = 0.0,
  });

  /// Classifies multiple texts (batch)
  Future<List<TextClassificationResult>> classifyBatch(
    List<String> texts, {
    double threshold = 0.0,
  });

  @override
  Future<T> runInference<T>(Map<String, dynamic> input) async {
    final text = input['text'] as String?;
    final texts = input['texts'] as List<String>?;
    final threshold = input['threshold'] as double? ?? 0.0;

    if (text != null) {
      return await classify(text, threshold: threshold) as T;
    } else if (texts != null) {
      return await classifyBatch(texts, threshold: threshold) as T;
    } else {
      throw ArgumentError('Either text or texts must be provided');
    }
  }
}
