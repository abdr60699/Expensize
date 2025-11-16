import '../models/chat_models.dart';
import '../models/vector_store_models.dart';
import '../storage/vector_store.dart';
import '../errors/ai_ml_exceptions.dart';
import 'adapters/chat_adapter.dart';

/// Service for managing chat operations
class ChatService {
  final ChatAdapter adapter;
  final VectorStore? vectorStore;

  ChatService({
    required this.adapter,
    this.vectorStore,
  });

  /// Initializes the service
  Future<void> initialize() async {
    await adapter.initialize();
    if (vectorStore != null) {
      await vectorStore!.load();
    }
  }

  /// Generates a response with optional RAG
  Future<ChatResponse> generate({
    required List<ChatMessage> messages,
    String? systemPrompt,
    double temperature = 0.7,
    int? maxTokens,
    bool enableRetrieval = false,
    int retrievalTopK = 3,
    double retrievalMinSimilarity = 0.7,
  }) async {
    // Perform retrieval if enabled
    List<ScoredDocument>? retrievedDocs;

    if (enableRetrieval && vectorStore != null && messages.isNotEmpty) {
      final lastUserMessage = messages.lastWhere(
        (m) => m.role == ChatRole.user,
        orElse: () => messages.last,
      );

      try {
        retrievedDocs = await vectorStore!.query(
          lastUserMessage.content,
          topK: retrievalTopK,
          minSimilarity: retrievalMinSimilarity,
        );
      } catch (e) {
        // Continue without retrieval if it fails
      }
    }

    // Enhance prompt with retrieved context
    List<ChatMessage> enhancedMessages = messages;

    if (retrievedDocs != null && retrievedDocs.isNotEmpty) {
      final context = retrievedDocs
          .map((doc) => doc.text)
          .join('\n\n');

      final lastUserMessage = messages.last;
      final enhancedContent = '''
Context information:
$context

User query: ${lastUserMessage.content}
''';

      enhancedMessages = [
        ...messages.sublist(0, messages.length - 1),
        ChatMessage(
          role: ChatRole.user,
          content: enhancedContent,
          metadata: {
            'original_query': lastUserMessage.content,
            'retrieved_docs': retrievedDocs.length,
          },
        ),
      ];
    }

    // Generate response
    final request = ChatRequest(
      messages: enhancedMessages,
      systemPrompt: systemPrompt,
      temperature: temperature,
      maxTokens: maxTokens,
    );

    final response = await adapter.generate(request);

    return ChatResponse(
      text: response.text,
      streamingTokens: response.streamingTokens,
      metadata: {
        ...?response.metadata,
        if (retrievedDocs != null) 'retrieval_enabled': true,
      },
      retrievedDocuments: retrievedDocs,
      generationTimeMs: response.generationTimeMs,
    );
  }

  /// Adds a document to the vector store for retrieval
  Future<void> addDocument(
    String id,
    String text, {
    Map<String, dynamic>? metadata,
  }) async {
    if (vectorStore == null) {
      throw VectorStoreException('Vector store not configured');
    }

    await vectorStore!.addDocument(id, text, metadata: metadata);
  }

  /// Queries the vector store
  Future<List<ScoredDocument>> queryVectorStore(
    String query, {
    int topK = 10,
    double? minSimilarity,
  }) async {
    if (vectorStore == null) {
      throw VectorStoreException('Vector store not configured');
    }

    return vectorStore!.query(
      query,
      topK: topK,
      minSimilarity: minSimilarity,
    );
  }

  /// Disposes resources
  Future<void> dispose() async {
    await adapter.dispose();
    if (vectorStore != null) {
      await vectorStore!.dispose();
    }
  }
}
