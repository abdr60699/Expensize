/// Information about an ML model
class ModelInfo {
  /// Unique model identifier
  final String id;

  /// Human-readable model name
  final String name;

  /// Model size in bytes
  final int sizeBytes;

  /// Framework (e.g., 'tflite', 'mlkit', 'onnx')
  final String framework;

  /// Whether the model is quantized
  final bool quantized;

  /// Quantization type (e.g., 'int8', 'float16')
  final String? quantizationType;

  /// Model version
  final String? version;

  /// Download URL
  final String? downloadUrl;

  /// SHA256 checksum for verification
  final String? checksum;

  /// License information
  final String? license;

  /// Input shape (e.g., [1, 224, 224, 3] for images)
  final List<int>? inputShape;

  /// Output shape
  final List<int>? outputShape;

  /// Expected performance metadata
  final ModelPerformance? performance;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const ModelInfo({
    required this.id,
    required this.name,
    required this.sizeBytes,
    required this.framework,
    required this.quantized,
    this.quantizationType,
    this.version,
    this.downloadUrl,
    this.checksum,
    this.license,
    this.inputShape,
    this.outputShape,
    this.performance,
    this.metadata,
  });

  /// Gets human-readable size
  String get sizeFormatted {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(2)} KB';
    if (sizeBytes < 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sizeBytes': sizeBytes,
      'framework': framework,
      'quantized': quantized,
      if (quantizationType != null) 'quantizationType': quantizationType,
      if (version != null) 'version': version,
      if (downloadUrl != null) 'downloadUrl': downloadUrl,
      if (checksum != null) 'checksum': checksum,
      if (license != null) 'license': license,
      if (inputShape != null) 'inputShape': inputShape,
      if (outputShape != null) 'outputShape': outputShape,
      if (performance != null) 'performance': performance!.toJson(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Creates from JSON
  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      sizeBytes: json['sizeBytes'] as int,
      framework: json['framework'] as String,
      quantized: json['quantized'] as bool,
      quantizationType: json['quantizationType'] as String?,
      version: json['version'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      checksum: json['checksum'] as String?,
      license: json['license'] as String?,
      inputShape: (json['inputShape'] as List?)?.map((e) => e as int).toList(),
      outputShape: (json['outputShape'] as List?)?.map((e) => e as int).toList(),
      performance: json['performance'] != null
          ? ModelPerformance.fromJson(json['performance'] as Map<String, dynamic>)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'ModelInfo(id: $id, name: $name, size: $sizeFormatted, framework: $framework)';
  }
}

/// Performance expectations for a model
class ModelPerformance {
  /// Expected inference time in milliseconds for low-end device
  final int? lowEndDeviceMs;

  /// Expected inference time in milliseconds for mid-range device
  final int? midRangeDeviceMs;

  /// Expected inference time in milliseconds for high-end device
  final int? highEndDeviceMs;

  /// Minimum required RAM in MB
  final int? minRamMb;

  /// Recommended RAM in MB
  final int? recommendedRamMb;

  /// Device profile (low, medium, high)
  final String? recommendedProfile;

  const ModelPerformance({
    this.lowEndDeviceMs,
    this.midRangeDeviceMs,
    this.highEndDeviceMs,
    this.minRamMb,
    this.recommendedRamMb,
    this.recommendedProfile,
  });

  Map<String, dynamic> toJson() {
    return {
      if (lowEndDeviceMs != null) 'lowEndDeviceMs': lowEndDeviceMs,
      if (midRangeDeviceMs != null) 'midRangeDeviceMs': midRangeDeviceMs,
      if (highEndDeviceMs != null) 'highEndDeviceMs': highEndDeviceMs,
      if (minRamMb != null) 'minRamMb': minRamMb,
      if (recommendedRamMb != null) 'recommendedRamMb': recommendedRamMb,
      if (recommendedProfile != null) 'recommendedProfile': recommendedProfile,
    };
  }

  factory ModelPerformance.fromJson(Map<String, dynamic> json) {
    return ModelPerformance(
      lowEndDeviceMs: json['lowEndDeviceMs'] as int?,
      midRangeDeviceMs: json['midRangeDeviceMs'] as int?,
      highEndDeviceMs: json['highEndDeviceMs'] as int?,
      minRamMb: json['minRamMb'] as int?,
      recommendedRamMb: json['recommendedRamMb'] as int?,
      recommendedProfile: json['recommendedProfile'] as String?,
    );
  }
}
