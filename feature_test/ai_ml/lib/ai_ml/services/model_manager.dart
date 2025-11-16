import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/model_info.dart';
import '../errors/ai_ml_exceptions.dart';
import '../utils/logger.dart';

/// Manages model downloads and storage
class ModelManager {
  final AiLogger logger;
  final Map<String, ModelInfo> _manifest = {};

  static const String _manifestPath = 'lib/features/ai_ml/assets/models/manifest.json';

  ModelManager({
    required this.logger,
  });

  /// Initializes the model manager and loads manifest
  Future<void> initialize() async {
    try {
      // Try to load manifest from assets
      final manifestJson = await rootBundle.loadString(_manifestPath);
      final manifestData = jsonDecode(manifestJson) as Map<String, dynamic>;

      final models = manifestData['models'] as List;
      for (final model in models) {
        final modelInfo = ModelInfo.fromJson(model as Map<String, dynamic>);
        _manifest[modelInfo.id] = modelInfo;
      }

      logger.info('Loaded ${_manifest.length} models from manifest');
    } catch (e) {
      logger.warning('Failed to load model manifest: $e');
      // Continue without manifest
    }
  }

  /// Gets model information
  Future<ModelInfo> getModelInfo(String modelId) async {
    final info = _manifest[modelId];
    if (info == null) {
      throw ModelNotFoundException(modelId);
    }
    return info;
  }

  /// Downloads a model
  Future<void> downloadModel(String modelId) async {
    final modelInfo = await getModelInfo(modelId);

    if (modelInfo.downloadUrl == null) {
      throw ModelDownloadException('No download URL for model: $modelId');
    }

    try {
      logger.info('Downloading model: $modelId from ${modelInfo.downloadUrl}');

      final response = await http.get(Uri.parse(modelInfo.downloadUrl!));

      if (response.statusCode != 200) {
        throw ModelDownloadException(
          'Failed to download model. HTTP ${response.statusCode}',
        );
      }

      final modelBytes = response.bodyBytes;

      // Verify checksum if provided
      if (modelInfo.checksum != null) {
        final actualChecksum = sha256.convert(modelBytes).toString();
        if (actualChecksum != modelInfo.checksum) {
          throw ModelDownloadException(
            'Checksum mismatch. Expected: ${modelInfo.checksum}, Got: $actualChecksum',
          );
        }
        logger.info('Checksum verified for model: $modelId');
      }

      // Save to cache directory
      final cacheDir = await getApplicationCacheDirectory();
      final modelsDir = Directory('${cacheDir.path}/models');
      if (!await modelsDir.exists()) {
        await modelsDir.create(recursive: true);
      }

      final modelFile = File('${modelsDir.path}/$modelId.tflite');
      await modelFile.writeAsBytes(modelBytes);

      logger.info('Model saved: ${modelFile.path}');
    } catch (e, stackTrace) {
      if (e is ModelDownloadException) rethrow;
      throw ModelDownloadException(
        'Failed to download model: $modelId',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Checks if model is downloaded
  Future<bool> isModelDownloaded(String modelId) async {
    try {
      final cacheDir = await getApplicationCacheDirectory();
      final modelFile = File('${cacheDir.path}/models/$modelId.tflite');
      return await modelFile.exists();
    } catch (e) {
      return false;
    }
  }

  /// Gets local model path
  Future<String?> getModelPath(String modelId) async {
    final cacheDir = await getApplicationCacheDirectory();
    final modelFile = File('${cacheDir.path}/models/$modelId.tflite');

    if (await modelFile.exists()) {
      return modelFile.path;
    }

    return null;
  }

  /// Deletes a downloaded model
  Future<void> deleteModel(String modelId) async {
    final cacheDir = await getApplicationCacheDirectory();
    final modelFile = File('${cacheDir.path}/models/$modelId.tflite');

    if (await modelFile.exists()) {
      await modelFile.delete();
      logger.info('Deleted model: $modelId');
    }
  }

  /// Lists all downloaded models
  Future<List<String>> listDownloadedModels() async {
    try {
      final cacheDir = await getApplicationCacheDirectory();
      final modelsDir = Directory('${cacheDir.path}/models');

      if (!await modelsDir.exists()) {
        return [];
      }

      final files = await modelsDir.list().toList();
      return files
          .whereType<File>()
          .map((f) => f.path.split('/').last.replaceAll('.tflite', ''))
          .toList();
    } catch (e) {
      logger.error('Failed to list models', e);
      return [];
    }
  }
}
