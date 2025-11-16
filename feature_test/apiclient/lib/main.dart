import 'package:flutter/material.dart';
import 'package:apiclient/api_client/api_client.dart';

void main() {
  runApp(const ApiClientDemoApp());
}

class ApiClientDemoApp extends StatelessWidget {
  const ApiClientDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Client Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ApiClientDemoHome(),
    );
  }
}

class ApiClientDemoHome extends StatefulWidget {
  const ApiClientDemoHome({super.key});

  @override
  State<ApiClientDemoHome> createState() => _ApiClientDemoHomeState();
}

class _ApiClientDemoHomeState extends State<ApiClientDemoHome> {
  late ApiClient _apiClient;
  bool _isInitialized = false;
  String _status = 'Not initialized';
  final List<String> _logs = [];
  int _selectedTab = 0;
  int _requestCount = 0;
  String _baseUrl = 'https://jsonplaceholder.typicode.com';

  // Sample endpoints for demonstration
  final List<Map<String, dynamic>> _sampleEndpoints = [
    {
      'name': 'Get Posts',
      'method': 'GET',
      'endpoint': '/posts',
      'description': 'Fetch list of posts',
    },
    {
      'name': 'Get Single Post',
      'method': 'GET',
      'endpoint': '/posts/1',
      'description': 'Fetch post with ID 1',
    },
    {
      'name': 'Create Post',
      'method': 'POST',
      'endpoint': '/posts',
      'description': 'Create a new post',
    },
    {
      'name': 'Update Post',
      'method': 'PUT',
      'endpoint': '/posts/1',
      'description': 'Update post with ID 1',
    },
    {
      'name': 'Delete Post',
      'method': 'DELETE',
      'endpoint': '/posts/1',
      'description': 'Delete post with ID 1',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeApiClient();
  }

  Future<void> _initializeApiClient() async {
    try {
      _addLog('Initializing API Client...');

      final config = ApiClientConfig(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        enableLogging: true,
        enableRetry: true,
        maxRetries: 3,
      );

      _apiClient = ApiClient(config: config);

      setState(() {
        _isInitialized = true;
        _status = 'Initialized successfully';
      });

      _addLog('✅ API Client initialized!');
      _addLog('Base URL: $_baseUrl');
      _addLog('Logging: Enabled');
      _addLog('Retry: Enabled (max 3)');
    } catch (e) {
      _addLog('❌ Error initializing: $e');
      setState(() {
        _status = 'Initialization failed: $e';
      });
    }
  }

  void _addLog(String message) {
    setState(() {
      final timestamp = DateTime.now().toIso8601String().substring(11, 19);
      _logs.add('$timestamp: $message');
    });
  }

  Future<void> _makeRequest(int index) async {
    if (!_isInitialized) {
      _addLog('⚠️ API Client not initialized');
      return;
    }

    final sample = _sampleEndpoints[index];
    _addLog('📤 Making ${sample['method']} request to ${sample['endpoint']}');

    try {
      ApiResponse<dynamic> response;

      switch (sample['method']) {
        case 'GET':
          response = await _apiClient.get(sample['endpoint'] as String);
          break;
        case 'POST':
          response = await _apiClient.post(
            sample['endpoint'] as String,
            data: {
              'title': 'Demo Post',
              'body': 'This is a demo post created by API Client',
              'userId': 1,
            },
          );
          break;
        case 'PUT':
          response = await _apiClient.put(
            sample['endpoint'] as String,
            data: {
              'id': 1,
              'title': 'Updated Post',
              'body': 'This post has been updated',
              'userId': 1,
            },
          );
          break;
        case 'DELETE':
          response = await _apiClient.delete(sample['endpoint'] as String);
          break;
        default:
          _addLog('❌ Unknown method: ${sample['method']}');
          return;
      }

      setState(() {
        _requestCount++;
      });

      if (response.success) {
        _addLog('✅ Success: ${sample['name']}');
        _addLog('Status: ${response.statusCode}');
        if (response.data != null) {
          final dataStr = response.data.toString();
          _addLog('Data: ${dataStr.length > 100 ? '${dataStr.substring(0, 100)}...' : dataStr}');
        }
      } else {
        _addLog('❌ Error: ${response.error?.message}');
        _addLog('Code: ${response.error?.code}');
      }
    } catch (e) {
      _addLog('❌ Exception: $e');
    }
  }

  Future<void> _testPagination() async {
    _addLog('📄 Testing pagination...');

    try {
      final response = await _apiClient.get(
        '/posts',
        queryParameters: {'_page': 1, '_limit': 10},
      );

      if (response.success) {
        _addLog('✅ Fetched page 1 with 10 items');
        _addLog('Status: ${response.statusCode}');
      } else {
        _addLog('❌ Pagination failed: ${response.error?.message}');
      }

      setState(() {
        _requestCount++;
      });
    } catch (e) {
      _addLog('❌ Exception: $e');
    }
  }

  Future<void> _testErrorHandling() async {
    _addLog('🔧 Testing error handling...');

    try {
      final response = await _apiClient.get('/invalid-endpoint-404');

      if (response.success) {
        _addLog('✅ Unexpected success');
      } else {
        _addLog('✅ Error handled correctly');
        _addLog('Error: ${response.error?.message}');
        _addLog('Code: ${response.error?.code}');
        _addLog('Retryable: ${response.error?.isRetryable}');
      }

      setState(() {
        _requestCount++;
      });
    } catch (e) {
      _addLog('❌ Exception: $e');
    }
  }

  Future<void> _changeBaseUrl() async {
    final controller = TextEditingController(text: _baseUrl);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Base URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Base URL',
            hintText: 'https://api.example.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Change'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _baseUrl = result;
        _isInitialized = false;
      });
      await _initializeApiClient();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('API Client Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.link),
            onPressed: _changeBaseUrl,
            tooltip: 'Change Base URL',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeApiClient,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatChip('Requests', _requestCount.toString(), Icons.http),
                    const SizedBox(width: 8),
                    _buildStatChip('Base', _baseUrl.split('/').last, Icons.cloud),
                  ],
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
                _buildTab('Requests', 1, Icons.api),
                _buildTab('Features', 2, Icons.stars),
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

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
        return _buildRequestsTab();
      case 2:
        return _buildFeaturesTab();
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
                'Production-ready API client using Dio with comprehensive features for modern Flutter apps.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildFeatureItem('Type-Safe Responses', 'Generic response wrapper with error handling'),
              _buildFeatureItem('Auto Retry', 'Exponential backoff on transient failures'),
              _buildFeatureItem('Token Management', 'Automatic token injection and refresh'),
              _buildFeatureItem('Request/Response Logging', 'Debug-friendly logging interceptor'),
              _buildFeatureItem('File Upload/Download', 'Progress tracking support'),
              _buildFeatureItem('Pagination Helpers', 'Built-in pagination utilities'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          'Current Configuration',
          Icons.settings,
          Column(
            children: [
              _buildConfigItem('Base URL', _baseUrl),
              _buildConfigItem('Timeout', '30 seconds'),
              _buildConfigItem('Retry Enabled', 'Yes (max 3)'),
              _buildConfigItem('Logging', 'Enabled'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          'Quick Actions',
          Icons.flash_on,
          Column(
            children: [
              _buildActionButton(
                'Test Pagination',
                Icons.pages,
                _testPagination,
                Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                'Test Error Handling',
                Icons.error_outline,
                _testErrorHandling,
                Colors.orange,
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                'Change Base URL',
                Icons.link,
                _changeBaseUrl,
                Colors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCard(
          'Sample Requests',
          Icons.api,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Try these pre-configured HTTP requests:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 16),
              ...List.generate(_sampleEndpoints.length, (index) {
                final endpoint = _sampleEndpoints[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildRequestCard(
                    endpoint['name'] as String,
                    endpoint['method'] as String,
                    endpoint['endpoint'] as String,
                    endpoint['description'] as String,
                    () => _makeRequest(index),
                  ),
                );
              }),
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
          'Core Features',
          Icons.stars,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeatureDetail(
                'Interceptors',
                'Auth, Logging, and Retry interceptors for complete request lifecycle management',
                Icons.filter_list,
                Colors.blue,
              ),
              const Divider(),
              _buildFeatureDetail(
                'Error Handling',
                'Standardized error responses with retry logic for transient failures',
                Icons.error,
                Colors.red,
              ),
              const Divider(),
              _buildFeatureDetail(
                'Token Management',
                'Automatic token injection and refresh flow integration',
                Icons.key,
                Colors.green,
              ),
              const Divider(),
              _buildFeatureDetail(
                'Type Safety',
                'Generic responses with JSON serialization support',
                Icons.code,
                Colors.purple,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          'HTTP Methods',
          Icons.http,
          Column(
            children: [
              _buildMethodItem('GET', 'Retrieve resources', Colors.green),
              _buildMethodItem('POST', 'Create new resources', Colors.blue),
              _buildMethodItem('PUT', 'Update resources', Colors.orange),
              _buildMethodItem('PATCH', 'Partial updates', Colors.teal),
              _buildMethodItem('DELETE', 'Remove resources', Colors.red),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          'Error Types',
          Icons.bug_report,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildErrorType('Network Error', 'Connection failures', true),
              _buildErrorType('Timeout', 'Request timed out', true),
              _buildErrorType('Unauthorized (401)', 'Authentication required', false),
              _buildErrorType('Not Found (404)', 'Resource not found', false),
              _buildErrorType('Validation (422)', 'Invalid data', false),
              _buildErrorType('Server Error (5xx)', 'Server-side issues', true),
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
              ? const Center(child: Text('No logs yet'))
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
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
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

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isInitialized ? onPressed : null,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    String name,
    String method,
    String endpoint,
    String description,
    VoidCallback onTap,
  ) {
    Color methodColor;
    switch (method) {
      case 'GET':
        methodColor = Colors.green;
        break;
      case 'POST':
        methodColor = Colors.blue;
        break;
      case 'PUT':
        methodColor = Colors.orange;
        break;
      case 'DELETE':
        methodColor = Colors.red;
        break;
      default:
        methodColor = Colors.grey;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: methodColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                method,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
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
                  const SizedBox(height: 2),
                  Text(
                    endpoint,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontFamily: 'monospace'),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_arrow, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureDetail(String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
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
                const SizedBox(height: 4),
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

  Widget _buildMethodItem(String method, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              method,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorType(String type, String description, bool retryable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            retryable ? Icons.refresh : Icons.block,
            color: retryable ? Colors.orange : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  '$description ${retryable ? '(Retryable)' : '(Not Retryable)'}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
