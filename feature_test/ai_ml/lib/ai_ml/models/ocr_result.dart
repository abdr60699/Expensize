import 'dart:ui';

/// Represents a block of text detected in OCR
class OcrBlock {
  /// The recognized text
  final String text;

  /// Confidence score (0.0 to 1.0)
  final double confidence;

  /// Bounding box of the text block
  final Rect? boundingBox;

  /// Language code (e.g., 'en', 'es')
  final String? language;

  /// Corner points of the text region
  final List<Offset>? cornerPoints;

  const OcrBlock({
    required this.text,
    required this.confidence,
    this.boundingBox,
    this.language,
    this.cornerPoints,
  });

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'confidence': confidence,
      if (boundingBox != null)
        'boundingBox': {
          'left': boundingBox!.left,
          'top': boundingBox!.top,
          'right': boundingBox!.right,
          'bottom': boundingBox!.bottom,
        },
      if (language != null) 'language': language,
      if (cornerPoints != null)
        'cornerPoints': cornerPoints!
            .map((p) => {'x': p.dx, 'y': p.dy})
            .toList(),
    };
  }

  /// Creates from JSON
  factory OcrBlock.fromJson(Map<String, dynamic> json) {
    Rect? bbox;
    if (json['boundingBox'] != null) {
      final b = json['boundingBox'] as Map<String, dynamic>;
      bbox = Rect.fromLTRB(
        (b['left'] as num).toDouble(),
        (b['top'] as num).toDouble(),
        (b['right'] as num).toDouble(),
        (b['bottom'] as num).toDouble(),
      );
    }

    List<Offset>? corners;
    if (json['cornerPoints'] != null) {
      corners = (json['cornerPoints'] as List)
          .map((p) => Offset(
                (p['x'] as num).toDouble(),
                (p['y'] as num).toDouble(),
              ))
          .toList();
    }

    return OcrBlock(
      text: json['text'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      boundingBox: bbox,
      language: json['language'] as String?,
      cornerPoints: corners,
    );
  }

  @override
  String toString() =>
      'OcrBlock(text: "$text", confidence: ${confidence.toStringAsFixed(4)})';
}

/// Result from OCR operation
class OcrResult {
  /// Complete recognized text
  final String text;

  /// Individual text blocks
  final List<OcrBlock> blocks;

  /// Time taken for OCR in milliseconds
  final int? inferenceTimeMs;

  /// Model ID used for OCR
  final String? modelId;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const OcrResult({
    required this.text,
    required this.blocks,
    this.inferenceTimeMs,
    this.modelId,
    this.metadata,
  });

  /// Gets text blocks with confidence above threshold
  List<OcrBlock> getAboveThreshold(double threshold) {
    return blocks.where((block) => block.confidence >= threshold).toList();
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'blocks': blocks.map((b) => b.toJson()).toList(),
      if (inferenceTimeMs != null) 'inferenceTimeMs': inferenceTimeMs,
      if (modelId != null) 'modelId': modelId,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Creates from JSON
  factory OcrResult.fromJson(Map<String, dynamic> json) {
    return OcrResult(
      text: json['text'] as String,
      blocks: (json['blocks'] as List)
          .map((b) => OcrBlock.fromJson(b as Map<String, dynamic>))
          .toList(),
      inferenceTimeMs: json['inferenceTimeMs'] as int?,
      modelId: json['modelId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'OcrResult(text: "${text.substring(0, text.length > 50 ? 50 : text.length)}...", blocks: ${blocks.length})';
  }
}
