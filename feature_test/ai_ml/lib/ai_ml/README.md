<!-- AUTO_FILE_HEADER -->
<!-- This file is part of the reusable widgets library -->

# AI/ML Utility Module for Flutter

A production-ready, modular AI/ML utility module for Flutter applications with on-device ML capabilities and cloud LLM integration, including RAG (Retrieval-Augmented Generation) patterns.

## 🎯 Features

### On-Device ML
- **Image Classification** - Classify images using TensorFlow Lite models
- **Object Detection** - Detect and track objects in images
- **OCR (Text Recognition)** - Extract text from images and documents
- **Text Embeddings** - Generate semantic embeddings for text
- **Text Classification** - Classify text for intent detection or sentiment analysis

### Cloud Integration
- **Chatbot Templates** - Pre-built chat patterns with conversation history
- **RAG Pipeline** - Retrieval-Augmented Generation for context-aware responses
- **Multiple LLM Providers** - OpenAI, Anthropic, Azure OpenAI, Vertex AI
- **Streaming Support** - Real-time token streaming for chat responses

### Core Capabilities
- **Adapter Architecture** - Swappable ML providers (TFLite, ML Kit, ONNX, Cloud)
- **Vector Store** - Efficient similarity search with SQLite persistence
- **Hybrid Inference** - Automatic fallback between on-device and cloud
- **Model Management** - Download, verify, and cache models
- **Privacy-First** - On-device inference, offline capability
- **Battery Conscious** - Optimized for mobile with GPU delegate support

## 📋 Requirements

- **Flutter SDK**: >=3.4.1
- **Dart SDK**: >=3.4.1 <4.0.0
- **Android**: minSdkVersion 21 (Android 5.0+)
- **iOS**: 12.0+

## 📦 Installation

### 1. Add Dependencies

This module is part of the reusable widgets library. The required dependencies are already included in `pubspec.yaml`:

```yaml
dependencies:
  tflite_flutter: ^0.10.4
  google_ml_kit: ^0.18.0
  image: ^4.1.7
  sqflite: ^2.3.2
  vector_math: ^2.1.4
  crypto: ^3.0.3
  http: ^1.1.0
  path_provider: ^2.1.1
```

### 2. Platform Setup

#### Android

Add to `android/app/build.gradle`:

```gradle
android {
    // ...
    aaptOptions {
        noCompress 'tflite'
    }
}
```

For ML Kit OCR, add to `android/app/build.gradle`:

```gradle
dependencies {
    // ML Kit dependencies will be added automatically
}
```

#### iOS

Add to `ios/Podfile`:

```ruby
platform :ios, '12.0'

# Enable for TFLite models
target 'Runner' do
  use_frameworks!

  # ML Kit will be added automatically via google_ml_kit plugin
end
```

For camera permissions (if using camera for OCR/object detection), add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to perform OCR and object detection</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to process images</string>
```

## 🚀 Quick Start

### Basic Initialization

```dart
import 'package:reuablewidgets/features/ai_ml/ai_ml.dart';

// 1. Create configuration
final config = AiMlConfig(
  inferencePolicy: InferencePolicy.preferOnDevice,
  enableLogging: true,
  apiKeys: {
    'openai': 'your-api-key-here',
  },
);

// 2. Create manager
final aiMl = AiMlManager(
  config: config,
  logger: const ConsoleLogger(enabled: true),
);

// 3. Initialize
await aiMl.initialize(config);

// 4. Register adapters (see below)
```

### Image Classification

```dart
// Register image classification adapter
final classifier = TfliteImageClassificationAdapter(
  modelInfo: ModelInfo(
    id: 'mobilenet_v2_1.0_224_quantized',
    name: 'MobileNet V2 Quantized',
    sizeBytes: 3500000,
    framework: 'tflite',
    quantized: true,
  ),
  labels: imageNetLabels, // Load from file
  inputSize: 224,
  useGpuDelegate: true,
);

await classifier.initialize();
aiMl.registerAdapter('image_classifier', classifier);

// Classify an image
final result = await aiMl.classifyImage(
  imageFile,
  modelId: 'image_classifier',
  threshold: 0.1,
);

// Print top predictions
for (final label in result.labels.take(5)) {
  print('${label.label}: ${(label.score * 100).toStringAsFixed(2)}%');
}
```

### OCR (Text Recognition)

```dart
// Register OCR adapter
final ocrAdapter = MlKitOcrAdapter(
  modelInfo: ModelInfo(
    id: 'mlkit_text_recognition',
    name: 'ML Kit OCR',
    sizeBytes: 0,
    framework: 'mlkit',
    quantized: false,
  ),
);

await ocrAdapter.initialize();
aiMl.registerAdapter('ocr', ocrAdapter);

// Run OCR
final result = await aiMl.runOcr(imageFile, modelId: 'ocr');

print('Text: ${result.text}');
print('Blocks: ${result.blocks.length}');
```

### Chat with RAG

```dart
// 1. Set up vector store
final vectorStore = SqliteVectorStore(
  dbName: 'my_docs',
  embeddingGenerator: MyEmbeddingGenerator(), // See example
);
await vectorStore.initialize();
aiMl.registerVectorStore('docs', vectorStore);

// 2. Add documents
await vectorStore.addDocument(
  'doc1',
  'Flutter is a UI toolkit...',
  metadata: {'category': 'tech'},
);

// 3. Register chat adapter
final chatAdapter = OpenAiChatAdapter(
  apiKey: 'your-api-key',
  model: 'gpt-3.5-turbo',
);
await chatAdapter.initialize();
aiMl.registerChatAdapter('openai', chatAdapter);

// 4. Create chat session with RAG
final session = aiMl.createChatSession(
  config: ChatSessionConfig(
    backend: ModelProvider.openai,
    retrieval: RetrievalConfig(
      vectorStoreId: 'docs',
      topK: 3,
      minSimilarity: 0.7,
    ),
  ),
);

// 5. Generate response
final response = await aiMl.chatGenerate(
  session,
  'What is Flutter?',
);

print('Response: ${response.text}');
print('Retrieved docs: ${response.retrievedDocuments?.length}');
```

## 📖 Documentation

- **[IMPLEMENTATION.md](IMPLEMENTATION.md)** - Detailed implementation guide
- **[SECURITY.md](SECURITY.md)** - Security and privacy best practices
- **[MODEL_GUIDE.md](MODEL_GUIDE.md)** - Model selection and optimization
- **[examples/example_main.dart](examples/example_main.dart)** - Complete working examples

## 🏗️ Architecture

### Adapter Pattern

The module uses an adapter architecture allowing you to swap ML providers:

```
┌─────────────────┐
│  AiMlManager    │  ← Main facade
└────────┬────────┘
         │
    ┌────┴────┬──────────┬───────────┐
    │         │          │           │
┌───▼───┐ ┌──▼──┐  ┌────▼────┐ ┌───▼────┐
│TFLite │ │MLKit│  │OpenAI   │ │Vector  │
│Adapter│ │Adapter│ │Adapter  │ │Store   │
└───────┘ └─────┘  └─────────┘ └────────┘
```

### Inference Policies

Control when to use on-device vs. cloud:

```dart
enum InferencePolicy {
  preferOnDevice,   // Try on-device first, fallback to cloud
  preferCloud,      // Try cloud first, fallback to on-device
  onDeviceOnly,     // Only use on-device (throws if unavailable)
  cloudOnly,        // Only use cloud (throws if unavailable)
}
```

## 🎨 Models

### Recommended Models

| Task | Model | Size | Device Profile | Quantized |
|------|-------|------|----------------|-----------|
| Image Classification | MobileNet V2 | 3.5 MB | Low/Medium | Yes (int8) |
| Image Classification | MobileNet V2 | 14 MB | Medium/High | No |
| Text Embedding | USE Lite | 50 MB | Medium | No |
| OCR | ML Kit | On-demand | Medium | N/A |
| Object Detection | ML Kit | On-demand | Medium | N/A |

See `lib/features/ai_ml/assets/models/manifest.json` for full model catalog.

### Model Management

```dart
// Download a model
await aiMl.downloadAndInstallModel('mobilenet_v2_1.0_224_quantized');

// Get model info
final info = await aiMl.getModelInfo('mobilenet_v2_1.0_224_quantized');
print('Size: ${info.sizeFormatted}');
print('Framework: ${info.framework}');
```

## 🔐 Security & Privacy

### On-Device Inference
- All data stays on device
- No network calls required
- Works offline
- GDPR/CCPA compliant by default

### Cloud Inference
- Use HTTPS for all API calls
- Store API keys in `flutter_secure_storage`
- Implement token rotation
- Avoid sending PII to third-party LLMs

### Vector Store Encryption
```dart
// Optional: Use encrypted Hive or SQLCipher
// See SECURITY.md for details
```

## ⚡ Performance Tips

### 1. Use Quantized Models
- 3-4x smaller size
- 2-3x faster inference
- ~1-2% accuracy loss

### 2. Enable GPU Delegates
```dart
TfliteImageClassificationAdapter(
  useGpuDelegate: true, // 2-5x speedup
  // ...
);
```

### 3. Batch Operations
```dart
final embeddings = await embeddingAdapter.embedBatch(texts);
```

### 4. Lazy Initialization
Initialize adapters only when needed:

```dart
if (!adapter.isInitialized) {
  await adapter.initialize();
}
```

## 🧪 Testing

See `test/features/ai_ml/` for comprehensive unit and integration tests.

```bash
# Run all AI/ML tests
flutter test test/features/ai_ml/

# Run specific test
flutter test test/features/ai_ml/unit/vector_store_test.dart
```

## 🤝 Contributing

This module is part of the reusable widgets library. Follow the project's contribution guidelines.

## 📄 License

See the main project LICENSE file.

## 🙏 Acknowledgments

- TensorFlow Lite team
- Google ML Kit team
- Flutter team
- Open source model contributors

## 📞 Support

For issues and questions:
1. Check the documentation
2. Review examples
3. Open an issue in the main repository

---

**Made with ❤️ for Flutter developers**
