# Integration Guide

How to integrate the AI/ML module into any Flutter application.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Basic Integration](#basic-integration)
- [Advanced Integration](#advanced-integration)
- [Platform-Specific Setup](#platform-specific-setup)
- [Best Practices](#best-practices)
- [Migration Guide](#migration-guide)

---

## Prerequisites

### Required Dependencies

Your Flutter project needs:
- **Flutter SDK**: >=3.4.1 <4.0.0
- **Dart SDK**: >=3.4.1
- **Android**: minSdkVersion 21 (Android 5.0) or higher
- **iOS**: iOS 12.0 or higher

### Optional Requirements

Depending on features used:
- **OpenAI API Key**: For cloud LLM features
- **TFLite Models**: `.tflite` model files for on-device ML
- **Internet Connection**: For cloud features (optional for on-device)

---

## Installation

### Step 1: Copy Module to Your Project

Copy the entire `ai_ml` directory into your project:

```bash
# If using as a package
cp -r feature_test/ai_ml /path/to/your/project/packages/ai_ml

# OR include in your lib directory
cp -r feature_test/ai_ml/lib/ai_ml /path/to/your/project/lib/
```

### Step 2: Add Dependencies

Add to your `pubspec.yaml`:

#### Option A: As a local package

```yaml
dependencies:
  ai_ml:
    path: ./packages/ai_ml
```

#### Option B: Inline (copy to lib/)

```yaml
dependencies:
  # ML/AI Dependencies
  tflite_flutter: ^0.11.0
  google_mlkit_object_detection: ^0.12.0
  google_mlkit_text_recognition: ^0.13.1
  http: ^1.2.2

  # Storage
  sqflite: ^2.4.0
  path_provider: ^2.1.5
  path: ^1.9.0

  # Image handling
  image: ^4.3.0
  image_picker: ^1.1.2

  # Utils
  crypto: ^3.0.5
```

### Step 3: Install Dependencies

```bash
flutter pub get
```

---

## Project Structure

### Recommended Structure

```
your_app/
├── lib/
│   ├── main.dart
│   ├── services/
│   │   └── ai_service.dart          # Wrapper for your app
│   ├── screens/
│   │   ├── image_classifier_screen.dart
│   │   ├── chat_screen.dart
│   │   └── ocr_scanner_screen.dart
│   └── models/
│       └── app_specific_models.dart
├── packages/                         # If using as package
│   └── ai_ml/
├── assets/
│   └── models/                       # TFLite models
│       ├── mobilenet_v2.tflite
│       └── labels.txt
└── pubspec.yaml
```

---

## Basic Integration

### Minimal Integration (5 minutes)

Create a simple wrapper service in your app:

```dart
// lib/services/ai_service.dart
import 'package:ai_ml/ai_ml.dart';

class AppAiService {
  static final AppAiService _instance = AppAiService._internal();
  factory AppAiService() => _instance;
  AppAiService._internal();

  late AiMlManager _aiMl;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    final config = AiMlConfig(
      inferencePolicy: InferencePolicy.preferOnDevice,
      enableLogging: true,
    );

    _aiMl = AiMlManager(
      config: config,
      logger: const ConsoleLogger(enabled: true),
    );

    await _aiMl.initialize(config);
    _initialized = true;
  }

  AiMlManager get manager => _aiMl;
}
```

### Initialize in main.dart

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'services/ai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AI service
  await AppAiService().initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App with AI',
      home: HomeScreen(),
    );
  }
}
```

### Use in Screens

```dart
// lib/screens/image_classifier_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ai_service.dart';

class ImageClassifierScreen extends StatefulWidget {
  @override
  _ImageClassifierScreenState createState() => _ImageClassifierScreenState();
}

class _ImageClassifierScreenState extends State<ImageClassifierScreen> {
  final _aiService = AppAiService();
  String _result = '';

  Future<void> _classifyImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    try {
      final result = await _aiService.manager.classifyImage(
        File(image.path),
        threshold: 0.1,
      );

      setState(() {
        _result = result.labels
            .take(5)
            .map((l) => '${l.label}: ${(l.score * 100).toStringAsFixed(1)}%')
            .join('\n');
      });
    } catch (e) {
      setState(() => _result = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Classifier')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _classifyImage,
            child: Text('Pick & Classify Image'),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(_result),
          ),
        ],
      ),
    );
  }
}
```

---

## Advanced Integration

### Full-Featured Integration

Create a comprehensive AI service with all features:

```dart
// lib/services/ai_service.dart
import 'dart:io';
import 'package:ai_ml/ai_ml.dart';
import 'package:flutter/services.dart';

class AppAiService {
  static final AppAiService _instance = AppAiService._internal();
  factory AppAiService() => _instance;
  AppAiService._internal();

  late AiMlManager _aiMl;
  late SqliteVectorStore _vectorStore;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // 1. Create configuration
    final config = AiMlConfig(
      inferencePolicy: InferencePolicy.preferOnDevice,
      enableLogging: true,
      apiKeys: {
        'openai': await _getApiKey('OPENAI_API_KEY'),
      },
    );

    // 2. Initialize manager
    _aiMl = AiMlManager(
      config: config,
      logger: const ConsoleLogger(enabled: true),
    );
    await _aiMl.initialize(config);

    // 3. Register adapters
    await _registerAdapters();

    // 4. Setup vector store
    await _setupVectorStore();

    _initialized = true;
  }

  Future<void> _registerAdapters() async {
    // Image classification
    final imageClassifier = TfliteImageClassificationAdapter(
      modelInfo: ModelInfo(
        id: 'mobilenet_v2',
        name: 'MobileNet V2',
        sizeBytes: 3500000,
        framework: 'tflite',
      ),
      labels: await _loadLabels('assets/models/labels.txt'),
      inputSize: 224,
      useGpuDelegate: true,
    );
    await imageClassifier.initialize();
    _aiMl.registerAdapter('image_classifier', imageClassifier);

    // OCR
    final ocrAdapter = MlKitOcrAdapter(
      modelInfo: ModelInfo(
        id: 'mlkit_ocr',
        name: 'ML Kit OCR',
        sizeBytes: 0,
        framework: 'mlkit',
      ),
    );
    await ocrAdapter.initialize();
    _aiMl.registerAdapter('ocr', ocrAdapter);

    // Object detection
    final objectDetector = MlKitObjectDetectionAdapter(
      modelInfo: ModelInfo(
        id: 'mlkit_object_detection',
        name: 'ML Kit Object Detection',
        sizeBytes: 0,
        framework: 'mlkit',
      ),
    );
    await objectDetector.initialize();
    _aiMl.registerAdapter('object_detector', objectDetector);

    // Text embeddings
    final embeddingAdapter = TfliteTextEmbeddingAdapter(
      modelInfo: ModelInfo(
        id: 'text_embedder',
        name: 'Universal Sentence Encoder',
        sizeBytes: 50000000,
        framework: 'tflite',
      ),
    );
    await embeddingAdapter.initialize();
    _aiMl.registerAdapter('embedder', embeddingAdapter);

    // OpenAI chat
    final openAiKey = config.apiKeys?['openai'];
    if (openAiKey != null && openAiKey.isNotEmpty) {
      final openAiAdapter = OpenAiChatAdapter(
        apiKey: openAiKey,
        model: 'gpt-3.5-turbo',
      );
      await openAiAdapter.initialize();
      _aiMl.registerChatAdapter('openai', openAiAdapter);
    }
  }

  Future<void> _setupVectorStore() async {
    _vectorStore = SqliteVectorStore(
      dbName: 'app_knowledge_base',
      embeddingGenerator: _TextEmbeddingGeneratorAdapter(_aiMl),
    );
    await _vectorStore.initialize();
    _aiMl.registerVectorStore('knowledge', _vectorStore);
  }

  Future<String> _getApiKey(String key) async {
    // Load from environment, secure storage, or config
    // For demo, return empty string
    return '';
  }

  Future<List<String>> _loadLabels(String path) async {
    final data = await rootBundle.loadString(path);
    return data.split('\n').where((line) => line.isNotEmpty).toList();
  }

  // Convenient methods for your app

  Future<ImageClassificationResult> classifyImage(File image) {
    return _aiMl.classifyImage(image, threshold: 0.1);
  }

  Future<OcrResult> scanText(File image) {
    return _aiMl.runOcr(image);
  }

  Future<List<DetectedObject>> detectObjects(File image) {
    return _aiMl.detectObjects(image, threshold: 0.5);
  }

  ChatSession createChatWithKnowledge({
    String systemPrompt = 'You are a helpful assistant.',
  }) {
    return _aiMl.createChatSession(
      config: ChatSessionConfig(
        backend: ModelProvider.openai,
        systemPrompt: systemPrompt,
        retrieval: RetrievalConfig(
          vectorStoreId: 'knowledge',
          topK: 3,
          minSimilarity: 0.7,
        ),
        temperature: 0.7,
        maxTokens: 500,
      ),
    );
  }

  Future<ChatResponse> chat(ChatSession session, String message) {
    return _aiMl.chatGenerate(session, message);
  }

  Future<void> addKnowledge(String id, String text, Map<String, dynamic>? metadata) {
    return _vectorStore.addDocument(id, text, metadata: metadata);
  }

  Future<List<ScoredDocument>> searchKnowledge(String query) {
    return _vectorStore.query(query, topK: 5, minSimilarity: 0.6);
  }

  Future<void> dispose() async {
    await _aiMl.dispose();
    _initialized = false;
  }

  AiMlManager get manager => _aiMl;
  bool get isInitialized => _initialized;
}

class _TextEmbeddingGeneratorAdapter implements TextEmbeddingGenerator {
  final AiMlManager aiMl;
  _TextEmbeddingGeneratorAdapter(this.aiMl);

  @override
  Future<TextEmbedding> generate(String text) {
    return aiMl.embedText(text, modelId: 'embedder');
  }
}
```

---

## Platform-Specific Setup

### Android Setup

#### 1. Update `android/app/build.gradle`

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        minSdkVersion 21  // Required for TFLite
        targetSdkVersion 34

        // For ML Kit
        multiDexEnabled true
    }

    // For TFLite GPU delegate
    aaptOptions {
        noCompress "tflite"
    }
}

dependencies {
    // For TFLite GPU (optional)
    implementation 'org.tensorflow:tensorflow-lite-gpu:2.9.0'
}
```

#### 2. Add Permissions (if needed)

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
    <!-- For camera access (OCR, object detection) -->
    <uses-permission android:name="android.permission.CAMERA" />

    <!-- For internet (cloud LLM) -->
    <uses-permission android:name="android.permission.INTERNET" />

    <!-- For file access -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
</manifest>
```

---

### iOS Setup

#### 1. Update `ios/Podfile`

```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

  # Uncomment for specific ML Kit features
  # pod 'GoogleMLKit/TextRecognition'
  # pod 'GoogleMLKit/ObjectDetection'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    # For TFLite GPU delegate
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
```

#### 2. Update `ios/Runner/Info.plist`

```xml
<dict>
    <!-- For camera access -->
    <key>NSCameraUsageDescription</key>
    <string>We need camera access to scan documents and recognize objects</string>

    <!-- For photo library access -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>We need photo library access to classify images</string>
</dict>
```

---

### Web Setup (Limited Support)

Some features work on web:
- ✅ Cloud LLM chat
- ✅ Vector store operations
- ❌ TFLite models (not supported)
- ❌ ML Kit (not supported)

For web apps, use `InferencePolicy.cloudOnly`:

```dart
final config = AiMlConfig(
  inferencePolicy: InferencePolicy.cloudOnly,
  apiKeys: {'openai': 'your-key'},
);
```

---

## Best Practices

### 1. Lazy Initialization

Don't initialize everything at app startup:

```dart
class AppAiService {
  Future<void> initializeImageClassification() async {
    if (_imageClassifierReady) return;
    // Register only image classification adapter
    await _registerImageClassifier();
    _imageClassifierReady = true;
  }

  Future<void> initializeChat() async {
    if (_chatReady) return;
    // Register only chat adapter
    await _registerChatAdapter();
    _chatReady = true;
  }
}
```

### 2. Error Handling

Always handle errors gracefully:

```dart
Future<void> classifyImage(File image) async {
  try {
    final result = await _aiMl.classifyImage(image);
    // Handle success
  } on ModelNotFoundException catch (e) {
    // Prompt user to download model
    showDialog(...);
  } on InitializationException catch (e) {
    // Re-initialize or show error
    await _aiService.initialize();
  } catch (e) {
    // Generic error
    showSnackbar('An error occurred: $e');
  }
}
```

### 3. Resource Management

Dispose resources when done:

```dart
class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  late ChatSession _session;

  @override
  void initState() {
    super.initState();
    _session = AppAiService().createChatWithKnowledge();
  }

  @override
  void dispose() {
    AppAiService().manager.closeChatSession(_session);
    super.dispose();
  }
}
```

### 4. Progress Indicators

Show progress for long operations:

```dart
Future<void> processImage(File image) async {
  setState(() => _isLoading = true);

  try {
    final result = await _aiService.classifyImage(image);
    // Handle result
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### 5. Caching Results

Cache expensive operations:

```dart
class AppAiService {
  final Map<String, ImageClassificationResult> _imageCache = {};

  Future<ImageClassificationResult> classifyImage(File image) async {
    final cacheKey = image.path;

    if (_imageCache.containsKey(cacheKey)) {
      return _imageCache[cacheKey]!;
    }

    final result = await _aiMl.classifyImage(image);
    _imageCache[cacheKey] = result;

    return result;
  }
}
```

### 6. Environment Configuration

Use different configs for dev/prod:

```dart
class AppConfig {
  static AiMlConfig getAiConfig() {
    if (kDebugMode) {
      return AiMlConfig(
        inferencePolicy: InferencePolicy.preferOnDevice,
        enableLogging: true,
      );
    } else {
      return AiMlConfig(
        inferencePolicy: InferencePolicy.preferCloud,
        enableLogging: false,
      );
    }
  }
}
```

---

## Migration Guide

### From Direct TFLite Usage

**Before:**
```dart
import 'package:tflite_flutter/tflite_flutter.dart';

final interpreter = await Interpreter.fromAsset('model.tflite');
final output = List.filled(1 * 1000, 0).reshape([1, 1000]);
interpreter.run(input, output);
```

**After:**
```dart
import 'package:ai_ml/ai_ml.dart';

final result = await aiMl.classifyImage(imageFile);
// Simplified API, automatic preprocessing
```

### From Direct ML Kit Usage

**Before:**
```dart
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

final textRecognizer = TextRecognizer();
final inputImage = InputImage.fromFile(file);
final recognizedText = await textRecognizer.processImage(inputImage);
await textRecognizer.close();
```

**After:**
```dart
import 'package:ai_ml/ai_ml.dart';

final result = await aiMl.runOcr(imageFile);
// Automatic lifecycle management
```

### From Direct OpenAI SDK

**Before:**
```dart
import 'package:openai_dart/openai_dart.dart';

final client = OpenAIClient(apiKey: 'key');
final response = await client.createChatCompletion(...);
```

**After:**
```dart
import 'package:ai_ml/ai_ml.dart';

final session = aiMl.createChatSession(...);
final response = await aiMl.chatGenerate(session, message);
// Added: RAG, session management, vector store
```

---

## Integration Checklist

- [ ] Copy ai_ml module to your project
- [ ] Add dependencies to pubspec.yaml
- [ ] Run `flutter pub get`
- [ ] Create AppAiService wrapper
- [ ] Initialize in main.dart
- [ ] Setup platform-specific configs (Android/iOS)
- [ ] Add required permissions
- [ ] Add model files to assets (if using TFLite)
- [ ] Update pubspec.yaml assets section
- [ ] Test initialization
- [ ] Implement error handling
- [ ] Add loading indicators
- [ ] Test on target platforms

---

## Support

For integration issues:
1. Check the [SETUP.md](./SETUP.md) for configuration details
2. Review [FEATURES.md](./FEATURES.md) for feature documentation
3. See example implementations in `/lib/main.dart` and `/lib/ai_ml/examples/`
4. Open an issue in the repository with integration questions

---

**Ready to integrate AI/ML into your app!**
