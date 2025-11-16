import 'dart:io';
import '../models/models.dart';
import '../errors/ai_ml_exceptions.dart';
import '../utils/logger.dart';
import '../storage/vector_store.dart';
import 'adapters/model_adapter.dart';
import 'adapters/chat_adapter.dart';
import 'chat_service.dart';
import 'model_manager.dart';

/// Main facade for AI/ML functionality
class AiMlManager {
  final AiMlConfig config;
  final AiLogger logger;
  final ModelManager _modelManager;
  final Map<String, ModelAdapter> _adapters = {};
  final Map<String, ChatAdapter> _chatAdapters = {};
  final Map<String, VectorStore> _vectorStores = {};
  final Map<String, ChatSession> _chatSessions = {};

  bool _initialized = false;

  AiMlManager({
    AiMlConfig? config,
    AiLogger? logger,
  })  : config = config ?? const AiMlConfig(),
        logger = logger ?? (config?.enableLogging == true
            ? const ConsoleLogger(enabled: true)
            : const NoOpLogger()),
        _modelManager = ModelManager(
          logger: logger ?? const NoOpLogger(),
        );

  /// Checks if the manager is initialized
  bool get isInitialized => _initialized;

  /// Initializes the AI/ML manager
  Future<void> initialize(AiMlConfig config) async {
    if (_initialized) {
      logger.warning('AiMlManager already initialized');
      return;
    }

    try {
      logger.info('Initializing AiMlManager...');

      // Initialize model manager
      await _modelManager.initialize();

      logger.info('AiMlManager initialized successfully');
      _initialized = true;
    } catch (e, stackTrace) {
      logger.error('Failed to initialize AiMlManager', e, stackTrace);
      throw InitializationException(
        'Failed to initialize AiMlManager',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Registers a model adapter
  void registerAdapter(String modelId, ModelAdapter adapter) {
    _adapters[modelId] = adapter;
    logger.info('Registered adapter for model: $modelId');
  }

  /// Registers a chat adapter
  void registerChatAdapter(String id, ChatAdapter adapter) {
    _chatAdapters[id] = adapter;
    logger.info('Registered chat adapter: $id');
  }

  /// Registers a vector store
  void registerVectorStore(String id, VectorStore store) {
    _vectorStores[id] = store;
    logger.info('Registered vector store: $id');
  }

  // ==================== Image Tasks ====================

  /// Classifies an image
  Future<ImageClassificationResult> classifyImage(
    File image, {
    String? modelId,
    double threshold = 0.0,
  }) async {
    _ensureInitialized();

    try {
      final adapter = _getAdapter<ImageClassificationAdapter>(modelId);

      if (!adapter.isInitialized) {
        await adapter.initialize();
      }

      logger.info('Classifying image with model: $modelId');
      final result = await adapter.classify(image, threshold: threshold);
      logger.info('Classification complete. Found ${result.labels.length} labels');

      return result;
    } catch (e, stackTrace) {
      logger.error('Failed to classify image', e, stackTrace);
      rethrow;
    }
  }

  /// Detects objects in an image
  Future<List<DetectedObject>> detectObjects(
    File image, {
    String? modelId,
    double threshold = 0.5,
  }) async {
    _ensureInitialized();

    try {
      final adapter = _getAdapter<ObjectDetectionAdapter>(modelId);

      if (!adapter.isInitialized) {
        await adapter.initialize();
      }

      logger.info('Detecting objects with model: $modelId');
      final result = await adapter.detect(image, threshold: threshold);
      logger.info('Object detection complete. Found ${result.length} objects');

      return result;
    } catch (e, stackTrace) {
      logger.error('Failed to detect objects', e, stackTrace);
      rethrow;
    }
  }

  /// Runs OCR on an image
  Future<OcrResult> runOcr(
    File image, {
    String? modelId,
  }) async {
    _ensureInitialized();

    try {
      final adapter = _getAdapter<OcrAdapter>(modelId);

      if (!adapter.isInitialized) {
        await adapter.initialize();
      }

      logger.info('Running OCR with model: $modelId');
      final result = await adapter.recognize(image);
      logger.info('OCR complete. Extracted ${result.text.length} characters');

      return result;
    } catch (e, stackTrace) {
      logger.error('Failed to run OCR', e, stackTrace);
      rethrow;
    }
  }

  // ==================== Text Tasks ====================

  /// Generates text embedding
  Future<TextEmbedding> embedText(
    String text, {
    String? modelId,
  }) async {
    _ensureInitialized();

    try {
      final adapter = _getAdapter<TextEmbeddingAdapter>(modelId);

      if (!adapter.isInitialized) {
        await adapter.initialize();
      }

      logger.info('Generating embedding for text (length: ${text.length})');
      final result = await adapter.embed(text);
      logger.info('Embedding generated (dimension: ${result.dimension})');

      return result;
    } catch (e, stackTrace) {
      logger.error('Failed to generate embedding', e, stackTrace);
      rethrow;
    }
  }

  /// Classifies text
  Future<TextClassificationResult> classifyText(
    String text, {
    String? modelId,
    double threshold = 0.0,
  }) async {
    _ensureInitialized();

    try {
      final adapter = _getAdapter<TextClassificationAdapter>(modelId);

      if (!adapter.isInitialized) {
        await adapter.initialize();
      }

      logger.info('Classifying text (length: ${text.length})');
      final result = await adapter.classify(text, threshold: threshold);
      logger.info('Text classification complete. Found ${result.labels.length} labels');

      return result;
    } catch (e, stackTrace) {
      logger.error('Failed to classify text', e, stackTrace);
      rethrow;
    }
  }

  // ==================== Model Management ====================

  /// Downloads and installs a model
  Future<void> downloadAndInstallModel(String modelId) async {
    _ensureInitialized();

    try {
      logger.info('Downloading model: $modelId');
      await _modelManager.downloadModel(modelId);
      logger.info('Model downloaded successfully: $modelId');
    } catch (e, stackTrace) {
      logger.error('Failed to download model', e, stackTrace);
      rethrow;
    }
  }

  /// Gets model information
  Future<ModelInfo> getModelInfo(String modelId) async {
    _ensureInitialized();

    final adapter = _adapters[modelId];
    if (adapter != null) {
      return adapter.info();
    }

    return _modelManager.getModelInfo(modelId);
  }

  // ==================== Chat/RAG ====================

  /// Creates a chat session
  ChatSession createChatSession({
    required ChatSessionConfig config,
  }) {
    _ensureInitialized();

    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final session = ChatSession(
      id: sessionId,
      config: config,
    );

    _chatSessions[sessionId] = session;
    logger.info('Created chat session: $sessionId');

    return session;
  }

  /// Generates a chat response
  Future<ChatResponse> chatGenerate(
    ChatSession session,
    String prompt, {
    ChatOptions? options,
  }) async {
    _ensureInitialized();

    try {
      // Add user message to session
      session.addMessage(ChatMessage(
        role: ChatRole.user,
        content: prompt,
      ));

      // Get chat adapter
      final adapterId = session.config.backend.name;
      final adapter = _chatAdapters[adapterId];
      if (adapter == null) {
        throw ChatException('Chat adapter not found: $adapterId');
      }

      if (!adapter.isInitialized) {
        await adapter.initialize();
      }

      // Handle RAG if configured
      List<ScoredDocument>? retrievedDocs;
      String enhancedPrompt = prompt;

      if (session.config.retrieval != null) {
        retrievedDocs = await _performRetrieval(prompt, session.config.retrieval!);

        if (retrievedDocs.isNotEmpty) {
          final context = retrievedDocs
              .map((doc) => doc.text)
              .join('\n\n');
          enhancedPrompt = '''
Context information:
$context

User query: $prompt
''';
        }
      }

      // Build chat request
      final request = ChatRequest(
        messages: [
          if (session.config.systemPrompt != null)
            ChatMessage(
              role: ChatRole.system,
              content: session.config.systemPrompt!,
            ),
          ...session.getRecentMessages(),
        ],
        temperature: options?.temperature ?? session.config.temperature,
        maxTokens: options?.maxTokens ?? session.config.maxTokens,
        stream: options?.stream ?? false,
        modelId: session.config.modelId,
      );

      logger.info('Generating chat response for session: ${session.id}');
      final response = await adapter.generate(request);

      // Add assistant response to session
      session.addMessage(ChatMessage(
        role: ChatRole.assistant,
        content: response.text,
        metadata: response.metadata,
      ));

      logger.info('Chat response generated');

      return ChatResponse(
        text: response.text,
        streamingTokens: response.streamingTokens,
        metadata: response.metadata,
        retrievedDocuments: retrievedDocs,
        generationTimeMs: response.generationTimeMs,
      );
    } catch (e, stackTrace) {
      logger.error('Failed to generate chat response', e, stackTrace);
      rethrow;
    }
  }

  /// Performs retrieval for RAG
  Future<List<ScoredDocument>> _performRetrieval(
    String query,
    RetrievalConfig config,
  ) async {
    final vectorStore = _vectorStores[config.vectorStoreId];
    if (vectorStore == null) {
      throw VectorStoreException(
        'Vector store not found: ${config.vectorStoreId}',
      );
    }

    return vectorStore.query(
      query,
      topK: config.topK,
      minSimilarity: config.minSimilarity,
    );
  }

  /// Closes a chat session
  Future<void> closeChatSession(ChatSession session) async {
    _chatSessions.remove(session.id);
    logger.info('Closed chat session: ${session.id}');
  }

  // ==================== Utilities ====================

  /// Sets a custom logger
  void setLogger(AiLogger logger) {
    // Logger is final, but this method is kept for API compatibility
    // In practice, logger should be set during construction
    logger.warning('setLogger called but logger is immutable. Set during construction.');
  }

  /// Disposes all resources
  Future<void> dispose() async {
    logger.info('Disposing AiMlManager...');

    // Dispose adapters
    for (final adapter in _adapters.values) {
      try {
        await adapter.dispose();
      } catch (e) {
        logger.error('Error disposing adapter', e);
      }
    }

    // Dispose chat adapters
    for (final adapter in _chatAdapters.values) {
      try {
        await adapter.dispose();
      } catch (e) {
        logger.error('Error disposing chat adapter', e);
      }
    }

    // Dispose vector stores
    for (final store in _vectorStores.values) {
      try {
        await store.dispose();
      } catch (e) {
        logger.error('Error disposing vector store', e);
      }
    }

    _adapters.clear();
    _chatAdapters.clear();
    _vectorStores.clear();
    _chatSessions.clear();
    _initialized = false;

    logger.info('AiMlManager disposed');
  }

  // ==================== Private Helpers ====================

  void _ensureInitialized() {
    if (!_initialized) {
      throw InitializationException('AiMlManager not initialized. Call initialize() first.');
    }
  }

  T _getAdapter<T extends ModelAdapter>(String? modelId) {
    if (modelId == null) {
      // Try to find first adapter of type T
      final adapter = _adapters.values.whereType<T>().firstOrNull;
      if (adapter == null) {
        throw ModelNotFoundException(
          'No adapter found for type ${T.toString()}',
        );
      }
      return adapter;
    }

    final adapter = _adapters[modelId];
    if (adapter == null) {
      throw ModelNotFoundException(modelId);
    }

    if (adapter is! T) {
      throw ModelException(
        'Model $modelId is not compatible with requested type ${T.toString()}',
      );
    }

    return adapter;
  }
}
