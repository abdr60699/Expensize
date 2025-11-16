import 'dart:ui';

/// Represents a detected object in an image
class DetectedObject {
  /// Object label/class
  final String label;

  /// Confidence score (0.0 to 1.0)
  final double score;

  /// Bounding box rectangle (normalized coordinates 0.0 to 1.0)
  final Rect boundingBox;

  /// Optional tracking ID for video
  final int? trackingId;

  /// Additional attributes
  final Map<String, dynamic>? attributes;

  const DetectedObject({
    required this.label,
    required this.score,
    required this.boundingBox,
    this.trackingId,
    this.attributes,
  });

  /// Creates a copy with optional field updates
  DetectedObject copyWith({
    String? label,
    double? score,
    Rect? boundingBox,
    int? trackingId,
    Map<String, dynamic>? attributes,
  }) {
    return DetectedObject(
      label: label ?? this.label,
      score: score ?? this.score,
      boundingBox: boundingBox ?? this.boundingBox,
      trackingId: trackingId ?? this.trackingId,
      attributes: attributes ?? this.attributes,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'score': score,
      'boundingBox': {
        'left': boundingBox.left,
        'top': boundingBox.top,
        'right': boundingBox.right,
        'bottom': boundingBox.bottom,
      },
      if (trackingId != null) 'trackingId': trackingId,
      if (attributes != null) 'attributes': attributes,
    };
  }

  /// Creates from JSON
  factory DetectedObject.fromJson(Map<String, dynamic> json) {
    final bbox = json['boundingBox'] as Map<String, dynamic>;
    return DetectedObject(
      label: json['label'] as String,
      score: (json['score'] as num).toDouble(),
      boundingBox: Rect.fromLTRB(
        (bbox['left'] as num).toDouble(),
        (bbox['top'] as num).toDouble(),
        (bbox['right'] as num).toDouble(),
        (bbox['bottom'] as num).toDouble(),
      ),
      trackingId: json['trackingId'] as int?,
      attributes: json['attributes'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'DetectedObject(label: $label, score: ${score.toStringAsFixed(4)}, bbox: $boundingBox)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DetectedObject &&
        other.label == label &&
        other.score == score &&
        other.boundingBox == boundingBox &&
        other.trackingId == trackingId;
  }

  @override
  int get hashCode => Object.hash(label, score, boundingBox, trackingId);
}
