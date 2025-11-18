# AI/ML Module Features

Complete guide to all features and capabilities available in the AI/ML module.

## Table of Contents

- [On-Device Machine Learning](#on-device-machine-learning)
- [Cloud LLM Integration](#cloud-llm-integration)
- [Vector Store & Semantic Search](#vector-store--semantic-search)
- [RAG (Retrieval-Augmented Generation)](#rag-retrieval-augmented-generation)
- [Model Management](#model-management)
- [Logging & Monitoring](#logging--monitoring)

---

## On-Device Machine Learning

Process data locally on the device for privacy, offline capability, and reduced latency.

### Image Classification

Classify images using TensorFlow Lite models.

**What you can do:**
- Identify objects, scenes, and concepts in images
- Get confidence scores for each prediction
- Filter results by confidence threshold
- Support for quantized models (INT8) for faster inference
- GPU acceleration support for better performance

**Use cases:**
- Product recognition in e-commerce apps
- Food classification in nutrition apps
- Document categorization
- Quality control in manufacturing
- Wildlife identification

**Example:**
```dart
final result = await aiMl.classifyImage(
  imageFile,
  threshold: 0.1,
);

for (final label in result.labels.take(5)) {
  print('${label.label}: ${(label.score * 100).toStringAsFixed(2)}%');
}
```

**Supported models:**
- MobileNet V2/V3
- EfficientNet
- ResNet
- Custom TFLite models

---

### Object Detection

Detect and locate multiple objects within images.

**What you can do:**
- Detect multiple objects in a single image
- Get bounding box coordinates for each object
- Receive confidence scores for detections
- Filter detections by confidence threshold
- Real-time object tracking in camera feeds

**Use cases:**
- Inventory management (counting items)
- Safety monitoring (PPE detection)
- Retail analytics (shelf monitoring)
- Parking lot monitoring
- Wildlife monitoring

**Example:**
```dart
final objects = await aiMl.detectObjects(
  imageFile,
  threshold: 0.5,
);

for (final obj in objects) {
  print('${obj.label} at ${obj.boundingBox}');
  print('Confidence: ${obj.confidence}');
}
```

**Supported frameworks:**
- Google ML Kit Object Detection
- Custom TFLite object detection models

---

### OCR (Optical Character Recognition)

Extract text from images with high accuracy.

**What you can do:**
- Extract text from photos and scanned documents
- Get structured text blocks with coordinates
- Receive confidence scores for each text block
- Support for multiple languages
- Handle handwriting and printed text

**Use cases:**
- Receipt scanning for expense tracking
- Business card digitization
- ID/passport verification
- Document digitization
- License plate recognition
- Sign translation apps

**Example:**
```dart
final result = await aiMl.runOcr(imageFile);

print('Full text: ${result.text}');
print('Confidence: ${result.averageConfidence}');

// Get high-confidence blocks
for (final block in result.getAboveThreshold(0.8)) {
  print('${block.text} (${block.confidence})');
}
```

**Features:**
- Text block extraction
- Bounding box coordinates
- Per-block confidence scores
- Language detection (ML Kit)
- Line and word segmentation

---

### Text Embeddings

Generate vector representations of text for semantic operations.

**What you can do:**
- Convert text to high-dimensional vectors
- Measure semantic similarity between texts
- Enable semantic search capabilities
- Cluster related documents
- Build recommendation systems

**Use cases:**
- Semantic search in documentation
- Duplicate detection
- Content recommendation
- Text clustering and categorization
- Question-answer matching

**Example:**
```dart
final embedding = await aiMl.embedText(
  'Flutter is a UI toolkit',
  modelId: 'text_embedder',
);

print('Embedding dimension: ${embedding.dimension}');
print('Vector: ${embedding.values}');
```

**Supported models:**
- Universal Sentence Encoder
- BERT embeddings
- Custom TFLite embedding models

---

### Text Classification

Categorize text into predefined classes.

**What you can do:**
- Classify text into categories
- Multi-label classification
- Sentiment analysis
- Intent detection
- Content moderation

**Use cases:**
- Email categorization
- Sentiment analysis for reviews
- Content filtering
- Intent recognition in chatbots
- News article categorization

**Example:**
```dart
final result = await aiMl.classifyText(
  'This product is amazing!',
  threshold: 0.3,
);

for (final label in result.labels) {
  print('${label.label}: ${label.score}');
}
```

---

## Cloud LLM Integration

Connect to powerful cloud-based language models for advanced AI capabilities.

### Multi-Provider Support

**Supported providers:**
- **OpenAI**: GPT-3.5-turbo, GPT-4, GPT-4-turbo
- **Anthropic** (coming soon): Claude 2, Claude 3
- **Vertex AI** (coming soon): PaLM 2, Gemini
- **Azure OpenAI** (coming soon): Microsoft-hosted OpenAI models

**What you can do:**
- Switch between providers seamlessly
- Configure per-session provider selection
- Fallback strategies for high availability
- Cost optimization by provider selection

---

### Chat Sessions

Stateful conversations with context management.

**What you can do:**
- Create isolated chat sessions
- Maintain conversation history
- Configure system prompts per session
- Control context window size
- Manage multiple concurrent sessions

**Features:**
- **Session Management**: Create, track, and close chat sessions
- **Context Window**: Configure max history messages
- **System Prompts**: Set AI behavior and personality
- **Message History**: Automatic history tracking
- **Session Isolation**: Independent contexts per session

**Example:**
```dart
final session = aiMl.createChatSession(
  config: ChatSessionConfig(
    backend: ModelProvider.openai,
    systemPrompt: 'You are a helpful financial advisor.',
    maxHistoryMessages: 10,
    temperature: 0.7,
    maxTokens: 500,
  ),
);

final response = await aiMl.chatGenerate(
  session,
  'How should I budget my expenses?',
);

print('Assistant: ${response.text}');
```

---

### Streaming Responses

Real-time token streaming for better user experience.

**What you can do:**
- Stream responses token-by-token
- Display partial responses in real-time
- Cancel generation mid-stream
- Better perceived performance

**Use cases:**
- Interactive chatbots
- Writing assistants
- Code generation tools
- Real-time translation

**Example:**
```dart
final response = await aiMl.chatGenerate(
  session,
  query,
  options: ChatOptions(stream: true),
);

await for (final token in response.streamingTokens!) {
  print(token); // Display incrementally
}
```

---

### Configuration Options

Fine-tune LLM behavior for your use case.

**Available parameters:**
- **temperature** (0.0-1.0): Controls randomness/creativity
  - 0.0: Deterministic, focused responses
  - 1.0: Creative, diverse responses
- **maxTokens**: Maximum response length
- **topP**: Nucleus sampling parameter
- **frequencyPenalty**: Reduce repetition
- **presencePenalty**: Encourage topic diversity
- **stopSequences**: Custom stop conditions

**Example:**
```dart
ChatSessionConfig(
  temperature: 0.3,      // More focused
  maxTokens: 1000,       // Long responses
  modelId: 'gpt-4',      // Specific model
)
```

---

## Vector Store & Semantic Search

SQLite-based vector database for efficient similarity search.

### Document Storage

**What you can do:**
- Store documents with vector embeddings
- Attach metadata to documents
- Update existing documents
- Delete documents by ID
- Batch operations for efficiency

**Features:**
- Automatic embedding generation
- Metadata storage and filtering
- Efficient SQLite backend
- Persistent storage
- Transaction support

**Example:**
```dart
// Initialize vector store
final vectorStore = SqliteVectorStore(
  dbName: 'my_knowledge_base',
  embeddingGenerator: embeddingAdapter,
);
await vectorStore.initialize();

// Add documents
await vectorStore.addDocument(
  'doc_1',
  'Flutter is a UI toolkit for building apps.',
  metadata: {
    'category': 'technology',
    'source': 'documentation',
    'date': '2024-01-01',
  },
);
```

---

### Semantic Search

Find relevant documents using meaning, not just keywords.

**What you can do:**
- Query by natural language
- Cosine similarity matching
- Filter by minimum similarity threshold
- Return top-K results
- Include/exclude metadata
- Combine with metadata filtering

**Advantages over keyword search:**
- Understands synonyms and related concepts
- Handles paraphrasing
- Context-aware matching
- No need for exact keyword matches

**Example:**
```dart
final results = await vectorStore.query(
  'How do I build mobile applications?',
  topK: 5,
  minSimilarity: 0.7,
);

for (final doc in results) {
  print('[${doc.score.toStringAsFixed(4)}] ${doc.text}');
  print('Metadata: ${doc.metadata}');
}
```

---

### Advanced Querying

**Capabilities:**
- **Top-K retrieval**: Get N most similar documents
- **Similarity threshold**: Filter by minimum score
- **Metadata filtering**: Combine semantic + metadata filters
- **Chunking**: Split large documents for better retrieval
- **Re-ranking**: Post-process results for relevance

**Configuration:**
```dart
RetrievalConfig(
  vectorStoreId: 'docs',
  topK: 5,                  // Top 5 results
  minSimilarity: 0.7,       // 70% similarity minimum
  includeMetadata: true,    // Include document metadata
  maxChunkSize: 500,        // Token limit per chunk
  chunkOverlap: 50,         // Overlap between chunks
)
```

---

## RAG (Retrieval-Augmented Generation)

Enhance LLM responses with relevant context from your knowledge base.

### How RAG Works

1. **User Query** → Vector Store
2. **Retrieve** top-K similar documents
3. **Inject** retrieved context into prompt
4. **Generate** response using LLM with context
5. **Return** response + retrieved sources

### Automatic Context Injection

**What you can do:**
- Automatically enhance prompts with relevant context
- Reduce hallucinations by grounding in facts
- Cite sources for responses
- Update knowledge without retraining models
- Domain-specific expertise

**Benefits:**
- **Accuracy**: Responses based on your data
- **Freshness**: Update knowledge in real-time
- **Transparency**: See which documents were used
- **Privacy**: Keep sensitive data local
- **Cost**: Avoid fine-tuning large models

**Example:**
```dart
// Create session with RAG enabled
final session = aiMl.createChatSession(
  config: ChatSessionConfig(
    backend: ModelProvider.openai,
    systemPrompt: 'You are a helpful assistant. Use the provided context to answer accurately.',
    retrieval: RetrievalConfig(
      vectorStoreId: 'docs',
      topK: 3,
      minSimilarity: 0.7,
    ),
  ),
);

// Generate response (RAG happens automatically)
final response = await aiMl.chatGenerate(
  session,
  'What are the benefits of Flutter?',
);

print('Response: ${response.text}');

// See which documents were retrieved
if (response.retrievedDocuments != null) {
  print('\nSources used:');
  for (final doc in response.retrievedDocuments!) {
    print('- ${doc.text.substring(0, 100)}...');
    print('  Relevance: ${doc.score}');
  }
}
```

---

### Use Cases

**Customer Support:**
- Answer questions from knowledge base
- Cite documentation automatically
- Handle edge cases with custom data

**Research & Documentation:**
- Query large document collections
- Synthesize information from multiple sources
- Generate summaries with citations

**Enterprise Knowledge Management:**
- Company-specific Q&A
- Policy and procedure assistance
- Onboarding assistance

**Content Creation:**
- Fact-checked writing assistance
- Research-backed content generation
- Domain-specific expertise

---

## Model Management

Download, install, and manage ML models.

### Model Download

**What you can do:**
- Download models from URLs
- Progress tracking
- Resume interrupted downloads
- Verify model integrity
- Automatic caching

**Example:**
```dart
await aiMl.downloadAndInstallModel('mobilenet_v2');
```

### Model Information

**What you can retrieve:**
- Model ID and name
- Framework (TFLite, ML Kit, etc.)
- File size
- Quantization type
- Input/output specifications
- Supported operations

**Example:**
```dart
final info = await aiMl.getModelInfo('mobilenet_v2');

print('Name: ${info.name}');
print('Size: ${info.sizeBytes / 1024 / 1024} MB');
print('Framework: ${info.framework}');
print('Quantized: ${info.quantized}');
```

---

## Logging & Monitoring

Track operations and debug issues.

### Built-in Loggers

**ConsoleLogger**: Print to console
```dart
final logger = ConsoleLogger(enabled: true);
```

**NoOpLogger**: Disable logging (production)
```dart
final logger = NoOpLogger();
```

**Custom Logger**: Implement your own
```dart
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
```

### Log Levels

- **info**: General information
- **warning**: Non-critical issues
- **error**: Errors and exceptions
- **debug**: Detailed debugging info

### What Gets Logged

- Initialization events
- Model downloads and loads
- Inference requests and results
- Chat generations
- Vector store operations
- Error conditions with stack traces

---

## Inference Policies

Control where computations happen.

### Available Policies

```dart
enum InferencePolicy {
  preferOnDevice,   // Try on-device first, fallback to cloud
  preferCloud,      // Try cloud first, fallback to on-device
  onDeviceOnly,     // Only use on-device models (offline)
  cloudOnly,        // Only use cloud APIs (online)
}
```

**Use cases:**
- **preferOnDevice**: Privacy-sensitive apps, reduce costs
- **preferCloud**: Best accuracy, large models
- **onDeviceOnly**: Offline apps, airplane mode
- **cloudOnly**: Web apps, always-online services

---

## Privacy & Offline Features

### Privacy-First Design

- **On-device inference**: No data leaves the device
- **Local vector store**: Embeddings stored locally
- **Selective cloud usage**: Choose what goes to cloud
- **No telemetry**: No built-in tracking
- **Data control**: You decide data flow

### Offline Capability

**What works offline:**
- ✅ Image classification
- ✅ Object detection
- ✅ OCR
- ✅ Text embeddings
- ✅ Text classification
- ✅ Vector store queries
- ❌ Cloud LLM chat (requires internet)

**Hybrid approach:**
- Use on-device ML for preprocessing
- Use cloud LLM only when online
- Cache responses for offline access

---

## Error Handling

Comprehensive exception types for different scenarios.

### Exception Types

- **InitializationException**: Manager not initialized
- **ModelNotFoundException**: Model or adapter not found
- **ModelException**: Model-related errors
- **ChatException**: Chat/LLM errors
- **VectorStoreException**: Vector database errors

**Example:**
```dart
try {
  final result = await aiMl.classifyImage(imageFile);
} on ModelNotFoundException catch (e) {
  print('Model not found: ${e.modelId}');
} on InitializationException catch (e) {
  print('Not initialized: ${e.message}');
} catch (e, stackTrace) {
  print('Error: $e');
  print('Stack trace: $stackTrace');
}
```

---

## Performance Optimizations

### GPU Acceleration

Enable GPU delegate for TFLite models:
```dart
TfliteImageClassificationAdapter(
  // ...
  useGpuDelegate: true,
);
```

### Quantization

Use INT8 quantized models for:
- 4x smaller model size
- Faster inference (2-3x)
- Lower memory usage
- Minimal accuracy loss

### Caching Strategies

- Cache embeddings for frequent queries
- Reuse model instances across calls
- Batch similar operations
- Pre-warm models during app startup

### Batch Processing

Process multiple items together:
```dart
// Instead of
for (final image in images) {
  await classifyImage(image);
}

// Consider batching if adapter supports it
```

---

## Summary

The AI/ML module provides:

✅ **6 on-device ML capabilities** (classification, detection, OCR, embeddings, etc.)
✅ **Multi-provider LLM support** (OpenAI, Anthropic, Vertex AI)
✅ **Vector database** with semantic search
✅ **RAG patterns** for enhanced AI responses
✅ **Privacy-first design** with offline support
✅ **Flexible adapter architecture** for extensibility
✅ **Production-ready** error handling and logging

All designed to be modular, reusable, and easy to integrate into any Flutter app.
