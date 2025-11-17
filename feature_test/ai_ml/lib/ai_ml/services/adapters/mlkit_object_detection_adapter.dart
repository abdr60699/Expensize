import 'dart:io';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart' as mlkit;
import '../../models/model_info.dart';
import '../../models/detected_object.dart' as models;
import '../../errors/ai_ml_exceptions.dart';
import 'model_adapter.dart';

/// Google ML Kit adapter for object detection
class MlKitObjectDetectionAdapter extends ObjectDetectionAdapter {
  final ModelInfo modelInfo;
  final mlkit.ObjectDetectorOptions options;

  mlkit.ObjectDetector? _detector;
  bool _isInitialized = false;

  MlKitObjectDetectionAdapter({
    required this.modelInfo,
    mlkit.ObjectDetectorOptions? options,
  }) : options = options ??
            mlkit.ObjectDetectorOptions(
              mode: mlkit.DetectionMode.single,
              classifyObjects: true,
              multipleObjects: true,
            );

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
      _detector = mlkit.ObjectDetector(options: options);
      _isInitialized = true;
    } catch (e, stackTrace) {
      throw InitializationException(
        'Failed to initialize ML Kit object detection adapter',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> dispose() async {
    await _detector?.close();
    _detector = null;
    _isInitialized = false;
  }

  @override
  Future<List<models.DetectedObject>> detect(
    File imageFile, {
    double threshold = 0.5,
  }) async {
    if (!_isInitialized || _detector == null) {
      throw InferenceException('Adapter not initialized');
    }

    try {
      final inputImage = mlkit.InputImage.fromFile(imageFile);
      final detectedObjects = await _detector!.processImage(inputImage);

      final results = <models.DetectedObject>[];

      for (final obj in detectedObjects) {
        // Get the best label
        if (obj.labels.isNotEmpty) {
          final topLabel = obj.labels.reduce(
            (a, b) => a.confidence > b.confidence ? a : b,
          );

          if (topLabel.confidence >= threshold) {
            results.add(models.DetectedObject(
              label: topLabel.text,
              score: topLabel.confidence,
              boundingBox: obj.boundingBox,
              trackingId: obj.trackingId,
            ));
          }
        }
      }

      return results;
    } catch (e, stackTrace) {
      throw InferenceException(
        'Failed to detect objects',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<models.DetectedObject>> detectFromBytes(
    List<int> imageBytes, {
    double threshold = 0.5,
  }) async {
    throw UnsupportedOperationException(
      'ML Kit object detection requires a file. Use detect() method instead.',
    );
  }
}
