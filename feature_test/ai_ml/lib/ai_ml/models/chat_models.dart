import 'vector_store_models.dart';

/// Configuration for AI/ML manager
class AiMlConfig {
  /// Inference policy (prefer on-device, cloud, etc.)
  final InferencePolicy inferencePolicy;

  /// Enable logging
  final bool enableLogging;

  /// Cache directory path
  final String? cacheDir;

  /// Maximum cache size in bytes
  final int? maxCacheSizeBytes;

  /// API keys for cloud services
  final Map<String, String>? apiKeys;

  /// Model configuration overrides
  final Map<String, dynamic>? modelConfig;

  const AiMlConfig({
    this.inferencePolicy = InferencePolicy.preferOnDevice,
    this.enableLogging = false,
    this.cacheDir,
    this.maxCacheSizeBytes,
    this.apiKeys,
    this.modelConfig,
  });

  AiMlConfig copyWith({
    InferencePolicy? inferencePolicy,
    bool? enableLogging,
    String? cacheDir,
    int? maxCacheSizeBytes,
    Map<String, String>? apiKeys,
    Map<String, dynamic>? modelConfig,
  }) {
    return AiMlConfig(
      inferencePolicy: inferencePolicy ?? this.inferencePolicy,
      enableLogging: enableLogging ?? this.enableLogging,
      cacheDir: cacheDir ?? this.cacheDir,
      maxCacheSizeBytes: maxCacheSizeBytes ?? this.maxCacheSizeBytes,
      apiKeys: apiKeys ?? this.apiKeys,
      modelConfig: modelConfig ?? this.modelConfig,
    );
  }
}

/// Inference policy enum
enum InferencePolicy {
  /// Prefer on-device inference, fallback to cloud
  preferOnDevice,

  /// Prefer cloud inference, fallback to on-device
  preferCloud,

  /// Only use on-device inference
  onDeviceOnly,

  /// Only use cloud inference
  cloudOnly,
}

/// Model provider for chat/LLM
enum ModelProvider {
  /// OpenAI (GPT models)
  openai,

  /// Anthropic (Claude models)
  anthropic,

  /// Google Vertex AI
  vertexAi,

  /// Azure OpenAI
  azureOpenai,

  /// On-device LLM
  onDevice,

  /// Custom/other provider
  custom,
}

/// Configuration for chat session
class ChatSessionConfig {
  /// Retrieval configuration for RAG
  final RetrievalConfig? retrieval;

  /// Model provider backend
  final ModelProvider backend;

  /// Use on-device model if available
  final bool useOnDeviceModel;

  /// Model ID to use
  final String? modelId;

  /// System prompt
  final String? systemPrompt;

  /// Maximum conversation history to maintain
  final int maxHistoryMessages;

  /// Temperature for generation (0.0 to 1.0)
  final double temperature;

  /// Maximum tokens to generate
  final int? maxTokens;

  /// Additional configuration
  final Map<String, dynamic>? additionalConfig;

  const ChatSessionConfig({
    this.retrieval,
    this.backend = ModelProvider.openai,
    this.useOnDeviceModel = false,
    this.modelId,
    this.systemPrompt,
    this.maxHistoryMessages = 10,
    this.temperature = 0.7,
    this.maxTokens,
    this.additionalConfig,
  });

  ChatSessionConfig copyWith({
    RetrievalConfig? retrieval,
    ModelProvider? backend,
    bool? useOnDeviceModel,
    String? modelId,
    String? systemPrompt,
    int? maxHistoryMessages,
    double? temperature,
    int? maxTokens,
    Map<String, dynamic>? additionalConfig,
  }) {
    return ChatSessionConfig(
      retrieval: retrieval ?? this.retrieval,
      backend: backend ?? this.backend,
      useOnDeviceModel: useOnDeviceModel ?? this.useOnDeviceModel,
      modelId: modelId ?? this.modelId,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      maxHistoryMessages: maxHistoryMessages ?? this.maxHistoryMessages,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      additionalConfig: additionalConfig ?? this.additionalConfig,
    );
  }
}

/// Configuration for retrieval (RAG)
class RetrievalConfig {
  /// Vector store to use for retrieval
  final String vectorStoreId;

  /// Number of documents to retrieve
  final int topK;

  /// Minimum similarity threshold
  final double minSimilarity;

  /// Whether to include document metadata in context
  final bool includeMetadata;

  /// Maximum chunk size for documents
  final int maxChunkSize;

  /// Overlap between chunks
  final int chunkOverlap;

  const RetrievalConfig({
    required this.vectorStoreId,
    this.topK = 3,
    this.minSimilarity = 0.7,
    this.includeMetadata = true,
    this.maxChunkSize = 500,
    this.chunkOverlap = 50,
  });
}

/// Represents a chat session
class ChatSession {
  /// Unique session ID
  final String id;

  /// Session configuration
  final ChatSessionConfig config;

  /// Conversation history
  final List<ChatMessage> messages;

  /// Session metadata
  final Map<String, dynamic>? metadata;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  DateTime updatedAt;

  ChatSession({
    required this.id,
    required this.config,
    List<ChatMessage>? messages,
    this.metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : messages = messages ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Adds a message to the session
  void addMessage(ChatMessage message) {
    messages.add(message);
    updatedAt = DateTime.now();
  }

  /// Gets recent messages based on config
  List<ChatMessage> getRecentMessages() {
    if (messages.length <= config.maxHistoryMessages) {
      return messages;
    }
    return messages.sublist(messages.length - config.maxHistoryMessages);
  }
}

/// Chat message
class ChatMessage {
  /// Message role (user, assistant, system)
  final ChatRole role;

  /// Message content
  final String content;

  /// Timestamp
  final DateTime timestamp;

  /// Optional metadata (citations, sources, etc.)
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? const _DefaultTimestamp();

  Map<String, dynamic> toJson() {
    return {
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: ChatRole.values.firstWhere((r) => r.name == json['role']),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Workaround for const DateTime
class _DefaultTimestamp extends DateTime {
  const _DefaultTimestamp() : super.fromMillisecondsSinceEpoch(0);
}

/// Chat message role
enum ChatRole {
  user,
  assistant,
  system,
}

/// Response from chat generation
class ChatResponse {
  /// Generated text
  final String text;

  /// Streaming tokens (if streaming is enabled)
  final Stream<String>? streamingTokens;

  /// Metadata (model used, tokens, citations, etc.)
  final Map<String, dynamic>? metadata;

  /// Retrieved documents (for RAG)
  final List<ScoredDocument>? retrievedDocuments;

  /// Generation time in milliseconds
  final int? generationTimeMs;

  const ChatResponse({
    required this.text,
    this.streamingTokens,
    this.metadata,
    this.retrievedDocuments,
    this.generationTimeMs,
  });

  /// Gets citations from metadata
  List<String>? get citations {
    if (metadata?['citations'] != null) {
      return (metadata!['citations'] as List).cast<String>();
    }
    return retrievedDocuments?.map((doc) => doc.id).toList();
  }
}

/// Options for chat generation
class ChatOptions {
  /// Enable streaming
  final bool stream;

  /// Override temperature
  final double? temperature;

  /// Override max tokens
  final int? maxTokens;

  /// Additional stop sequences
  final List<String>? stopSequences;

  /// Override retrieval settings
  final RetrievalConfig? retrievalOverride;

  const ChatOptions({
    this.stream = false,
    this.temperature,
    this.maxTokens,
    this.stopSequences,
    this.retrievalOverride,
  });
}
