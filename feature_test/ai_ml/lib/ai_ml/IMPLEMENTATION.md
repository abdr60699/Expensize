<!-- AUTO_FILE_HEADER -->

# AI/ML Module - Implementation Guide

This guide provides detailed implementation instructions for integrating the AI/ML module into your Flutter application.

## Table of Contents

1. [Setup and Configuration](#setup-and-configuration)
2. [Image Classification](#image-classification)
3. [Object Detection](#object-detection)
4. [OCR (Text Recognition)](#ocr-text-recognition)
5. [Text Embeddings](#text-embeddings)
6. [Vector Store & Retrieval](#vector-store--retrieval)
7. [Chat & RAG Pipeline](#chat--rag-pipeline)
8. [Custom Adapters](#custom-adapters)
9. [Performance Optimization](#performance-optimization)
10. [Error Handling](#error-handling)

## Setup and Configuration

### 1. Basic Initialization

```dart
import 'package:reuablewidgets/features/ai_ml/ai_ml.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AiMlManager _aiMl;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAiMl();
  }

  Future<void> _initializeAiMl() async {
    try {
      // Create configuration
      final config = AiMlConfig(
        inferencePolicy: InferencePolicy.preferOnDevice,
        enableLogging: true,
        apiKeys: {
          'openai': await _getApiKey('openai'),
        },
      );

      // Create manager
      _aiMl = AiMlManager(
        config: config,
        logger: const ConsoleLogger(enabled: true),
      );

      // Initialize
      await _aiMl.initialize(config);

      // Register adapters
      await _registerAdapters();

      setState(() => _initialized = true);
    } catch (e) {
      print('Failed to initialize AI/ML: $e');
    }
  }

  Future<String> _getApiKey(String service) async {
    // Retrieve from secure storage
    final storage = FlutterSecureStorage();
    return await storage.read(key: '${service}_api_key') ?? '';
  }

  Future<void> _registerAdapters() async {
    // Register adapters (see sections below)
  }

  @override
  void dispose() {
    _aiMl.dispose();
    super.dispose();
  }
}
```

### 2. Inference Policy Selection

Choose the right policy for your use case:

```dart
// Privacy-first: Always use on-device
final config = AiMlConfig(
  inferencePolicy: InferencePolicy.onDeviceOnly,
);

// Cloud-first: Better accuracy, requires internet
final config = AiMlConfig(
  inferencePolicy: InferencePolicy.preferCloud,
);

// Hybrid: Best of both worlds
final config = AiMlConfig(
  inferencePolicy: InferencePolicy.preferOnDevice,
);
```

## Image Classification

### Setup

```dart
Future<void> _setupImageClassification() async {
  // Load labels from assets
  final labelsString = await rootBundle.loadString(
    'lib/features/ai_ml/assets/models/imagenet_labels.txt',
  );
  final labels = labelsString.split('\n');

  // Create adapter
  final adapter = TfliteImageClassificationAdapter(
    modelInfo: ModelInfo(
      id: 'mobilenet_v2_1.0_224_quantized',
      name: 'MobileNet V2 Quantized',
      sizeBytes: 3500000,
      framework: 'tflite',
      quantized: true,
      quantizationType: 'int8',
    ),
    labels: labels,
    inputSize: 224,
    useGpuDelegate: Platform.isAndroid || Platform.isIOS,
  );

  await adapter.initialize();
  _aiMl.registerAdapter('image_classifier', adapter);
}
```

### Usage

```dart
Future<void> classifyImage(File imageFile) async {
  try {
    final result = await _aiMl.classifyImage(
      imageFile,
      modelId: 'image_classifier',
      threshold: 0.1, // Minimum confidence
    );

    // Display results
    setState(() {
      _classificationResults = result.labels.take(5).toList();
    });

    // Log performance
    print('Inference time: ${result.inferenceTimeMs}ms');
  } on InferenceException catch (e) {
    print('Inference failed: ${e.message}');
  }
}
```

### UI Integration

```dart
Widget buildClassificationResults() {
  return ListView.builder(
    itemCount: _classificationResults.length,
    itemBuilder: (context, index) {
      final label = _classificationResults[index];
      return ListTile(
        title: Text(label.label),
        trailing: Text(
          '${(label.score * 100).toStringAsFixed(1)}%',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: CircularProgressIndicator(
          value: label.score,
        ),
      );
    },
  );
}
```

## Object Detection

### Setup

```dart
Future<void> _setupObjectDetection() async {
  final adapter = MlKitObjectDetectionAdapter(
    modelInfo: ModelInfo(
      id: 'mlkit_object_detection',
      name: 'ML Kit Object Detection',
      sizeBytes: 0,
      framework: 'mlkit',
      quantized: false,
    ),
    options: ObjectDetectorOptions(
      mode: DetectionMode.stream,
      classifyObjects: true,
      multipleObjects: true,
    ),
  );

  await adapter.initialize();
  _aiMl.registerAdapter('object_detector', adapter);
}
```

### Real-Time Detection

```dart
StreamSubscription<CameraImage>? _cameraSubscription;

void startRealtimeDetection(CameraController camera) {
  _cameraSubscription = camera.imageStream.listen((image) async {
    // Convert CameraImage to File (implementation depends on your setup)
    final imageFile = await _convertToFile(image);

    final objects = await _aiMl.detectObjects(
      imageFile,
      modelId: 'object_detector',
      threshold: 0.5,
    );

    setState(() {
      _detectedObjects = objects;
    });
  });
}

void stopRealtimeDetection() {
  _cameraSubscription?.cancel();
}
```

## OCR (Text Recognition)

### Setup

```dart
Future<void> _setupOcr() async {
  final adapter = MlKitOcrAdapter(
    modelInfo: ModelInfo(
      id: 'mlkit_text_recognition',
      name: 'ML Kit OCR',
      sizeBytes: 0,
      framework: 'mlkit',
      quantized: false,
    ),
    supportedLanguages: ['en', 'es', 'fr'],
  );

  await adapter.initialize();
  _aiMl.registerAdapter('ocr', adapter);
}
```

### Document Scanning

```dart
Future<void> scanDocument(File imageFile) async {
  try {
    final result = await _aiMl.runOcr(
      imageFile,
      modelId: 'ocr',
    );

    // Extract text
    final fullText = result.text;

    // Process high-confidence blocks
    final confidentBlocks = result.getAboveThreshold(0.8);

    // Display results
    setState(() {
      _ocrText = fullText;
      _ocrBlocks = confidentBlocks;
    });

    print('Extracted ${result.blocks.length} text blocks');
  } catch (e) {
    print('OCR failed: $e');
  }
}
```

### Receipt/Form Processing

```dart
Future<Map<String, String>> extractReceiptData(File receiptImage) async {
  final result = await _aiMl.runOcr(receiptImage);

  final data = <String, String>{};

  // Parse structured data
  for (final block in result.blocks) {
    // Example: Extract total amount
    if (block.text.toLowerCase().contains('total')) {
      final amountMatch = RegExp(r'\$?(\d+\.\d{2})').firstMatch(block.text);
      if (amountMatch != null) {
        data['total'] = amountMatch.group(1)!;
      }
    }

    // Extract date
    final dateMatch = RegExp(r'(\d{1,2}/\d{1,2}/\d{2,4})').firstMatch(block.text);
    if (dateMatch != null) {
      data['date'] = dateMatch.group(1)!;
    }
  }

  return data;
}
```

## Text Embeddings

### Setup

```dart
Future<void> _setupTextEmbeddings() async {
  // Load vocabulary if needed
  final vocabString = await rootBundle.loadString(
    'lib/features/ai_ml/assets/models/vocabulary.txt',
  );
  final vocab = <String, int>{};
  vocabString.split('\n').asMap().forEach((i, word) {
    vocab[word] = i;
  });

  final adapter = TfliteTextEmbeddingAdapter(
    modelInfo: ModelInfo(
      id: 'universal_sentence_encoder_lite',
      name: 'USE Lite',
      sizeBytes: 50000000,
      framework: 'tflite',
      quantized: false,
    ),
    maxSequenceLength: 128,
    vocabulary: vocab,
  );

  await adapter.initialize();
  _aiMl.registerAdapter('text_embedder', adapter);
}
```

### Semantic Search

```dart
Future<List<String>> semanticSearch(String query, List<String> documents) async {
  // Generate query embedding
  final queryEmbedding = await _aiMl.embedText(
    query,
    modelId: 'text_embedder',
  );

  // Generate document embeddings
  final adapter = _aiMl._adapters['text_embedder'] as TextEmbeddingAdapter;
  final docEmbeddings = await adapter.embedBatch(documents);

  // Compute similarities
  final similarities = docEmbeddings.map((docEmb) {
    return queryEmbedding.cosineSimilarity(docEmb);
  }).toList();

  // Sort by similarity
  final indexed = List.generate(documents.length, (i) => i);
  indexed.sort((a, b) => similarities[b].compareTo(similarities[a]));

  // Return top results
  return indexed.take(5).map((i) => documents[i]).toList();
}
```

## Vector Store & Retrieval

### Setup

```dart
Future<void> _setupVectorStore() async {
  // Create embedding generator
  final embeddingGenerator = _TextEmbeddingAdapter(_aiMl);

  // Create vector store
  final vectorStore = SqliteVectorStore(
    dbName: 'my_knowledge_base',
    embeddingGenerator: embeddingGenerator,
  );

  await vectorStore.initialize();
  _aiMl.registerVectorStore('kb', vectorStore);
}

class _TextEmbeddingAdapter implements TextEmbeddingGenerator {
  final AiMlManager aiMl;
  _TextEmbeddingAdapter(this.aiMl);

  @override
  Future<TextEmbedding> generate(String text) async {
    return aiMl.embedText(text, modelId: 'text_embedder');
  }
}
```

### Document Ingestion

```dart
Future<void> ingestDocuments(List<String> documents) async {
  final vectorStore = _aiMl._vectorStores['kb']!;

  for (int i = 0; i < documents.length; i++) {
    // Chunk large documents
    final chunks = _chunkDocument(documents[i], maxChunkSize: 500);

    for (int j = 0; j < chunks.length; j++) {
      await vectorStore.addDocument(
        'doc_${i}_chunk_$j',
        chunks[j],
        metadata: {
          'document_id': i,
          'chunk_index': j,
          'total_chunks': chunks.length,
        },
      );
    }
  }

  print('Ingested ${documents.length} documents');
}

List<String> _chunkDocument(String text, {int maxChunkSize = 500, int overlap = 50}) {
  final chunks = <String>[];
  int start = 0;

  while (start < text.length) {
    int end = (start + maxChunkSize).clamp(0, text.length);

    // Try to break at sentence boundary
    if (end < text.length) {
      final sentenceEnd = text.lastIndexOf('.', end);
      if (sentenceEnd > start) {
        end = sentenceEnd + 1;
      }
    }

    chunks.add(text.substring(start, end).trim());
    start = end - overlap;
  }

  return chunks;
}
```

## Chat & RAG Pipeline

### Complete RAG Setup

```dart
class ChatWithRAG {
  final AiMlManager aiMl;
  ChatSession? _session;

  ChatWithRAG(this.aiMl);

  Future<void> initialize() async {
    // 1. Setup embedding adapter (see above)
    await _setupTextEmbeddings();

    // 2. Setup vector store (see above)
    await _setupVectorStore();

    // 3. Setup chat adapter
    final chatAdapter = OpenAiChatAdapter(
      apiKey: await _getApiKey('openai'),
      model: 'gpt-3.5-turbo',
    );
    await chatAdapter.initialize();
    aiMl.registerChatAdapter('openai', chatAdapter);

    // 4. Create chat session
    _session = aiMl.createChatSession(
      config: ChatSessionConfig(
        backend: ModelProvider.openai,
        systemPrompt: '''
You are a helpful AI assistant with access to a knowledge base.
Use the provided context to answer questions accurately.
If the context doesn't contain relevant information, say so.
''',
        retrieval: RetrievalConfig(
          vectorStoreId: 'kb',
          topK: 3,
          minSimilarity: 0.7,
          maxChunkSize: 500,
          chunkOverlap: 50,
        ),
        temperature: 0.7,
        maxTokens: 500,
      ),
    );
  }

  Future<ChatResponse> chat(String message) async {
    if (_session == null) {
      throw Exception('Chat not initialized');
    }

    return await aiMl.chatGenerate(
      _session!,
      message,
      options: ChatOptions(
        stream: false,
      ),
    );
  }

  Future<void> dispose() async {
    if (_session != null) {
      await aiMl.closeChatSession(_session!);
    }
  }
}
```

### Streaming Responses

```dart
Future<void> chatWithStreaming(String message) async {
  final response = await aiMl.chatGenerate(
    session,
    message,
    options: ChatOptions(stream: true),
  );

  // Listen to streaming tokens
  if (response.streamingTokens != null) {
    final buffer = StringBuffer();

    await for (final token in response.streamingTokens!) {
      buffer.write(token);
      setState(() {
        _chatResponse = buffer.toString();
      });
    }
  }
}
```

## Custom Adapters

### Creating a Custom Model Adapter

```dart
class CustomImageClassifier extends ImageClassificationAdapter {
  @override
  bool _isInitialized = false;

  @override
  Future<ModelInfo> info() async {
    return ModelInfo(
      id: 'custom_model',
      name: 'Custom Model',
      sizeBytes: 10000000,
      framework: 'custom',
      quantized: false,
    );
  }

  @override
  Future<void> initialize() async {
    // Initialize your custom model
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<ImageClassificationResult> classify(
    File imageFile, {
    double threshold = 0.0,
  }) async {
    // Your custom classification logic
    final labels = <LabelScore>[
      LabelScore(label: 'cat', score: 0.95),
      LabelScore(label: 'dog', score: 0.03),
    ];

    return ImageClassificationResult(
      labels: labels.where((l) => l.score >= threshold).toList(),
      modelId: 'custom_model',
    );
  }

  @override
  Future<ImageClassificationResult> classifyFromBytes(
    List<int> imageBytes, {
    double threshold = 0.0,
  }) async {
    // Implement byte-based classification
    throw UnimplementedError();
  }
}
```

## Performance Optimization

### 1. Model Selection

```dart
// Low-end devices: Use quantized models
if (_isLowEndDevice()) {
  modelId = 'mobilenet_v2_1.0_224_quantized';
} else {
  modelId = 'mobilenet_v2_1.0_224';
}
```

### 2. GPU Delegation

```dart
final adapter = TfliteImageClassificationAdapter(
  useGpuDelegate: true, // Enable GPU
  // ...
);
```

### 3. Batch Processing

```dart
// Instead of processing one by one
for (final text in texts) {
  await adapter.embed(text);
}

// Process in batch
final embeddings = await adapter.embedBatch(texts);
```

### 4. Lazy Loading

```dart
// Initialize adapters only when needed
Future<void> _ensureAdapterInitialized(String modelId) async {
  final adapter = _aiMl._adapters[modelId];
  if (adapter != null && !adapter.isInitialized) {
    await adapter.initialize();
  }
}
```

## Error Handling

### Comprehensive Error Handling

```dart
Future<void> performInference(File imageFile) async {
  try {
    final result = await _aiMl.classifyImage(imageFile);
    // Handle success
  } on ModelNotFoundException catch (e) {
    // Model not found - download it
    await _downloadModel(e.modelId);
    return performInference(imageFile); // Retry
  } on InferenceException catch (e) {
    // Inference failed - try fallback
    if (_aiMl.config.inferencePolicy == InferencePolicy.preferOnDevice) {
      // Fallback to cloud
      await _useCloudInference(imageFile);
    } else {
      _showError('Inference failed: ${e.message}');
    }
  } on InitializationException catch (e) {
    _showError('Initialization failed: ${e.message}');
  } on AiMlException catch (e) {
    _showError('AI/ML error: ${e.message}');
  } catch (e) {
    _showError('Unknown error: $e');
  }
}
```

---

For more examples, see `examples/example_main.dart`.
