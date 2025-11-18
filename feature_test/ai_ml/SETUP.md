# Setup Guide

Complete guide to setting up the AI/ML module from scratch.

## Table of Contents

- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Model Setup](#model-setup)
- [API Keys Configuration](#api-keys-configuration)
- [Platform Configuration](#platform-configuration)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

Get up and running in 5 minutes:

```bash
# 1. Navigate to the module
cd feature_test/ai_ml

# 2. Install dependencies
flutter pub get

# 3. Run the demo app
flutter run
```

That's it! The demo app will launch with examples of all features.

---

## Detailed Setup

### Step 1: System Requirements

Verify you have the required tools:

```bash
# Check Flutter version
flutter --version
# Required: Flutter >=3.4.1

# Check Dart version
dart --version
# Required: Dart >=3.4.1

# Verify Flutter doctor
flutter doctor
# Ensure no critical issues
```

### Step 2: Clone or Copy Module

If you haven't already:

```bash
# Clone the entire repository
git clone <repository-url>
cd expensize/feature_test/ai_ml

# OR copy just the ai_ml module
cp -r /path/to/ai_ml /your/project/location
```

### Step 3: Install Dependencies

```bash
cd feature_test/ai_ml
flutter pub get
```

This installs:
- `tflite_flutter` - TensorFlow Lite runtime
- `google_mlkit_object_detection` - Object detection
- `google_mlkit_text_recognition` - OCR
- `http` - HTTP client for API calls
- `sqflite` - SQLite for vector store
- `path_provider` - File system access
- `image` - Image processing
- `image_picker` - Image selection
- `crypto` - Cryptographic operations

---

## Model Setup

### Option 1: Use ML Kit Models (No Setup Needed)

ML Kit models download automatically on first use:

```dart
// OCR - downloads automatically
final ocrAdapter = MlKitOcrAdapter(
  modelInfo: ModelInfo(
    id: 'mlkit_ocr',
    name: 'ML Kit OCR',
    sizeBytes: 0,
    framework: 'mlkit',
  ),
);
await ocrAdapter.initialize();
```

### Option 2: Use TFLite Models (Manual Setup)

#### Download Pre-trained Models

**Image Classification (MobileNet V2):**
```bash
# Create models directory
mkdir -p assets/models

# Download MobileNet V2 quantized
wget https://storage.googleapis.com/download.tensorflow.org/models/tflite/mobilenet_v2_1.0_224_quantized_1_metadata_1.tflite \
  -O assets/models/mobilenet_v2.tflite

# Download ImageNet labels
wget https://storage.googleapis.com/download.tensorflow.org/models/tflite/mobilenet_v1_1.0_224_quant_and_labels.zip
unzip mobilenet_v1_1.0_224_quant_and_labels.zip
mv labels_mobilenet_quant_v1_224.txt assets/models/labels.txt
```

**Text Embeddings (Universal Sentence Encoder):**
```bash
# Download USE Lite
wget https://tfhub.dev/google/lite-model/universal-sentence-encoder-qa-ondevice/1?lite-format=tflite \
  -O assets/models/use_qa.tflite
```

#### Add Models to pubspec.yaml

```yaml
flutter:
  assets:
    - assets/models/mobilenet_v2.tflite
    - assets/models/labels.txt
    - assets/models/use_qa.tflite
```

#### Load Models in Code

```dart
// Image classification with custom model
final imageClassifier = TfliteImageClassificationAdapter(
  modelInfo: ModelInfo(
    id: 'mobilenet_v2',
    name: 'MobileNet V2',
    sizeBytes: 3500000,
    framework: 'tflite',
    quantized: true,
    quantizationType: 'int8',
  ),
  labels: await _loadLabels(),
  inputSize: 224,
  useGpuDelegate: true,
);

Future<List<String>> _loadLabels() async {
  final data = await rootBundle.loadString('assets/models/labels.txt');
  return data.split('\n').where((line) => line.isNotEmpty).toList();
}
```

### Option 3: Use Custom Models

Place your `.tflite` model in `assets/models/` and configure:

```dart
final customAdapter = TfliteImageClassificationAdapter(
  modelInfo: ModelInfo(
    id: 'my_custom_model',
    name: 'My Custom Model',
    sizeBytes: 5000000,
    framework: 'tflite',
  ),
  labels: ['class1', 'class2', 'class3'],
  inputSize: 224,  // Match your model's input size
);
```

---

## API Keys Configuration

### OpenAI Setup

#### 1. Get API Key

1. Go to [platform.openai.com](https://platform.openai.com)
2. Sign up or log in
3. Navigate to API Keys
4. Create new secret key
5. Copy the key (starts with `sk-`)

#### 2. Configure in Code

**Option A: Environment Variables (Recommended for Production)**

```bash
# .env file (add to .gitignore!)
OPENAI_API_KEY=sk-your-key-here
```

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load();

final config = AiMlConfig(
  apiKeys: {
    'openai': dotenv.env['OPENAI_API_KEY'] ?? '',
  },
);
```

**Option B: Secure Storage (Recommended for Mobile)**

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// Store key (once, maybe in settings screen)
await storage.write(key: 'openai_api_key', value: 'sk-your-key');

// Load key
final apiKey = await storage.read(key: 'openai_api_key');

final config = AiMlConfig(
  apiKeys: {'openai': apiKey ?? ''},
);
```

**Option C: Direct (Only for Testing)**

```dart
final config = AiMlConfig(
  apiKeys: {
    'openai': 'sk-your-key-here',  // NEVER commit this to git!
  },
);
```

### Future Providers

When adding support for other providers:

```dart
final config = AiMlConfig(
  apiKeys: {
    'openai': 'sk-...',
    'anthropic': 'sk-ant-...',
    'vertex_ai': 'ya29...',
  },
);
```

---

## Platform Configuration

### Android Configuration

#### 1. Update build.gradle

```gradle
// android/app/build.gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.yourapp.id"
        minSdkVersion 21  // Required
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"

        multiDexEnabled true  // For ML Kit
    }

    // Prevent compression of TFLite models
    aaptOptions {
        noCompress "tflite"
    }

    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    implementation 'com.android.support:multidex:1.0.3'

    // Optional: TFLite GPU delegate for better performance
    implementation 'org.tensorflow:tensorflow-lite-gpu:2.9.0'
}
```

#### 2. ProGuard Rules (if minifying)

```proguard
# android/app/proguard-rules.pro

# TFLite
-keep class org.tensorflow.** { *; }
-keep class org.tensorflow.lite.** { *; }

# ML Kit
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
```

#### 3. Permissions

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- For camera features -->
    <uses-permission android:name="android.permission.CAMERA" />

    <!-- For internet (cloud LLM) -->
    <uses-permission android:name="android.permission.INTERNET" />

    <!-- For file access -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
                     android:maxSdkVersion="28" />

    <!-- Camera hardware (optional, not required) -->
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
</manifest>
```

---

### iOS Configuration

#### 1. Update Podfile

```ruby
# ios/Podfile
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    target.build_configurations.each do |config|
      # Disable Bitcode (required for TFLite)
      config.build_settings['ENABLE_BITCODE'] = 'NO'

      # Set minimum iOS version
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

#### 2. Install Pods

```bash
cd ios
pod install
cd ..
```

#### 3. Update Info.plist

```xml
<!-- ios/Runner/Info.plist -->
<dict>
    <!-- Camera access -->
    <key>NSCameraUsageDescription</key>
    <string>We need camera access to scan documents and recognize objects</string>

    <!-- Photo library access -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>We need photo library access to classify and analyze images</string>

    <!-- Photo library add (if saving processed images) -->
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>We need permission to save processed images</string>
</dict>
```

---

### Web Configuration

Limited support for web platform:

#### What Works:
- ✅ Cloud LLM chat (OpenAI, etc.)
- ✅ Vector store operations
- ✅ HTTP-based operations

#### What Doesn't Work:
- ❌ TFLite models
- ❌ ML Kit features
- ❌ On-device inference

#### Web Setup:

```dart
import 'package:flutter/foundation.dart';

final config = kIsWeb
    ? AiMlConfig(
        inferencePolicy: InferencePolicy.cloudOnly,
        apiKeys: {'openai': apiKey},
      )
    : AiMlConfig(
        inferencePolicy: InferencePolicy.preferOnDevice,
        apiKeys: {'openai': apiKey},
      );
```

---

## Verification

### 1. Run Tests

```bash
flutter test
```

Expected output:
```
✓ Image classification adapter test
✓ OCR adapter test
✓ Vector store test
✓ Chat session test
All tests passed!
```

### 2. Run Demo App

```bash
flutter run
```

Navigate through tabs:
- **Overview**: See module capabilities
- **Features**: Browse feature documentation
- **Architecture**: View system design
- **Logs**: Monitor operations

### 3. Test Features

#### Test Image Classification:
```dart
// Use demo app or write quick test
import 'package:ai_ml/ai_ml.dart';

void testImageClassification() async {
  final aiMl = AiMlManager(
    config: AiMlConfig(enableLogging: true),
  );
  await aiMl.initialize(AiMlConfig());

  // Register adapter
  final adapter = TfliteImageClassificationAdapter(...);
  await adapter.initialize();
  aiMl.registerAdapter('classifier', adapter);

  // Test
  final result = await aiMl.classifyImage(testImage);
  print('Success: ${result.labels.length} labels found');
}
```

#### Test OCR:
```dart
void testOcr() async {
  final aiMl = AiMlManager(
    config: AiMlConfig(enableLogging: true),
  );
  await aiMl.initialize(AiMlConfig());

  final adapter = MlKitOcrAdapter(
    modelInfo: ModelInfo(
      id: 'mlkit_ocr',
      name: 'ML Kit OCR',
      sizeBytes: 0,
      framework: 'mlkit',
    ),
  );
  await adapter.initialize();
  aiMl.registerAdapter('ocr', adapter);

  final result = await aiMl.runOcr(testImage);
  print('Success: ${result.text.length} characters extracted');
}
```

#### Test Chat (requires API key):
```dart
void testChat() async {
  final aiMl = AiMlManager(
    config: AiMlConfig(
      apiKeys: {'openai': 'sk-your-key'},
      enableLogging: true,
    ),
  );
  await aiMl.initialize(AiMlConfig(apiKeys: {'openai': 'sk-your-key'}));

  final adapter = OpenAiChatAdapter(
    apiKey: 'sk-your-key',
    model: 'gpt-3.5-turbo',
  );
  await adapter.initialize();
  aiMl.registerChatAdapter('openai', adapter);

  final session = aiMl.createChatSession(
    config: ChatSessionConfig(backend: ModelProvider.openai),
  );

  final response = await aiMl.chatGenerate(session, 'Hello!');
  print('Success: ${response.text}');
}
```

---

## Troubleshooting

### Common Issues

#### 1. "Failed to load model"

**Cause**: Model file not found or not added to assets.

**Solution**:
```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/models/your_model.tflite
```

Then run:
```bash
flutter clean
flutter pub get
```

---

#### 2. "Minimum SDK version error" (Android)

**Error**: `Manifest merger failed : uses-sdk:minSdkVersion 16 cannot be smaller than version 21`

**Solution**:
```gradle
// android/app/build.gradle
android {
    defaultConfig {
        minSdkVersion 21  // Change from 16 to 21
    }
}
```

---

#### 3. "GPU delegate failed to initialize"

**Cause**: Device doesn't support GPU delegate or not configured.

**Solution**: Disable GPU delegate:
```dart
TfliteImageClassificationAdapter(
  // ...
  useGpuDelegate: false,  // Set to false
);
```

Or add dependency:
```gradle
// android/app/build.gradle
dependencies {
    implementation 'org.tensorflow:tensorflow-lite-gpu:2.9.0'
}
```

---

#### 4. "API key invalid" (OpenAI)

**Error**: `401 Unauthorized` or `Invalid API key`

**Solution**:
1. Verify key starts with `sk-`
2. Check key is active at platform.openai.com
3. Ensure billing is set up (OpenAI requires it)
4. Test key with curl:
```bash
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer sk-your-key"
```

---

#### 5. "ML Kit model download failed"

**Error**: `Failed to download model`

**Solution**:
1. Ensure device has internet connection
2. Check Google Play Services is up to date (Android)
3. Try manual initialization:
```dart
final options = TextRecognizerOptions();
final textRecognizer = TextRecognizer(options: options);

// This triggers download if needed
await textRecognizer.processImage(testImage);
```

---

#### 6. "Vector store initialization failed"

**Error**: `DatabaseException: unable to open database file`

**Solution**:
```dart
// Ensure path_provider can access app directory
import 'package:path_provider/path_provider.dart';

final appDir = await getApplicationDocumentsDirectory();
print('App directory: ${appDir.path}');

// Initialize vector store with explicit path
final vectorStore = SqliteVectorStore(
  dbName: 'vectors',
  embeddingGenerator: generator,
);
await vectorStore.initialize();
```

---

#### 7. iOS build fails with "Undefined symbols"

**Solution**:
```bash
# Clean iOS build
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# Clean Flutter build
flutter clean
flutter pub get

# Rebuild
flutter run
```

---

#### 8. "Out of memory" on device

**Cause**: Large model or multiple models loaded.

**Solution**:
1. Use quantized models (INT8)
2. Dispose unused adapters:
```dart
await adapter.dispose();
```
3. Don't keep multiple models in memory
4. Use model manager for lazy loading

---

### Debug Logging

Enable detailed logging:

```dart
final aiMl = AiMlManager(
  config: AiMlConfig(enableLogging: true),
  logger: ConsoleLogger(enabled: true),
);
```

Check logs for:
- Initialization steps
- Model loading
- Inference timing
- Error stack traces

---

### Performance Issues

If inference is slow:

1. **Enable GPU delegate** (if supported):
```dart
TfliteImageClassificationAdapter(
  useGpuDelegate: true,
);
```

2. **Use quantized models**:
- INT8 quantization: 4x smaller, 2-3x faster
- Download quantized versions of models

3. **Profile performance**:
```dart
final stopwatch = Stopwatch()..start();
final result = await aiMl.classifyImage(image);
print('Inference time: ${stopwatch.elapsedMilliseconds}ms');
```

4. **Check image size**:
```dart
// Resize large images before processing
import 'package:image/image.dart' as img;

final image = img.decodeImage(imageBytes)!;
final resized = img.copyResize(image, width: 224);
```

---

## Setup Checklist

- [ ] Flutter SDK >=3.4.1 installed
- [ ] Run `flutter doctor` with no critical issues
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Models downloaded and added to assets (if using TFLite)
- [ ] Models listed in pubspec.yaml
- [ ] API keys configured (if using cloud features)
- [ ] Android minSdkVersion set to 21+
- [ ] iOS deployment target set to 12.0+
- [ ] Permissions added to AndroidManifest.xml
- [ ] Usage descriptions added to Info.plist
- [ ] Tests pass (`flutter test`)
- [ ] Demo app runs (`flutter run`)
- [ ] Features verified (image classification, OCR, chat, etc.)

---

## Next Steps

1. ✅ Complete setup (you're here)
2. 📖 Read [FEATURES.md](./FEATURES.md) for capabilities
3. 🔧 Read [INTEGRATION.md](./INTEGRATION.md) for integration guide
4. 💻 Check [example_main.dart](./lib/ai_ml/examples/example_main.dart) for code examples
5. 🚀 Start building your AI-powered app!

---

## Getting Help

If you encounter issues not covered here:

1. Check the [README.md](./README.md) for overview
2. Review example code in `/lib/ai_ml/examples/`
3. Enable debug logging for detailed error messages
4. Check Flutter/Dart versions match requirements
5. Open an issue in the repository

---

**Setup complete! You're ready to build AI-powered features.**
