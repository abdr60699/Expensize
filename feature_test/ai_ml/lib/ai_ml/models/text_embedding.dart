/// Represents a text embedding vector
class TextEmbedding {
  /// The embedding vector
  final List<double> vector;

  /// Original text that was embedded
  final String? originalText;

  /// Model ID used for embedding
  final String? modelId;

  /// Time taken for embedding in milliseconds
  final int? inferenceTimeMs;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const TextEmbedding({
    required this.vector,
    this.originalText,
    this.modelId,
    this.inferenceTimeMs,
    this.metadata,
  });

  /// Gets the dimension of the embedding
  int get dimension => vector.length;

  /// Normalizes the vector to unit length (L2 norm)
  TextEmbedding normalize() {
    final magnitude = _computeMagnitude();
    if (magnitude == 0) return this;

    final normalized = vector.map((v) => v / magnitude).toList();
    return TextEmbedding(
      vector: normalized,
      originalText: originalText,
      modelId: modelId,
      inferenceTimeMs: inferenceTimeMs,
      metadata: metadata,
    );
  }

  /// Computes L2 magnitude
  double _computeMagnitude() {
    return vector.fold(0.0, (sum, v) => sum + v * v);
  }

  /// Computes cosine similarity with another embedding
  double cosineSimilarity(TextEmbedding other) {
    if (vector.length != other.vector.length) {
      throw ArgumentError('Embeddings must have the same dimension');
    }

    double dotProduct = 0.0;
    double magnitudeA = 0.0;
    double magnitudeB = 0.0;

    for (int i = 0; i < vector.length; i++) {
      dotProduct += vector[i] * other.vector[i];
      magnitudeA += vector[i] * vector[i];
      magnitudeB += other.vector[i] * other.vector[i];
    }

    final magnitude = magnitudeA * magnitudeB;
    if (magnitude == 0) return 0.0;

    return dotProduct / magnitude;
  }

  /// Computes L2 (Euclidean) distance to another embedding
  double l2Distance(TextEmbedding other) {
    if (vector.length != other.vector.length) {
      throw ArgumentError('Embeddings must have the same dimension');
    }

    double sum = 0.0;
    for (int i = 0; i < vector.length; i++) {
      final diff = vector[i] - other.vector[i];
      sum += diff * diff;
    }

    return sum; // Return squared distance for efficiency
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'vector': vector,
      if (originalText != null) 'originalText': originalText,
      if (modelId != null) 'modelId': modelId,
      if (inferenceTimeMs != null) 'inferenceTimeMs': inferenceTimeMs,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Creates from JSON
  factory TextEmbedding.fromJson(Map<String, dynamic> json) {
    return TextEmbedding(
      vector: (json['vector'] as List).map((v) => (v as num).toDouble()).toList(),
      originalText: json['originalText'] as String?,
      modelId: json['modelId'] as String?,
      inferenceTimeMs: json['inferenceTimeMs'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'TextEmbedding(dimension: $dimension, modelId: $modelId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TextEmbedding) return false;
    if (vector.length != other.vector.length) return false;
    for (int i = 0; i < vector.length; i++) {
      if (vector[i] != other.vector[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(vector);
}
