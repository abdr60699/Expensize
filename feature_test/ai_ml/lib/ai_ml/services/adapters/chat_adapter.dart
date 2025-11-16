import '../../models/chat_models.dart';

/// Request for chat generation
class ChatRequest {
  /// List of messages in the conversation
  final List<ChatMessage> messages;

  /// System prompt (optional, may be in messages)
  final String? systemPrompt;

  /// Temperature for generation
  final double temperature;

  /// Maximum tokens to generate
  final int? maxTokens;

  /// Stop sequences
  final List<String>? stopSequences;

  /// Enable streaming
  final bool stream;

  /// Model ID to use
  final String? modelId;

  /// Additional parameters
  final Map<String, dynamic>? additionalParams;

  const ChatRequest({
    required this.messages,
    this.systemPrompt,
    this.temperature = 0.7,
    this.maxTokens,
    this.stopSequences,
    this.stream = false,
    this.modelId,
    this.additionalParams,
  });

  ChatRequest copyWith({
    List<ChatMessage>? messages,
    String? systemPrompt,
    double? temperature,
    int? maxTokens,
    List<String>? stopSequences,
    bool? stream,
    String? modelId,
    Map<String, dynamic>? additionalParams,
  }) {
    return ChatRequest(
      messages: messages ?? this.messages,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      stopSequences: stopSequences ?? this.stopSequences,
      stream: stream ?? this.stream,
      modelId: modelId ?? this.modelId,
      additionalParams: additionalParams ?? this.additionalParams,
    );
  }
}

/// Interface for chat/LLM adapters
abstract class ChatAdapter {
  /// Provider name
  String get provider;

  /// Default model ID
  String get defaultModel;

  /// Initializes the adapter
  Future<void> initialize();

  /// Generates a chat response
  Future<ChatResponse> generate(ChatRequest request);

  /// Checks if streaming is supported
  bool get supportsStreaming;

  /// Disposes resources
  Future<void> dispose();
}

/// Base implementation with common functionality
abstract class BaseChatAdapter implements ChatAdapter {
  bool _initialized = false;

  @override
  bool get supportsStreaming => false;

  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }

  /// Validates the request
  void validateRequest(ChatRequest request) {
    if (request.messages.isEmpty) {
      throw ArgumentError('Messages cannot be empty');
    }
    if (request.temperature < 0.0 || request.temperature > 1.0) {
      throw ArgumentError('Temperature must be between 0.0 and 1.0');
    }
  }

  /// Builds system prompt if needed
  String? buildSystemPrompt(ChatRequest request) {
    if (request.systemPrompt != null) {
      return request.systemPrompt;
    }

    // Check if first message is a system message
    if (request.messages.isNotEmpty &&
        request.messages.first.role == ChatRole.system) {
      return request.messages.first.content;
    }

    return null;
  }

  /// Gets conversation messages (excluding system prompt if already extracted)
  List<ChatMessage> getConversationMessages(ChatRequest request) {
    if (request.systemPrompt != null &&
        request.messages.isNotEmpty &&
        request.messages.first.role == ChatRole.system) {
      return request.messages.sublist(1);
    }
    return request.messages;
  }
}
