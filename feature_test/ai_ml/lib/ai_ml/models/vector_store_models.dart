import 'text_embedding.dart';

/// Represents a document in the vector store
class VectorDocument {
  /// Unique document ID
  final String id;

  /// Document text content
  final String text;

  /// Text embedding
  final TextEmbedding? embedding;

  /// Document metadata
  final Map<String, dynamic>? metadata;

  /// Timestamp when added
  final DateTime createdAt;

  const VectorDocument({
    required this.id,
    required this.text,
    this.embedding,
    this.metadata,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? const _DefaultTimestamp();

  VectorDocument copyWith({
    String? id,
    String? text,
    TextEmbedding? embedding,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return VectorDocument(
      id: id ?? this.id,
      text: text ?? this.text,
      embedding: embedding ?? this.embedding,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      if (embedding != null) 'embedding': embedding!.toJson(),
      if (metadata != null) 'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory VectorDocument.fromJson(Map<String, dynamic> json) {
    return VectorDocument(
      id: json['id'] as String,
      text: json['text'] as String,
      embedding: json['embedding'] != null
          ? TextEmbedding.fromJson(json['embedding'] as Map<String, dynamic>)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    final preview = text.length > 50 ? '${text.substring(0, 50)}...' : text;
    return 'VectorDocument(id: $id, text: "$preview")';
  }
}

/// Workaround for const DateTime
class _DefaultTimestamp extends DateTime {
  const _DefaultTimestamp() : super.fromMillisecondsSinceEpoch(0);
}

/// Document with similarity score
class ScoredDocument {
  /// The document
  final VectorDocument document;

  /// Similarity score
  final double score;

  const ScoredDocument({
    required this.document,
    required this.score,
  });

  /// Convenience getter for document ID
  String get id => document.id;

  /// Convenience getter for document text
  String get text => document.text;

  /// Convenience getter for document metadata
  Map<String, dynamic>? get metadata => document.metadata;

  Map<String, dynamic> toJson() {
    return {
      'document': document.toJson(),
      'score': score,
    };
  }

  factory ScoredDocument.fromJson(Map<String, dynamic> json) {
    return ScoredDocument(
      document: VectorDocument.fromJson(json['document'] as Map<String, dynamic>),
      score: (json['score'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'ScoredDocument(id: $id, score: ${score.toStringAsFixed(4)})';
  }
}

/// Query options for vector store
class VectorQueryOptions {
  /// Number of results to return
  final int topK;

  /// Minimum similarity threshold
  final double? minSimilarity;

  /// Filter by metadata
  final Map<String, dynamic>? metadataFilter;

  /// Similarity metric to use
  final SimilarityMetric metric;

  const VectorQueryOptions({
    this.topK = 10,
    this.minSimilarity,
    this.metadataFilter,
    this.metric = SimilarityMetric.cosine,
  });
}

/// Similarity metric for vector search
enum SimilarityMetric {
  /// Cosine similarity
  cosine,

  /// Euclidean (L2) distance
  euclidean,

  /// Dot product
  dotProduct,
}
