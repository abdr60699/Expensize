import 'package:flutter/material.dart';
import 'package:ai_ml/ai_ml/ai_ml.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AiMlDemoApp());
}

class AiMlDemoApp extends StatelessWidget {
  const AiMlDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI/ML Module Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AiMlDemoHome(),
    );
  }
}

class AiMlDemoHome extends StatefulWidget {
  const AiMlDemoHome({super.key});

  @override
  State<AiMlDemoHome> createState() => _AiMlDemoHomeState();
}

class _AiMlDemoHomeState extends State<AiMlDemoHome> {
  late AiMlManager _aiMl;
  bool _isInitialized = false;
  String _status = 'Not initialized';
  final List<String> _logs = [];
  int _selectedTab = 0;

  // Sample data for vector store demo
  final List<String> _sampleDocs = [
    'Flutter is Google\'s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop.',
    'TensorFlow Lite is a lightweight solution for running machine learning models on mobile and embedded devices.',
    'Machine learning models can run efficiently on mobile devices using techniques like quantization and pruning.',
    'Vector databases enable semantic search by comparing embedding similarities using cosine distance or dot product.',
    'On-device inference provides privacy benefits and works offline, but may have limited model size.',
    'Retrieval-Augmented Generation (RAG) enhances LLM responses by providing relevant context from a knowledge base.',
    'Natural Language Processing (NLP) enables computers to understand, interpret, and generate human language.',
    'Computer vision tasks include image classification, object detection, and optical character recognition (OCR).',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAiMl();
  }

  Future<void> _initializeAiMl() async {
    try {
      _addLog('Initializing AI/ML Manager...');

      final config = AiMlConfig(
        inferencePolicy: InferencePolicy.preferOnDevice,
        enableLogging: true,
      );

      _aiMl = AiMlManager(
        config: config,
        logger: _CustomLogger(onLog: _addLog),
      );

      await _aiMl.initialize(config);

      setState(() {
        _isInitialized = true;
        _status = 'Initialized successfully';
      });

      _addLog('AI/ML Manager initialized successfully!');
    } catch (e) {
      _addLog('Error initializing: $e');
      setState(() {
        _status = 'Initialization failed: $e';
      });
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toIso8601String().substring(11, 19)}: $message');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('AI/ML Module Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isInitialized ? () => _initializeAiMl() : null,
            tooltip: 'Reinitialize',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _isInitialized ? Colors.green.shade50 : Colors.orange.shade50,
            child: Row(
              children: [
                Icon(
                  _isInitialized ? Icons.check_circle : Icons.info,
                  color: _isInitialized ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isInitialized ? Colors.green.shade900 : Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Navigation
          Container(
            color: Colors.grey.shade100,
            child: Row(
              children: [
                _buildTab('Overview', 0, Icons.dashboard),
                _buildTab('Features', 1, Icons.psychology),
                _buildTab('Architecture', 2, Icons.account_tree),
                _buildTab('Logs', 3, Icons.article),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildFeaturesTab();
      case 2:
        return _buildArchitectureTab();
      case 3:
        return _buildLogsTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCard(
          'About This Module',
          Icons.info_outline,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A production-ready Flutter package for on-device ML and cloud LLM integration with RAG support.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildFeatureItem('On-device ML', 'Image classification, object detection, OCR'),
              _buildFeatureItem('Text Processing', 'Embeddings, classification, semantic search'),
              _buildFeatureItem('Cloud LLMs', 'OpenAI, Anthropic, Vertex AI integration'),
              _buildFeatureItem('Vector Store', 'Efficient similarity search with SQLite'),
              _buildFeatureItem('RAG Patterns', 'Retrieval-Augmented Generation support'),
              _buildFeatureItem('Privacy-First', 'Offline-first capability, on-device processing'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          'Configuration',
          Icons.settings,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConfigItem('Inference Policy', InferencePolicy.preferOnDevice.name),
              _buildConfigItem('Logging', _aiMl.config.enableLogging ? 'Enabled' : 'Disabled'),
              _buildConfigItem('Initialized', _isInitialized ? 'Yes' : 'No'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          'Sample Documents',
          Icons.article,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The demo includes ${_sampleDocs.length} sample documents about ML/AI topics:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._sampleDocs.take(3).map((doc) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '• ${doc.length > 80 ? "${doc.substring(0, 80)}..." : doc}',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  )),
              Text(
                '... and ${_sampleDocs.length - 3} more',
                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCard(
          'Image Tasks',
          Icons.image,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMethodCard(
                'classifyImage',
                'Classifies images using on-device ML models',
                'ImageClassificationResult',
                ['File image', 'String? modelId', 'double threshold'],
              ),
              const SizedBox(height: 12),
              _buildMethodCard(
                'detectObjects',
                'Detects and locates objects in images',
                'List<DetectedObject>',
                ['File image', 'String? modelId', 'double threshold'],
              ),
              const SizedBox(height: 12),
              _buildMethodCard(
                'runOcr',
                'Extracts text from images using OCR',
                'OcrResult',
                ['File image', 'String? modelId'],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          'Text Tasks',
          Icons.text_fields,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMethodCard(
                'embedText',
                'Generates vector embeddings for semantic search',
                'TextEmbedding',
                ['String text', 'String? modelId'],
              ),
              const SizedBox(height: 12),
              _buildMethodCard(
                'classifyText',
                'Classifies text into predefined categories',
                'TextClassificationResult',
                ['String text', 'String? modelId', 'double threshold'],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          'Chat & RAG',
          Icons.chat,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMethodCard(
                'createChatSession',
                'Creates a new chat session with optional RAG',
                'ChatSession',
                ['ChatSessionConfig config'],
              ),
              const SizedBox(height: 12),
              _buildMethodCard(
                'chatGenerate',
                'Generates responses with context retrieval',
                'ChatResponse',
                ['ChatSession session', 'String prompt', 'ChatOptions? options'],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          'Model Management',
          Icons.cloud_download,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMethodCard(
                'downloadAndInstallModel',
                'Downloads and installs ML models',
                'Future<void>',
                ['String modelId'],
              ),
              const SizedBox(height: 12),
              _buildMethodCard(
                'getModelInfo',
                'Retrieves information about a model',
                'ModelInfo',
                ['String modelId'],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArchitectureTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCard(
          'Architecture Overview',
          Icons.account_tree,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The AI/ML module uses an adapter pattern for flexibility:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 16),
              _buildArchitectureLayer('AiMlManager', 'Main facade - coordinates all operations', Colors.purple),
              _buildArchitectureLayer('Adapters', 'Swappable providers (TFLite, ML Kit, OpenAI)', Colors.blue),
              _buildArchitectureLayer('Models', 'Data structures for inputs/outputs', Colors.green),
              _buildArchitectureLayer('Storage', 'Vector store for embeddings & similarity search', Colors.orange),
              _buildArchitectureLayer('Services', 'Chat, model management, logging', Colors.teal),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          'Supported Adapters',
          Icons.extension,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAdapterItem('TFLite Image Classification', 'On-device image classification using TensorFlow Lite'),
              _buildAdapterItem('TFLite Text Embedding', 'Generate text embeddings for semantic search'),
              _buildAdapterItem('ML Kit OCR', 'Google ML Kit text recognition'),
              _buildAdapterItem('ML Kit Object Detection', 'Google ML Kit object detection'),
              _buildAdapterItem('OpenAI Chat', 'Cloud-based chat with GPT models'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          'Data Flow',
          Icons.trending_up,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDataFlowStep(1, 'User Input', 'Text, image, or chat message'),
              _buildDataFlowStep(2, 'AiMlManager', 'Routes to appropriate adapter'),
              _buildDataFlowStep(3, 'Adapter', 'Processes with specific ML framework'),
              _buildDataFlowStep(4, 'Model', 'Structured result (labels, embeddings, etc.)'),
              _buildDataFlowStep(5, 'Application', 'Display or further processing'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_logs.length} log entries',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _logs.clear()),
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Clear'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _logs.isEmpty
              ? const Center(
                  child: Text('No logs yet'),
                )
              : ListView.builder(
                  itemCount: _logs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    final log = _logs[_logs.length - 1 - index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Text(
                        log,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCard(String title, IconData icon, Widget child) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildMethodCard(String name, String description, String returnType, List<String> params) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            'Returns: $returnType',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Parameters: ${params.join(", ")}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildArchitectureLayer(String name, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdapterItem(String name, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.extension, size: 18, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataFlowStep(int step, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              '$step',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _aiMl.dispose();
    super.dispose();
  }
}

/// Custom logger implementation for the demo
class _CustomLogger implements AiLogger {
  final Function(String) onLog;

  const _CustomLogger({required this.onLog});

  @override
  void info(String message, [dynamic data]) {
    onLog('INFO: $message');
  }

  @override
  void warning(String message, [dynamic data]) {
    onLog('WARN: $message');
  }

  @override
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    onLog('ERROR: $message${error != null ? " - $error" : ""}');
  }

  @override
  void debug(String message, [dynamic data]) {
    onLog('DEBUG: $message');
  }
}
