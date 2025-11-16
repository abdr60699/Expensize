import 'package:flutter/material.dart';
import 'package:offline/connectivity_offline/offline_support.dart';
import 'package:offline/connectivity_offline/config/offline_config.dart';
import 'package:offline/connectivity_offline/models/cache_metadata.dart';
import 'package:offline/connectivity_offline/models/offline_request.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the offline support module
  await OfflineSupport.initialize(
    config: OfflineConfig.development(),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Support Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const OfflineDemo(),
    );
  }
}

class OfflineDemo extends StatefulWidget {
  const OfflineDemo({super.key});

  @override
  State<OfflineDemo> createState() => _OfflineDemoState();
}

class _OfflineDemoState extends State<OfflineDemo> {
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  String _status = 'Ready';
  List<String> _cacheKeys = [];
  List<String> _queuedRequests = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final cacheBox = Hive.box('offline_cache');
    final queueBox = Hive.box('offline_queue');

    setState(() {
      _cacheKeys = cacheBox.keys.cast<String>().toList();
      _queuedRequests = queueBox.keys.cast<String>().toList();
    });
  }

  Future<void> _addToCache() async {
    if (_keyController.text.isEmpty || _valueController.text.isEmpty) {
      _showMessage('Please enter both key and value');
      return;
    }

    try {
      final cacheBox = Hive.box('offline_cache');
      final metadataBox = Hive.box('offline_metadata');

      final metadata = CacheMetadata(
        key: _keyController.text,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        sizeInBytes: _valueController.text.length,
        lastAccessedAt: DateTime.now(),
      );

      final entry = CacheEntry(
        key: _keyController.text,
        data: _valueController.text,
        metadata: metadata,
      );

      await cacheBox.put(_keyController.text, entry);
      await metadataBox.put(_keyController.text, metadata);

      _showMessage('Added to cache: ${_keyController.text}');
      _keyController.clear();
      _valueController.clear();
      await _refreshData();
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  Future<void> _addToQueue() async {
    if (_keyController.text.isEmpty) {
      _showMessage('Please enter a URL in the key field');
      return;
    }

    try {
      final queueBox = Hive.box('offline_queue');

      final request = OfflineRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        method: 'POST',
        url: _keyController.text,
        body: _valueController.text,
        createdAt: DateTime.now(),
        priority: RequestPriority.normal,
      );

      await queueBox.add(request);

      _showMessage('Added to queue: ${request.method} ${request.url}');
      _keyController.clear();
      _valueController.clear();
      await _refreshData();
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  Future<void> _viewCacheItem(String key) async {
    try {
      final cacheBox = Hive.box('offline_cache');
      final entry = cacheBox.get(key) as CacheEntry?;

      if (entry != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Cache Entry: $key'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Key: ${entry.key}'),
                  const SizedBox(height: 8),
                  Text('Data: ${entry.data}'),
                  const SizedBox(height: 8),
                  Text('Created: ${entry.metadata.createdAt}'),
                  Text('Expires: ${entry.metadata.expiresAt}'),
                  Text('Size: ${entry.metadata.sizeInBytes} bytes'),
                  Text('Accessed: ${entry.metadata.accessCount} times'),
                  Text('Is Expired: ${entry.isExpired}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showMessage('Error viewing item: $e');
    }
  }

  Future<void> _clearCache() async {
    try {
      await OfflineSupport.clearAllData();
      _showMessage('All offline data cleared');
      await _refreshData();
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  void _showMessage(String message) {
    setState(() {
      _status = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Offline Support Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearCache,
            tooltip: 'Clear All Data',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Status: $_status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(
                labelText: 'Key / URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: 'Value / Body',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addToCache,
                    icon: const Icon(Icons.add),
                    label: const Text('Add to Cache'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addToQueue,
                    icon: const Icon(Icons.queue),
                    label: const Text('Add to Queue'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Cached Items (${_cacheKeys.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _cacheKeys.isEmpty
                  ? const Center(child: Text('No cached items'))
                  : ListView.builder(
                      itemCount: _cacheKeys.length,
                      itemBuilder: (context, index) {
                        final key = _cacheKeys[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.storage),
                            title: Text(key),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _viewCacheItem(key),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              'Queued Requests (${_queuedRequests.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _queuedRequests.isEmpty
                  ? const Center(child: Text('No queued requests'))
                  : ValueListenableBuilder(
                      valueListenable: Hive.box('offline_queue').listenable(),
                      builder: (context, Box box, _) {
                        return ListView.builder(
                          itemCount: box.length,
                          itemBuilder: (context, index) {
                            final request = box.getAt(index) as OfflineRequest;
                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  Icons.cloud_upload,
                                  color: request.priorityLevel == RequestPriority.high
                                      ? Colors.red
                                      : request.priorityLevel == RequestPriority.normal
                                          ? Colors.blue
                                          : Colors.grey,
                                ),
                                title: Text('${request.method} ${request.url}'),
                                subtitle: Text(
                                  'Created: ${request.createdAt}\nRetries: ${request.retryCount}',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }
}
