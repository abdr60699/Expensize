<!-- AUTO_FILE_HEADER -->

# AI/ML Module - Security & Privacy Guide

This document outlines security and privacy best practices for the AI/ML module.

## Table of Contents

1. [Privacy-First Design](#privacy-first-design)
2. [Data Protection](#data-protection)
3. [API Key Management](#api-key-management)
4. [Cloud LLM Security](#cloud-llm-security)
5. [Model Security](#model-security)
6. [Compliance (GDPR/CCPA)](#compliance-gdprccpa)
7. [User Consent](#user-consent)
8. [Data Retention](#data-retention)
9. [Security Checklist](#security-checklist)

## Privacy-First Design

### On-Device Inference

The module prioritizes on-device inference to maximize privacy:

```dart
final config = AiMlConfig(
  inferencePolicy: InferencePolicy.onDeviceOnly,
);
```

**Benefits:**
- ✅ Data never leaves the device
- ✅ Works offline
- ✅ No tracking or telemetry
- ✅ GDPR/CCPA compliant by default
- ✅ Lower latency

**Limitations:**
- ❌ Limited by device capabilities
- ❌ Model size constraints
- ❌ May require model downloads

### Hybrid Approach

For enhanced functionality, use a hybrid approach with user consent:

```dart
// Ask user preference
final userConsent = await _requestCloudInferenceConsent();

final config = AiMlConfig(
  inferencePolicy: userConsent
    ? InferencePolicy.preferCloud
    : InferencePolicy.onDeviceOnly,
);
```

## Data Protection

### 1. Encrypted Vector Store

Encrypt sensitive data in the vector store:

```dart
// Option 1: Use encrypted SQLite (SQLCipher)
// Add dependency: sqflite_sqlcipher: ^2.2.0

import 'package:sqflite_sqlcipher/sqflite.dart';

class EncryptedVectorStore extends SqliteVectorStore {
  final String encryptionKey;

  EncryptedVectorStore({
    required super.dbName,
    required this.encryptionKey,
    super.embeddingGenerator,
  });

  @override
  Future<void> initialize() async {
    if (_database != null) return;

    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, '$dbName.db');

    // Open with encryption
    _database = await openDatabase(
      fullPath,
      version: 1,
      password: encryptionKey, // SQLCipher encryption
      onCreate: (db, version) async {
        // Create tables...
      },
    );
  }
}

// Usage
final encryptionKey = await _getOrGenerateEncryptionKey();
final vectorStore = EncryptedVectorStore(
  dbName: 'secure_docs',
  encryptionKey: encryptionKey,
  embeddingGenerator: embeddingAdapter,
);
```

### 2. Secure Key Storage

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyManager {
  static const _storage = FlutterSecureStorage();

  /// Generates and stores a new encryption key
  static Future<String> getOrGenerateEncryptionKey() async {
    String? key = await _storage.read(key: 'vector_store_key');

    if (key == null) {
      // Generate a new 256-bit key
      final random = Random.secure();
      final bytes = List<int>.generate(32, (_) => random.nextInt(256));
      key = base64Encode(bytes);
      await _storage.write(key: 'vector_store_key', value: key);
    }

    return key;
  }

  /// Deletes the encryption key (user logout/data wipe)
  static Future<void> deleteEncryptionKey() async {
    await _storage.delete(key: 'vector_store_key');
  }
}
```

### 3. Data Sanitization

Remove PII before processing:

```dart
class DataSanitizer {
  /// Removes emails, phone numbers, SSNs from text
  static String sanitize(String text) {
    var sanitized = text;

    // Remove emails
    sanitized = sanitized.replaceAll(
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
      '[EMAIL]',
    );

    // Remove phone numbers
    sanitized = sanitized.replaceAll(
      RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'),
      '[PHONE]',
    );

    // Remove SSNs
    sanitized = sanitized.replaceAll(
      RegExp(r'\b\d{3}-\d{2}-\d{4}\b'),
      '[SSN]',
    );

    // Remove credit card numbers
    sanitized = sanitized.replaceAll(
      RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'),
      '[CARD]',
    );

    return sanitized;
  }
}

// Usage before cloud inference
Future<ChatResponse> chatWithSanitization(String message) async {
  final sanitized = DataSanitizer.sanitize(message);
  return await aiMl.chatGenerate(session, sanitized);
}
```

## API Key Management

### 1. Secure Storage

**Never hardcode API keys in source code.**

```dart
// ❌ BAD
final apiKey = 'sk-1234567890abcdef';

// ✅ GOOD
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiKeyManager {
  static const _storage = FlutterSecureStorage();

  static Future<void> storeApiKey(String service, String apiKey) async {
    await _storage.write(
      key: '${service}_api_key',
      value: apiKey,
    );
  }

  static Future<String?> getApiKey(String service) async {
    return await _storage.read(key: '${service}_api_key');
  }

  static Future<void> deleteApiKey(String service) async {
    await _storage.delete(key: '${service}_api_key');
  }
}
```

### 2. Key Rotation

Implement periodic key rotation:

```dart
class ApiKeyRotation {
  static const _keyAgeKey = 'api_key_created_at';
  static const _rotationPeriod = Duration(days: 90);

  static Future<bool> shouldRotateKey(String service) async {
    final storage = FlutterSecureStorage();
    final createdAtStr = await storage.read(key: '${service}_$_keyAgeKey');

    if (createdAtStr == null) return false;

    final createdAt = DateTime.parse(createdAtStr);
    final age = DateTime.now().difference(createdAt);

    return age > _rotationPeriod;
  }

  static Future<void> markKeyCreated(String service) async {
    final storage = FlutterSecureStorage();
    await storage.write(
      key: '${service}_$_keyAgeKey',
      value: DateTime.now().toIso8601String(),
    );
  }
}
```

### 3. Server-Side Token Exchange

For production apps, use server-side token exchange:

```dart
class SecureApiClient {
  final String serverUrl;

  SecureApiClient(this.serverUrl);

  /// Gets a short-lived token from your backend
  Future<String> getShortLivedToken() async {
    final response = await http.post(
      Uri.parse('$serverUrl/api/tokens'),
      headers: {
        'Authorization': 'Bearer ${await _getUserAuthToken()}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    }

    throw Exception('Failed to get token');
  }

  Future<String> _getUserAuthToken() async {
    // Get user's authentication token
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'user_auth_token') ?? '';
  }
}

// Usage
final token = await apiClient.getShortLivedToken();
final chatAdapter = OpenAiChatAdapter(
  apiKey: token,
  model: 'gpt-3.5-turbo',
);
```

## Cloud LLM Security

### 1. HTTPS Only

All network requests use HTTPS:

```dart
// Built into all adapters
class OpenAiChatAdapter extends BaseChatAdapter {
  static const String _defaultBaseUrl = 'https://api.openai.com/v1';
  // Always HTTPS
}
```

### 2. Request Filtering

Filter sensitive content before sending to cloud:

```dart
class CloudRequestFilter {
  static const _piiPatterns = [
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',  // Email
    r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b',                          // Phone
    r'\b\d{3}-\d{2}-\d{4}\b',                                  // SSN
  ];

  static bool containsPII(String text) {
    for (final pattern in _piiPatterns) {
      if (RegExp(pattern).hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> shouldAllowCloudInference(String content) async {
    // Check user settings
    final prefs = await SharedPreferences.getInstance();
    final allowPII = prefs.getBool('allow_pii_cloud') ?? false;

    if (!allowPII && containsPII(content)) {
      return false;
    }

    return true;
  }
}
```

### 3. Response Validation

Validate and sanitize responses:

```dart
class ResponseValidator {
  static String validateAndSanitize(String response) {
    // Remove any leaked API keys or tokens
    var sanitized = response.replaceAll(
      RegExp(r'sk-[a-zA-Z0-9]{32,}'),
      '[REDACTED]',
    );

    // Remove potential code injection
    sanitized = sanitized.replaceAll(
      RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false),
      '[SCRIPT_REMOVED]',
    );

    return sanitized;
  }
}
```

## Model Security

### 1. Model Verification

Verify model checksums before use:

```dart
Future<void> downloadAndVerifyModel(String modelId) async {
  final modelInfo = await aiMl.getModelInfo(modelId);

  // Download
  await aiMl.downloadAndInstallModel(modelId);

  // Verify checksum
  if (modelInfo.checksum != null) {
    final modelPath = await _getModelPath(modelId);
    final modelFile = File(modelPath);
    final bytes = await modelFile.readAsBytes();
    final actualChecksum = sha256.convert(bytes).toString();

    if (actualChecksum != modelInfo.checksum) {
      // Delete corrupted model
      await modelFile.delete();
      throw ModelException('Checksum mismatch for model: $modelId');
    }
  }
}
```

### 2. Model Source Validation

Only download models from trusted sources:

```dart
class TrustedModelSources {
  static const _trustedDomains = [
    'storage.googleapis.com',
    'tfhub.dev',
    'huggingface.co',
  ];

  static bool isTrustedSource(String url) {
    final uri = Uri.parse(url);
    return _trustedDomains.any((domain) => uri.host.contains(domain));
  }
}

// Validate before download
Future<void> safeDownloadModel(String modelId) async {
  final modelInfo = await aiMl.getModelInfo(modelId);

  if (modelInfo.downloadUrl != null) {
    if (!TrustedModelSources.isTrustedSource(modelInfo.downloadUrl!)) {
      throw SecurityException('Untrusted model source: ${modelInfo.downloadUrl}');
    }
  }

  await aiMl.downloadAndInstallModel(modelId);
}
```

## Compliance (GDPR/CCPA)

### 1. Data Inventory

Track what data is collected:

```dart
class DataInventory {
  static Map<String, dynamic> getDataInventory() {
    return {
      'on_device_models': {
        'stored': true,
        'location': 'app_cache',
        'purpose': 'ML inference',
        'retention': 'until_app_deletion',
      },
      'vector_store': {
        'stored': true,
        'location': 'app_database',
        'purpose': 'semantic_search',
        'retention': 'configurable',
        'encrypted': true,
      },
      'api_keys': {
        'stored': true,
        'location': 'secure_storage',
        'purpose': 'cloud_api_access',
        'retention': 'until_logout',
      },
      'chat_history': {
        'stored': true,
        'location': 'in_memory',
        'purpose': 'conversation_context',
        'retention': 'session_only',
      },
    };
  }
}
```

### 2. Right to Deletion

Implement complete data deletion:

```dart
class DataDeletionManager {
  static Future<void> deleteAllUserData() async {
    // 1. Delete vector store data
    for (final store in aiMl._vectorStores.values) {
      await store.clear();
      await store.dispose();
    }

    // 2. Delete downloaded models
    final cacheDir = await getApplicationCacheDirectory();
    final modelsDir = Directory('${cacheDir.path}/models');
    if (await modelsDir.exists()) {
      await modelsDir.delete(recursive: true);
    }

    // 3. Delete API keys
    final storage = FlutterSecureStorage();
    await storage.deleteAll();

    // 4. Clear chat sessions
    for (final session in aiMl._chatSessions.values) {
      await aiMl.closeChatSession(session);
    }

    print('All user data deleted');
  }
}
```

### 3. Data Export

Provide data export functionality:

```dart
class DataExporter {
  static Future<Map<String, dynamic>> exportUserData() async {
    final data = <String, dynamic>{};

    // Export vector store documents
    final vectorStore = aiMl._vectorStores['kb'];
    if (vectorStore != null) {
      final count = await vectorStore.count();
      data['vector_store'] = {
        'document_count': count,
        'database_name': (vectorStore as SqliteVectorStore).dbName,
      };
    }

    // Export model info
    data['models'] = {
      'downloaded': await _listDownloadedModels(),
    };

    // Export settings
    final prefs = await SharedPreferences.getInstance();
    data['settings'] = {
      'inference_policy': prefs.getString('inference_policy'),
      'allow_cloud_inference': prefs.getBool('allow_cloud_inference'),
    };

    return data;
  }
}
```

## User Consent

### Consent Flow

```dart
class ConsentManager {
  static const _storage = FlutterSecureStorage();

  static Future<bool> hasConsent(String purpose) async {
    final consent = await _storage.read(key: 'consent_$purpose');
    return consent == 'true';
  }

  static Future<void> requestConsent(BuildContext context, String purpose) async {
    final consented = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Required'),
        content: Text(_getConsentMessage(purpose)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Decline'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Accept'),
          ),
        ],
      ),
    );

    if (consented == true) {
      await _storage.write(key: 'consent_$purpose', value: 'true');
    }
  }

  static String _getConsentMessage(String purpose) {
    switch (purpose) {
      case 'cloud_inference':
        return 'This feature sends your data to cloud servers for processing. '
               'Your data will be encrypted in transit but will leave your device.';
      case 'model_download':
        return 'This will download a ${purpose} model to your device. '
               'The download may use mobile data.';
      default:
        return 'Permission needed for: $purpose';
    }
  }
}
```

## Data Retention

### Automatic Cleanup

```dart
class DataRetentionManager {
  static const _maxVectorStoreAge = Duration(days: 90);
  static const _maxModelAge = Duration(days: 180);

  static Future<void> enforceRetentionPolicy() async {
    await _cleanOldVectorStoreData();
    await _cleanOldModels();
  }

  static Future<void> _cleanOldVectorStoreData() async {
    final vectorStore = aiMl._vectorStores['kb'] as SqliteVectorStore?;
    if (vectorStore == null) return;

    final cutoff = DateTime.now().subtract(_maxVectorStoreAge);

    // Delete old documents
    await vectorStore._db.delete(
      'vector_documents',
      where: 'created_at < ?',
      whereArgs: [cutoff.millisecondsSinceEpoch],
    );
  }

  static Future<void> _cleanOldModels() async {
    final cacheDir = await getApplicationCacheDirectory();
    final modelsDir = Directory('${cacheDir.path}/models');

    if (!await modelsDir.exists()) return;

    final files = await modelsDir.list().toList();
    final cutoff = DateTime.now().subtract(_maxModelAge);

    for (final file in files.whereType<File>()) {
      final stat = await file.stat();
      if (stat.modified.isBefore(cutoff)) {
        await file.delete();
      }
    }
  }
}
```

## Security Checklist

### Pre-Launch Checklist

- [ ] No API keys hardcoded in source code
- [ ] API keys stored in `flutter_secure_storage`
- [ ] HTTPS used for all network requests
- [ ] Model checksums verified on download
- [ ] PII detection implemented
- [ ] User consent flows implemented
- [ ] Data deletion functionality tested
- [ ] Data export functionality implemented
- [ ] Encryption enabled for sensitive data
- [ ] Logging disabled in production builds
- [ ] Vector store encryption enabled (if needed)
- [ ] Model sources validated
- [ ] Response validation implemented
- [ ] Data retention policy enforced
- [ ] Privacy policy updated
- [ ] GDPR/CCPA compliance verified

### Runtime Checklist

- [ ] Monitor for data leaks in logs
- [ ] Audit API key usage
- [ ] Track consent changes
- [ ] Monitor model download sources
- [ ] Review cloud API usage
- [ ] Check encryption status
- [ ] Validate retention policy execution

---

For questions or security concerns, please review the main repository's security policy.
