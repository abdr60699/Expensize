/// AI/ML Utility Module for Flutter
///
/// A production-ready Flutter package for on-device ML and cloud LLM integration
/// with RAG (Retrieval-Augmented Generation) support.
///
/// ## Features
/// - On-device ML for image classification, object detection, and OCR
/// - Text embeddings and classification
/// - Cloud LLM integration (OpenAI, Anthropic, etc.)
/// - Vector store for efficient similarity search
/// - RAG patterns for enhanced chat responses
/// - Adapter architecture for swappable providers
/// - Privacy-first design with offline-first capability
///
/// ## Usage
///
/// ```dart
/// // Initialize the manager
/// final aiMl = AiMlManager(
///   config: AiMlConfig(
///     inferencePolicy: InferencePolicy.preferOnDevice,
///     enableLogging: true,
///   ),
/// );
/// await aiMl.initialize(config);
///
/// // Register adapters
/// aiMl.registerAdapter('image_classifier', imageClassificationAdapter);
/// aiMl.registerChatAdapter('openai', openAiAdapter);
///
/// // Use image classification
/// final result = await aiMl.classifyImage(imageFile);
///
/// // Use chat with RAG
/// final session = aiMl.createChatSession(
///   config: ChatSessionConfig(
///     backend: ModelProvider.openai,
///     retrieval: RetrievalConfig(vectorStoreId: 'my-docs'),
///   ),
/// );
/// final response = await aiMl.chatGenerate(session, 'What is X?');
/// ```
library ai_ml;

// Core service
export 'services/ai_ml_manager.dart';
export 'services/model_manager.dart';
export 'services/chat_service.dart';

// Models
export 'models/models.dart';

// Adapters
export 'services/adapters/model_adapter.dart';
export 'services/adapters/chat_adapter.dart';
export 'services/adapters/tflite_image_classification_adapter.dart';
export 'services/adapters/tflite_text_embedding_adapter.dart';
export 'services/adapters/mlkit_ocr_adapter.dart';
export 'services/adapters/mlkit_object_detection_adapter.dart';
export 'services/adapters/openai_chat_adapter.dart';

// Storage
export 'storage/vector_store.dart';

// Utilities
export 'utils/logger.dart';

// Errors
export 'errors/ai_ml_exceptions.dart';
