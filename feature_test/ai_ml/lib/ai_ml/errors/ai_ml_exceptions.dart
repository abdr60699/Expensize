/// Base exception for AI/ML module
class AiMlException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AiMlException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('AiMlException: $message');
    if (code != null) buffer.write(' (code: $code)');
    if (originalError != null) buffer.write('\nOriginal error: $originalError');
    return buffer.toString();
  }
}

/// Exception for model-related errors
class ModelException extends AiMlException {
  const ModelException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'ModelException: $message';
}

/// Exception for model not found
class ModelNotFoundException extends ModelException {
  final String modelId;

  const ModelNotFoundException(
    this.modelId, {
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super('Model not found: $modelId');
}

/// Exception for model download errors
class ModelDownloadException extends ModelException {
  const ModelDownloadException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception for inference errors
class InferenceException extends AiMlException {
  const InferenceException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'InferenceException: $message';
}

/// Exception for initialization errors
class InitializationException extends AiMlException {
  const InitializationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'InitializationException: $message';
}

/// Exception for vector store errors
class VectorStoreException extends AiMlException {
  const VectorStoreException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'VectorStoreException: $message';
}

/// Exception for chat/LLM errors
class ChatException extends AiMlException {
  const ChatException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'ChatException: $message';
}

/// Exception for API/network errors
class ApiException extends AiMlException {
  final int? statusCode;

  const ApiException(
    super.message, {
    this.statusCode,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ApiException: $message');
    if (statusCode != null) buffer.write(' (HTTP $statusCode)');
    return buffer.toString();
  }
}

/// Exception for unsupported operations
class UnsupportedOperationException extends AiMlException {
  const UnsupportedOperationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'UnsupportedOperationException: $message';
}

/// Exception for invalid configuration
class ConfigurationException extends AiMlException {
  const ConfigurationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'ConfigurationException: $message';
}
