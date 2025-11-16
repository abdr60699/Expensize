/// Represents a classification label with its confidence score
class LabelScore {
  /// The label/class name
  final String label;

  /// Confidence score (0.0 to 1.0)
  final double score;

  /// Optional index in the model's output
  final int? index;

  const LabelScore({
    required this.label,
    required this.score,
    this.index,
  });

  /// Creates a copy with optional field updates
  LabelScore copyWith({
    String? label,
    double? score,
    int? index,
  }) {
    return LabelScore(
      label: label ?? this.label,
      score: score ?? this.score,
      index: index ?? this.index,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'score': score,
      if (index != null) 'index': index,
    };
  }

  /// Creates from JSON
  factory LabelScore.fromJson(Map<String, dynamic> json) {
    return LabelScore(
      label: json['label'] as String,
      score: (json['score'] as num).toDouble(),
      index: json['index'] as int?,
    );
  }

  @override
  String toString() =>
      'LabelScore(label: $label, score: ${score.toStringAsFixed(4)})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LabelScore &&
        other.label == label &&
        other.score == score &&
        other.index == index;
  }

  @override
  int get hashCode => Object.hash(label, score, index);
}
