import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/chat_models.dart';
import '../../errors/ai_ml_exceptions.dart';
import 'chat_adapter.dart';

/// OpenAI Chat API adapter
class OpenAiChatAdapter extends BaseChatAdapter {
  final String apiKey;
  final String baseUrl;
  final String model;

  static const String _defaultBaseUrl = 'https://api.openai.com/v1';
  static const String _defaultModel = 'gpt-3.5-turbo';

  OpenAiChatAdapter({
    required this.apiKey,
    this.baseUrl = _defaultBaseUrl,
    this.model = _defaultModel,
  });

  @override
  String get provider => 'openai';

  @override
  String get defaultModel => model;

  @override
  bool get supportsStreaming => true;

  @override
  Future<ChatResponse> generate(ChatRequest request) async {
    if (!isInitialized) {
      throw ChatException('Adapter not initialized');
    }

    validateRequest(request);

    final startTime = DateTime.now();

    try {
      final messages = _buildMessages(request);
      final requestBody = {
        'model': request.modelId ?? model,
        'messages': messages,
        'temperature': request.temperature,
        if (request.maxTokens != null) 'max_tokens': request.maxTokens,
        if (request.stopSequences != null) 'stop': request.stopSequences,
        'stream': request.stream,
      };

      if (request.stream) {
        return await _generateStreaming(requestBody, startTime);
      } else {
        return await _generateNonStreaming(requestBody, startTime);
      }
    } catch (e, stackTrace) {
      if (e is ChatException) rethrow;
      throw ChatException(
        'Failed to generate chat response',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<ChatResponse> _generateNonStreaming(
    Map<String, dynamic> requestBody,
    DateTime startTime,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        'OpenAI API error: ${response.body}',
        statusCode: response.statusCode,
      );
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    final choice = responseData['choices'][0] as Map<String, dynamic>;
    final message = choice['message'] as Map<String, dynamic>;
    final content = message['content'] as String;

    final usage = responseData['usage'] as Map<String, dynamic>?;
    final generationTime = DateTime.now().difference(startTime).inMilliseconds;

    return ChatResponse(
      text: content,
      metadata: {
        'model': responseData['model'],
        'usage': usage,
        'finish_reason': choice['finish_reason'],
      },
      generationTimeMs: generationTime,
    );
  }

  Future<ChatResponse> _generateStreaming(
    Map<String, dynamic> requestBody,
    DateTime startTime,
  ) async {
    final request = http.Request(
      'POST',
      Uri.parse('$baseUrl/chat/completions'),
    );

    request.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    });

    request.body = jsonEncode(requestBody);

    final client = http.Client();
    final streamedResponse = await client.send(request);

    if (streamedResponse.statusCode != 200) {
      final responseBody = await streamedResponse.stream.bytesToString();
      client.close();
      throw ApiException(
        'OpenAI API error: $responseBody',
        statusCode: streamedResponse.statusCode,
      );
    }

    final textBuffer = StringBuffer();
    final streamController = StreamController<String>();

    streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
      (line) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          if (data == '[DONE]') {
            streamController.close();
            client.close();
            return;
          }

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final delta = json['choices'][0]['delta'] as Map<String, dynamic>;
            final content = delta['content'] as String?;

            if (content != null) {
              textBuffer.write(content);
              streamController.add(content);
            }
          } catch (e) {
            // Ignore parsing errors for incomplete chunks
          }
        }
      },
      onError: (error) {
        streamController.addError(error);
        client.close();
      },
      onDone: () {
        if (!streamController.isClosed) {
          streamController.close();
        }
        client.close();
      },
    );

    return ChatResponse(
      text: '', // Will be filled as stream progresses
      streamingTokens: streamController.stream,
      metadata: {'streaming': true},
    );
  }

  List<Map<String, String>> _buildMessages(ChatRequest request) {
    final messages = <Map<String, String>>[];

    // Add system prompt if provided
    final systemPrompt = buildSystemPrompt(request);
    if (systemPrompt != null) {
      messages.add({
        'role': 'system',
        'content': systemPrompt,
      });
    }

    // Add conversation messages
    final conversationMessages = getConversationMessages(request);
    for (final msg in conversationMessages) {
      messages.add({
        'role': msg.role.name,
        'content': msg.content,
      });
    }

    return messages;
  }
}
