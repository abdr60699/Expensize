# AI/ML Module - Production-Ready Flutter Package

A comprehensive Flutter package for on-device ML and cloud LLM integration with RAG (Retrieval-Augmented Generation) support.

## Features

### On-Device Machine Learning
- **Image Classification**: Classify images using TensorFlow Lite models
- **Object Detection**: Detect and locate multiple objects in images
- **OCR (Optical Character Recognition)**: Extract text from images using Google ML Kit
- **Text Embeddings**: Generate vector embeddings for semantic search
- **Text Classification**: Categorize text using ML models

### Cloud LLM Integration
- **Multi-Provider Support**: OpenAI, Anthropic, Vertex AI, Azure OpenAI
- **Chat Sessions**: Stateful conversations with context management
- **Streaming Responses**: Real-time token streaming for better UX
- **Custom System Prompts**: Configure AI behavior per session

### RAG (Retrieval-Augmented Generation)
- **Vector Store**: SQLite-based vector database for efficient similarity search
- **Semantic Search**: Find relevant documents using cosine similarity
- **Context Injection**: Automatically enhance prompts with retrieved context
- **Flexible Retrieval**: Configure top-K, similarity thresholds, chunking

### Architecture
- **Adapter Pattern**: Swappable ML providers without changing core logic
- **Privacy-First**: On-device inference with offline capability
- **Modular Design**: Use only the features you need
- **Extensible**: Easy to add custom adapters and providers

## Prerequisites

- Flutter SDK (>=3.4.1 <4.0.0)
- Dart SDK
- For on-device ML: TensorFlow Lite models (.tflite files)
- For cloud LLMs: API keys (OpenAI, Anthropic, etc.)
- Android SDK 21+ or iOS 12+

## Installation

### 1. Navigate to the project directory

```bash
cd feature_test/ai_ml
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the demo application

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                          # Demo application
└── ai_ml/
    ├── ai_ml.dart                     # Main library export file
    ├── services/
    │   ├── ai_ml_manager.dart         # Main facade/coordinator
    │   ├── model_manager.dart         # Model download/management
    │   ├── chat_service.dart          # Chat service utilities
    │   └── adapters/
    │       ├── model_adapter.dart     # Base adapter interface
    │       ├── chat_adapter.dart      # Chat adapter interface
    │       ├── tflite_image_classification_adapter.dart
    │       ├── tflite_text_embedding_adapter.dart
    │       ├── mlkit_ocr_adapter.dart
    │       ├── mlkit_object_detection_adapter.dart
    │       └── openai_chat_adapter.dart
    ├── models/
    │   ├── chat_models.dart           # Chat & session models
    │   ├── image_classification_result.dart
    │   ├── detected_object.dart
    │   ├── ocr_result.dart
    │   ├── text_embedding.dart
    │   ├── text_classification_result.dart
    │   ├── model_info.dart
    │   ├── label_score.dart
    │   └── vector_store_models.dart
    ├── storage/
    │   └── vector_store.dart          # Vector database implementation
    ├── utils/
    │   └── logger.dart                # Logging utilities
    ├── errors/
    │   └── ai_ml_exceptions.dart      # Custom exceptions
    └── examples/
        └── example_main.dart          # Comprehensive usage examples
```

## Quick Start

### Initialize the Manager

```dart
import 'package:ai_ml/ai_ml/ai_ml.dart';

// Create configuration
final config = AiMlConfig(
  inferencePolicy: InferencePolicy.preferOnDevice,
  enableLogging: true,
  apiKeys: {
    'openai': 'your-api-key-here',
  },
);

// Create and initialize manager
final aiMl = AiMlManager(
  config: config,
  logger: const ConsoleLogger(enabled: true),
);

await aiMl.initialize(config);
```

### Image Classification

```dart
import 'dart:io';

// Register the adapter
final imageClassifier = TfliteImageClassificationAdapter(
  modelInfo: ModelInfo(
    id: 'mobilenet_v2',
    name: 'MobileNet V2',
    sizeBytes: 3500000,
    framework: 'tflite',
  ),
  labels: loadLabelsFromFile(), // Load from assets
  inputSize: 224,
);

await imageClassifier.initialize();
aiMl.registerAdapter('image_classifier', imageClassifier);

// Classify an image
final imageFile = File('/path/to/image.jpg');
final result = await aiMl.classifyImage(
  imageFile,
  threshold: 0.1,
);

print('Top predictions:');
for (final label in result.labels.take(5)) {
  print('${label.label}: ${(label.score * 100).toStringAsFixed(2)}%');
}
```

### OCR (Text Recognition)

```dart
// Register OCR adapter
final ocrAdapter = MlKitOcrAdapter(
  modelInfo: ModelInfo(
    id: 'mlkit_text',
    name: 'ML Kit Text Recognition',
    sizeBytes: 0,
    framework: 'mlkit',
  ),
);

await ocrAdapter.initialize();
aiMl.registerAdapter('ocr', ocrAdapter);

// Run OCR
final imageFile = File('/path/to/document.jpg');
final result = await aiMl.runOcr(imageFile);

print('Recognized text: ${result.text}');
print('Confidence: ${result.averageConfidence.toStringAsFixed(2)}');
```

### Text Embeddings & Vector Store

```dart
// Register embedding adapter
final embeddingAdapter = TfliteTextEmbeddingAdapter(
  modelInfo: ModelInfo(
    id: 'universal_sentence_encoder',
    name: 'Universal Sentence Encoder',
    sizeBytes: 50000000,
    framework: 'tflite',
  ),
);

await embeddingAdapter.initialize();
aiMl.registerAdapter('embedder', embeddingAdapter);

// Create vector store
final vectorStore = SqliteVectorStore(
  dbName: 'knowledge_base',
  embeddingGenerator: _YourEmbeddingGenerator(aiMl),
);

await vectorStore.initialize();
aiMl.registerVectorStore('docs', vectorStore);

// Add documents
await vectorStore.addDocument(
  'doc1',
  'Flutter is a UI toolkit for building apps.',
  metadata: {'category': 'tech'},
);

// Query for similar documents
final results = await vectorStore.query(
  'What is Flutter?',
  topK: 5,
  minSimilarity: 0.7,
);

for (final doc in results) {
  print('[${doc.score.toStringAsFixed(4)}] ${doc.text}');
}
```

### Chat with RAG

```dart
// Register chat adapter
final openAiAdapter = OpenAiChatAdapter(
  apiKey: 'your-openai-api-key',
  model: 'gpt-3.5-turbo',
);

await openAiAdapter.initialize();
aiMl.registerChatAdapter('openai', openAiAdapter);

// Create chat session with RAG
final session = aiMl.createChatSession(
  config: ChatSessionConfig(
    backend: ModelProvider.openai,
    systemPrompt: 'You are a helpful assistant with access to documentation.',
    retrieval: RetrievalConfig(
      vectorStoreId: 'docs',
      topK: 3,
      minSimilarity: 0.7,
    ),
    temperature: 0.7,
    maxTokens: 500,
  ),
);

// Generate response (with automatic context retrieval)
final response = await aiMl.chatGenerate(
  session,
  'How do I use Flutter for mobile development?',
);

print('Assistant: ${response.text}');

if (response.retrievedDocuments != null) {
  print('\nRetrieved ${response.retrievedDocuments!.length} relevant documents');
}
```

## Configuration

### Inference Policies

```dart
enum InferencePolicy {
  preferOnDevice,   // Try on-device first, fallback to cloud
  preferCloud,      // Try cloud first, fallback to on-device
  onDeviceOnly,     // Only use on-device models
  cloudOnly,        // Only use cloud APIs
}
```

### Chat Session Configuration

```dart
ChatSessionConfig(
  backend: ModelProvider.openai,        // Which LLM provider
  useOnDeviceModel: false,              // Use local LLM if available
  modelId: 'gpt-4',                     // Specific model ID
  systemPrompt: 'Custom instructions',   // System prompt
  maxHistoryMessages: 10,               // Context window size
  temperature: 0.7,                     // Creativity (0.0 - 1.0)
  maxTokens: 1000,                      // Maximum response length
  retrieval: RetrievalConfig(...),      // RAG configuration
)
```

### Retrieval Configuration

```dart
RetrievalConfig(
  vectorStoreId: 'my_docs',    // Which vector store to query
  topK: 5,                     // Number of documents to retrieve
  minSimilarity: 0.7,          // Minimum cosine similarity
  includeMetadata: true,       // Include document metadata
  maxChunkSize: 500,           // Maximum tokens per chunk
  chunkOverlap: 50,            // Overlap between chunks
)
```

## Demo Application

The demo app showcases the AI/ML module capabilities with an interactive UI:

### Features
- **Overview Tab**: Module capabilities and configuration
- **Features Tab**: Detailed API documentation for all methods
- **Architecture Tab**: System design and data flow visualization
- **Logs Tab**: Real-time logging of operations

### Running the Demo

```bash
cd feature_test/ai_ml
flutter run
```

## Supported Adapters

### On-Device ML
- **TFLite Image Classification**: Image categorization using TensorFlow Lite
- **TFLite Text Embedding**: Vector embeddings for semantic search
- **ML Kit OCR**: Text recognition from images
- **ML Kit Object Detection**: Multi-object detection and localization

### Cloud LLMs
- **OpenAI Chat**: GPT-3.5, GPT-4, and other OpenAI models
- **Anthropic** (coming soon): Claude models
- **Vertex AI** (coming soon): Google's LLM platform
- **Azure OpenAI** (coming soon): Microsoft's OpenAI service

## Advanced Usage

### Custom Adapters

Create your own adapter by implementing `ModelAdapter` or `ChatAdapter`:

```dart
class MyCustomAdapter implements ModelAdapter {
  @override
  Future<void> initialize() async {
    // Setup your ML framework
  }

  @override
  bool get isInitialized => _initialized;

  @override
  ModelInfo info() {
    return ModelInfo(
      id: 'my_custom_model',
      name: 'My Custom Model',
      sizeBytes: 1000000,
      framework: 'custom',
    );
  }

  @override
  Future<void> dispose() async {
    // Cleanup resources
  }
}
```

### Error Handling

```dart
try {
  final result = await aiMl.classifyImage(imageFile);
} on ModelNotFoundException catch (e) {
  print('Model not found: ${e.modelId}');
} on InitializationException catch (e) {
  print('Failed to initialize: ${e.message}');
} on ChatException catch (e) {
  print('Chat error: ${e.message}');
}
```

### Logging

```dart
// Custom logger
class MyLogger implements AiLogger {
  @override
  void info(String message, [dynamic data]) {
    // Your logging implementation
  }

  @override
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    // Your error tracking
  }

  // ... other methods
}

final aiMl = AiMlManager(
  config: config,
  logger: MyLogger(),
);
```

## Performance Tips

1. **Model Size**: Use quantized models (INT8) for faster inference
2. **GPU Delegation**: Enable GPU acceleration for TFLite when available
3. **Caching**: Cache embeddings and model results when appropriate
4. **Batch Processing**: Process multiple items together when possible
5. **Chunking**: Split large documents for better retrieval accuracy

## Privacy & Offline Support

- **On-Device First**: Process sensitive data locally without cloud APIs
- **Offline Capability**: Full functionality without internet connection
- **Data Control**: Choose which data stays local vs. cloud processing
- **No Tracking**: No built-in telemetry or user tracking

## Troubleshooting

### Issue: Model fails to load
**Solution**: Ensure the model file is in the correct assets directory and pubspec.yaml includes it.

### Issue: Out of memory
**Solution**: Use quantized models, reduce batch size, or enable GPU delegation.

### Issue: Slow inference
**Solution**: Enable GPU acceleration, use smaller models, or consider cloud inference for heavy tasks.

### Issue: Chat adapter not found
**Solution**: Register the adapter before creating a chat session.

## Dependencies

### Core Dependencies
- `tflite_flutter: ^0.10.4` - TensorFlow Lite for on-device ML
- `google_ml_kit: ^0.16.3` - Google ML Kit for OCR and object detection
- `http: ^1.1.0` - HTTP client for API calls

### Storage
- `sqflite: ^2.3.0` - SQLite for vector store
- `path_provider: ^2.1.1` - File system paths
- `path: ^1.8.3` - Path manipulation

### Image Processing
- `image: ^4.1.3` - Image manipulation
- `image_picker: ^1.0.4` - Image selection from gallery/camera

## Examples

See `/lib/ai_ml/examples/example_main.dart` for comprehensive usage examples including:
- Image classification workflow
- OCR text extraction
- Vector store setup and querying
- Chat with RAG implementation
- Error handling patterns

## Roadmap

- [ ] More LLM providers (Anthropic, Vertex AI, Azure OpenAI)
- [ ] On-device LLM support (Gemma, LLaMA)
- [ ] Advanced RAG patterns (hybrid search, re-ranking)
- [ ] Model compression utilities
- [ ] Benchmark and profiling tools
- [ ] Cloud model fine-tuning integration

## Contributing

This module is part of the Expensize project. For contributions:

1. Follow the existing adapter pattern
2. Add comprehensive tests
3. Document all public APIs
4. Ensure privacy-first design

## License

This is a feature module for the Expensize application.

## Support

For issues or questions about this module, please refer to the main Expensize project documentation or open an issue in the repository.

---

**Built with privacy and performance in mind**
