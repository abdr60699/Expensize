import 'dart:io';
import 'package:flutter/material.dart';
import '../ai_ml.dart';

/// Example application demonstrating AI/ML module features
///
/// This example shows how to:
/// 1. Initialize the AI/ML manager
/// 2. Register adapters
/// 3. Perform image classification
/// 4. Run OCR on images
/// 5. Generate text embeddings
/// 6. Create and use a vector store
/// 7. Set up a chat session with RAG
/// 8. Generate chat responses with retrieved context

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create an example instance
  final example = AiMlExample();
  await example.initialize();

  // Run examples
  await example.runImageClassificationExample();
  await example.runOcrExample();
  await example.runEmbeddingExample();
  await example.runChatWithRagExample();

  // Cleanup
  await example.dispose();
}

class AiMlExample {
  late AiMlManager aiMl;
  late SqliteVectorStore vectorStore;

  /// Initialize the AI/ML manager and adapters
  Future<void> initialize() async {
    print('🚀 Initializing AI/ML module...\n');

    // Create configuration
    final config = AiMlConfig(
      inferencePolicy: InferencePolicy.preferOnDevice,
      enableLogging: true,
      apiKeys: {
        'openai': 'your-openai-api-key-here',
      },
    );

    // Create manager
    aiMl = AiMlManager(
      config: config,
      logger: const ConsoleLogger(enabled: true),
    );

    // Initialize
    await aiMl.initialize(config);

    // Register image classification adapter
    final imageClassifier = TfliteImageClassificationAdapter(
      modelInfo: ModelInfo(
        id: 'mobilenet_v2_1.0_224_quantized',
        name: 'MobileNet V2 Quantized',
        sizeBytes: 3500000,
        framework: 'tflite',
        quantized: true,
        quantizationType: 'int8',
      ),
      labels: _getImageNetLabels(), // You would load this from a file
      inputSize: 224,
      useGpuDelegate: true,
    );
    await imageClassifier.initialize();
    aiMl.registerAdapter('image_classifier', imageClassifier);

    // Register OCR adapter
    final ocrAdapter = MlKitOcrAdapter(
      modelInfo: ModelInfo(
        id: 'mlkit_text_recognition',
        name: 'ML Kit Text Recognition',
        sizeBytes: 0,
        framework: 'mlkit',
        quantized: false,
      ),
    );
    await ocrAdapter.initialize();
    aiMl.registerAdapter('ocr', ocrAdapter);

    // Register text embedding adapter
    final embeddingAdapter = TfliteTextEmbeddingAdapter(
      modelInfo: ModelInfo(
        id: 'universal_sentence_encoder_lite',
        name: 'Universal Sentence Encoder Lite',
        sizeBytes: 50000000,
        framework: 'tflite',
        quantized: false,
      ),
    );
    await embeddingAdapter.initialize();
    aiMl.registerAdapter('text_embedder', embeddingAdapter);

    // Register OpenAI chat adapter
    final openAiAdapter = OpenAiChatAdapter(
      apiKey: config.apiKeys?['openai'] ?? '',
      model: 'gpt-3.5-turbo',
    );
    await openAiAdapter.initialize();
    aiMl.registerChatAdapter('openai', openAiAdapter);

    // Create and register vector store
    vectorStore = SqliteVectorStore(
      dbName: 'example_vectors',
      embeddingGenerator: _EmbeddingGeneratorAdapter(aiMl),
    );
    await vectorStore.initialize();
    aiMl.registerVectorStore('docs', vectorStore);

    print('✅ AI/ML module initialized successfully\n');
  }

  /// Example: Image classification
  Future<void> runImageClassificationExample() async {
    print('📸 Running Image Classification Example...\n');

    try {
      // In a real app, you would load an actual image file
      // final imageFile = File('/path/to/image.jpg');

      print('Note: Image classification requires an actual image file.');
      print('Usage: await aiMl.classifyImage(imageFile, threshold: 0.1);\n');

      // Example result processing:
      // final result = await aiMl.classifyImage(imageFile, threshold: 0.1);
      // print('Top predictions:');
      // for (final label in result.labels.take(5)) {
      //   print('  ${label.label}: ${(label.score * 100).toStringAsFixed(2)}%');
      // }
    } catch (e) {
      print('❌ Error: $e\n');
    }
  }

  /// Example: OCR
  Future<void> runOcrExample() async {
    print('📝 Running OCR Example...\n');

    try {
      print('Note: OCR requires an actual image file with text.');
      print('Usage: await aiMl.runOcr(imageFile);\n');

      // Example result processing:
      // final result = await aiMl.runOcr(imageFile);
      // print('Recognized text:');
      // print(result.text);
      // print('\nConfident blocks (>0.8):');
      // for (final block in result.getAboveThreshold(0.8)) {
      //   print('  "${block.text}" (${block.confidence.toStringAsFixed(2)})');
      // }
    } catch (e) {
      print('❌ Error: $e\n');
    }
  }

  /// Example: Text embeddings and vector store
  Future<void> runEmbeddingExample() async {
    print('🔢 Running Text Embedding & Vector Store Example...\n');

    try {
      // Add some sample documents to the vector store
      final documents = [
        'Flutter is Google\'s UI toolkit for building beautiful, natively compiled applications.',
        'TensorFlow Lite is a lightweight solution for mobile and embedded devices.',
        'Machine learning models can run efficiently on mobile devices using quantization.',
        'Vector databases enable semantic search by comparing embedding similarities.',
        'On-device inference provides privacy and works offline.',
      ];

      print('Adding ${documents.length} documents to vector store...');
      for (int i = 0; i < documents.length; i++) {
        await vectorStore.addDocument(
          'doc_$i',
          documents[i],
          metadata: {'index': i, 'category': 'tech'},
        );
      }

      print('✅ Documents added\n');

      // Query the vector store
      final query = 'How to build mobile apps?';
      print('Query: "$query"\n');

      final results = await vectorStore.query(
        query,
        topK: 3,
        minSimilarity: 0.0,
      );

      print('Top 3 similar documents:');
      for (final result in results) {
        print('  [${result.score.toStringAsFixed(4)}] ${result.text}');
      }
      print('');
    } catch (e) {
      print('❌ Error: $e\n');
    }
  }

  /// Example: Chat with RAG
  Future<void> runChatWithRagExample() async {
    print('💬 Running Chat with RAG Example...\n');

    try {
      // Create a chat session with RAG enabled
      final session = aiMl.createChatSession(
        config: ChatSessionConfig(
          backend: ModelProvider.openai,
          systemPrompt: 'You are a helpful AI assistant with access to a knowledge base. '
              'Use the provided context to answer questions accurately.',
          retrieval: RetrievalConfig(
            vectorStoreId: 'docs',
            topK: 2,
            minSimilarity: 0.3,
          ),
          temperature: 0.7,
          maxTokens: 200,
        ),
      );

      print('Chat session created: ${session.id}\n');

      // Example conversation
      final queries = [
        'What is Flutter?',
        'How does on-device ML help with privacy?',
      ];

      for (final query in queries) {
        print('User: $query');

        // Note: This requires a valid OpenAI API key
        print('Note: Requires valid API key. Usage:');
        print('  final response = await aiMl.chatGenerate(session, query);');
        print('  print("Assistant: \${response.text}");');

        // Example response processing:
        // final response = await aiMl.chatGenerate(session, query);
        // print('Assistant: ${response.text}');
        // if (response.retrievedDocuments != null) {
        //   print('Retrieved ${response.retrievedDocuments!.length} documents');
        // }
        print('');
      }

      // Close session
      await aiMl.closeChatSession(session);
      print('Chat session closed\n');
    } catch (e) {
      print('❌ Error: $e\n');
    }
  }

  /// Cleanup resources
  Future<void> dispose() async {
    print('🧹 Cleaning up resources...');
    await aiMl.dispose();
    print('✅ Cleanup complete');
  }

  /// Mock ImageNet labels (first 10 for demo)
  List<String> _getImageNetLabels() {
    return [
      'background',
      'tench',
      'goldfish',
      'great white shark',
      'tiger shark',
      'hammerhead',
      'electric ray',
      'stingray',
      'cock',
      'hen',
      // ... (normally 1000 labels)
    ];
  }
}

/// Adapter to use AiMlManager for embedding generation in VectorStore
class _EmbeddingGeneratorAdapter implements TextEmbeddingGenerator {
  final AiMlManager aiMl;

  _EmbeddingGeneratorAdapter(this.aiMl);

  @override
  Future<TextEmbedding> generate(String text) async {
    return aiMl.embedText(text, modelId: 'text_embedder');
  }
}
