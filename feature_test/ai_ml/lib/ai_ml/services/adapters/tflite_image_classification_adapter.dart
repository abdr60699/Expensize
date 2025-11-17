import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../../models/model_info.dart';
import '../../models/image_classification_result.dart';
import '../../models/label_score.dart';
import '../../errors/ai_ml_exceptions.dart';
import 'model_adapter.dart';

/// TensorFlow Lite adapter for image classification
class TfliteImageClassificationAdapter extends ImageClassificationAdapter {
  final ModelInfo modelInfo;
  final List<String> labels;
  final int inputSize;
  final bool useGpuDelegate;

  Interpreter? _interpreter;
  bool _isInitialized = false;

  TfliteImageClassificationAdapter({
    required this.modelInfo,
    required this.labels,
    this.inputSize = 224,
    this.useGpuDelegate = false,
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

      // Enable GPU delegate if requested (Android/iOS)
      if (useGpuDelegate) {
        if (Platform.isAndroid) {
          options.addDelegate(GpuDelegateV2());
        } else if (Platform.isIOS) {
          options.addDelegate(GpuDelegate());
        }
      }

      // Use XNNPACK delegate for CPU optimization
      options.addDelegate(XNNPackDelegate());

      _interpreter = await Interpreter.fromAsset(
        modelInfo.id,
        options: options,
      );

      _isInitialized = true;
    } catch (e, stackTrace) {
      throw InitializationException(
        'Failed to initialize TFLite image classification adapter',
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
  Future<ImageClassificationResult> classify(
    File imageFile, {
    double threshold = 0.0,
  }) async {
    final imageBytes = await imageFile.readAsBytes();
    return classifyFromBytes(imageBytes, threshold: threshold);
  }

  @override
  Future<ImageClassificationResult> classifyFromBytes(
    List<int> imageBytes, {
    double threshold = 0.0,
  }) async {
    if (!_isInitialized || _interpreter == null) {
      throw InferenceException('Adapter not initialized');
    }

    final startTime = DateTime.now();

    try {
      // Decode and preprocess image
      final inputData = _preprocessImage(imageBytes);

      // Prepare output buffer
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final outputType = _interpreter!.getOutputTensor(0).type;

      final output = List.filled(outputShape[1], 0.0).reshape([1, outputShape[1]]);

      // Run inference
      _interpreter!.run(inputData, output);

      // Process results
      final predictions = output[0] as List<double>;
      final labelScores = <LabelScore>[];

      for (int i = 0; i < predictions.length && i < labels.length; i++) {
        if (predictions[i] >= threshold) {
          labelScores.add(LabelScore(
            label: labels[i],
            score: predictions[i],
            index: i,
          ));
        }
      }

      // Sort by score descending
      labelScores.sort((a, b) => b.score.compareTo(a.score));

      final inferenceTime = DateTime.now().difference(startTime).inMilliseconds;

      return ImageClassificationResult(
        labels: labelScores,
        inferenceTimeMs: inferenceTime,
        modelId: modelInfo.id,
      );
    } catch (e, stackTrace) {
      throw InferenceException(
        'Failed to run image classification inference',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Preprocesses image to model input format
  Uint8List _preprocessImage(List<int> imageBytes) {
    // Decode image
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw InferenceException('Failed to decode image');
    }

    // Resize to input size
    final resized = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    // Convert to Float32List normalized to [0, 1] or [-1, 1]
    final inputShape = _interpreter!.getInputTensor(0).shape;
    final inputType = _interpreter!.getInputTensor(0).type;

    // Check if it's a float model (most common for image classification)
    if (inputType.toString().contains('float') || inputType == TfLiteType.float32) {
      final buffer = Float32List(inputShape[1] * inputShape[2] * inputShape[3]);
      int pixelIndex = 0;

      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          final pixel = resized.getPixel(x, y);

          // Normalize to [0, 1]
          buffer[pixelIndex++] = pixel.r / 255.0;
          buffer[pixelIndex++] = pixel.g / 255.0;
          buffer[pixelIndex++] = pixel.b / 255.0;
        }
      }

      return buffer.buffer.asUint8List();
    } else {
      // Quantized model
      final buffer = Uint8List(inputShape[1] * inputShape[2] * inputShape[3]);
      int pixelIndex = 0;

      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          final pixel = resized.getPixel(x, y);
          buffer[pixelIndex++] = pixel.r.toInt();
          buffer[pixelIndex++] = pixel.g.toInt();
          buffer[pixelIndex++] = pixel.b.toInt();
        }
      }

      return buffer;
    } else {
      throw InferenceException('Unsupported input type: $inputType');
    }
  }
}
