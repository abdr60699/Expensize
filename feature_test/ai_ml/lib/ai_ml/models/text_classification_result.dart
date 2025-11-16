import 'label_score.dart';

/// Result from text classification
class TextClassificationResult {
  /// List of predicted labels with scores
  final List<LabelScore> labels;

  /// Time taken for inference in milliseconds
  final int? inferenceTimeMs;

  /// Model ID used for classification
  final String? modelId;

  /// Original text that was classified
  final String? originalText;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const TextClassificationResult({
    required this.labels,
    this.inferenceTimeMs,
    this.modelId,
    this.originalText,
    this.metadata,
  });

  /// Gets the top prediction
  LabelScore? get topPrediction => labels.isNotEmpty ? labels.first : null;

  /// Gets predictions above a certain threshold
  List<LabelScore> getAboveThreshold(double threshold) {
    return labels.where((label) => label.score >= threshold).toList();
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'labels': labels.map((l) => l.toJson()).toList(),
      if (inferenceTimeMs != null) 'inferenceTimeMs': inferenceTimeMs,
      if (modelId != null) 'modelId': modelId,
      if (originalText != null) 'originalText': originalText,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Creates from JSON
  factory TextClassificationResult.fromJson(Map<String, dynamic> json) {
    return TextClassificationResult(
      labels: (json['labels'] as List)
          .map((l) => LabelScore.fromJson(l as Map<String, dynamic>))
          .toList(),
      inferenceTimeMs: json['inferenceTimeMs'] as int?,
      modelId: json['modelId'] as String?,
      originalText: json['originalText'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    final topLabels = labels.take(3).map((l) => l.toString()).join(', ');
    return 'TextClassificationResult(labels: [$topLabels], inferenceTimeMs: $inferenceTimeMs)';
  }
}
