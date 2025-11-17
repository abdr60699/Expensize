import 'package:flutter/material.dart';
import 'package:analytics/analytics_logging/analytics_logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AnalyticsDemoApp());
}

class AnalyticsDemoApp extends StatelessWidget {
  const AnalyticsDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analytics & Logging Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AnalyticsDemoHome(),
    );
  }
}

class AnalyticsDemoHome extends StatefulWidget {
  const AnalyticsDemoHome({super.key});

  @override
  State<AnalyticsDemoHome> createState() => _AnalyticsDemoHomeState();
}

class _AnalyticsDemoHomeState extends State<AnalyticsDemoHome> {
  late AnalyticsManager _analyticsManager;
  late ErrorLogger _errorLogger;
  late ConsentManager _consentManager;

  bool _isInitialized = false;
  String _status = 'Not initialized';
  final List<String> _logs = [];
  int _selectedTab = 0;
  int _eventCount = 0;
  String? _userId;

  // Sample events for demonstration
  final List<Map<String, dynamic>> _sampleEvents = [
    {
      'name': 'button_click',
      'params': {'button_id': 'demo_button', 'screen': 'home'}
    },
    {
      'name': 'screen_view',
      'params': {'screen_name': 'DemoScreen', 'screen_class': 'Demo'}
    },
    {
      'name': 'purchase',
      'params': {'value': 99.99, 'currency': 'USD', 'items': 3}
    },
    {
      'name': 'search',
      'params': {'search_term': 'flutter analytics', 'results': 42}
    },
    {
      'name': 'level_up',
      'params': {'character': 'demo_user', 'level': 5}
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnalytics();
  }

  Future<void> _initializeAnalytics() async {
    try {
      _addLog('Initializing Analytics & Logging...');

      // Initialize consent manager
      _consentManager = ConsentManager();
      await _consentManager.initialize();

      // Get current consent
      final hasConsent = await _consentManager.hasAnalyticsConsent();
      _addLog('Analytics consent: ${hasConsent ? "granted" : "not granted"}');

      // Create privacy config
      final privacyConfig = PrivacyConfig(
        analyticsEnabled: hasConsent,
        errorReportingEnabled: hasConsent,
        enableDebugLogging: true,
      );

      // Initialize analytics manager (mock providers for demo)
      _analyticsManager = AnalyticsManager(
        providers: [], // In production: add Firebase, etc.
        privacyConfig: privacyConfig,
      );

      await _analyticsManager.initialize();

      // Initialize error logger (mock providers for demo)
      _errorLogger = ErrorLogger(
        providers: [], // In production: add Sentry, Crashlytics
      );

      await _errorLogger.initialize();

      setState(() {
        _isInitialized = true;
        _status = 'Initialized successfully (Demo Mode)';
      });

      _addLog('✅ Analytics & Logging initialized!');
      _addLog('Note: Running in demo mode without real providers');
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

  Future<void> _logSampleEvent(int index) async {
    if (!_isInitialized) {
      _addLog('⚠️ Analytics not initialized');
      return;
    }

    final sample = _sampleEvents[index];
    final event = AnalyticsEvent.custom(
      name: sample['name'] as String,
      parameters: sample['params'] as Map<String, dynamic>,
    );

    await _analyticsManager.logEvent(event);

    setState(() {
      _eventCount++;
    });

    _addLog('📊 Event logged: ${sample['name']}');
  }

  Future<void> _logCustomEvent() async {
    final event = AnalyticsEvent.custom(
      name: 'custom_demo_event',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
        'event_count': _eventCount,
        'tab': _selectedTab,
      },
    );

    await _analyticsManager.logEvent(event);

    setState(() {
      _eventCount++;
    });

    _addLog('📊 Custom event logged');
  }

  Future<void> _setUser() async {
    final newUserId = 'demo_user_${DateTime.now().millisecondsSinceEpoch}';

    final user = AnalyticsUser.withFullConsent(
      userId: newUserId,
      properties: {
        'demo_mode': true,
        'platform': 'flutter',
        'app_version': '1.0.0',
      },
    );

    await _analyticsManager.setUser(user);

    setState(() {
      _userId = newUserId;
    });

    _addLog('👤 User set: $newUserId');
  }

  Future<void> _simulateError() async {
    _addLog('🐛 Simulating error...');

    try {
      throw Exception('Demo error for testing error reporting');
    } catch (error, stackTrace) {
      final errorReport = ErrorReport(
        error: error,
        stackTrace: stackTrace,
        appContext: const AppContext(
          appVersion: '1.0.0',
          buildNumber: '1',
          environment: 'demo',
        ),
        severity: ErrorSeverity.error,
      );

      await _errorLogger.report(errorReport);
      _addLog('❌ Error reported: ${error.toString()}');
    }
  }

  Future<void> _toggleConsent() async {
    final currentConsent = await _consentManager.hasAnalyticsConsent();

    if (currentConsent) {
      await _consentManager.revokeAllConsent();
      await _analyticsManager.disable();
      _addLog('🔒 Analytics consent revoked');
    } else {
      await _consentManager.grantAllConsent();
      await _analyticsManager.enable();
      _addLog('✅ Analytics consent granted');
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Analytics & Logging Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeAnalytics,
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
                    _buildStatChip('Events', _eventCount.toString(), Icons.event),
                    const SizedBox(width: 8),
                    _buildStatChip('User', _userId ?? 'Not set', Icons.person),
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
                _buildTab('Events', 1, Icons.analytics),
                _buildTab('Errors', 2, Icons.bug_report),
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
        return _buildEventsTab();
      case 2:
        return _buildErrorsTab();
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
                'Production-ready analytics and error reporting for Flutter apps with privacy-first design.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildFeatureItem('Unified Analytics', 'Single API for Firebase Analytics, Sentry, and more'),
              _buildFeatureItem('Error Reporting', 'Automatic crash reporting with context'),
              _buildFeatureItem('Privacy Controls', 'GDPR/CCPA compliant consent management'),
              _buildFeatureItem('Multi-Provider', 'Support for multiple analytics backends'),
              _buildFeatureItem('Flexible Configuration', 'Environment-specific settings'),
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
                'Set User ID',
                Icons.person_add,
                _setUser,
                Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                'Log Custom Event',
                Icons.add_chart,
                _logCustomEvent,
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                'Simulate Error',
                Icons.bug_report,
                _simulateError,
                Colors.orange,
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                'Toggle Consent',
                Icons.security,
                _toggleConsent,
                Colors.purple,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          'Supported Providers',
          Icons.extension,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProviderItem('Firebase Analytics', 'Event tracking and user analytics', true),
              _buildProviderItem('Firebase Crashlytics', 'Crash and error reporting', true),
              _buildProviderItem('Sentry', 'Advanced error monitoring with context', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCard(
          'Sample Events',
          Icons.event,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Try logging these pre-configured events:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 16),
              ...List.generate(_sampleEvents.length, (index) {
                final event = _sampleEvents[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildEventCard(
                    event['name'] as String,
                    event['params'] as Map<String, dynamic>,
                    () => _logSampleEvent(index),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          'Event Types',
          Icons.category,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEventTypeInfo(
                'Screen View',
                'Track navigation and page views',
                'screen_view, screen_name, screen_class',
              ),
              const Divider(),
              _buildEventTypeInfo(
                'User Action',
                'Track button clicks and interactions',
                'action, category, label, value',
              ),
              const Divider(),
              _buildEventTypeInfo(
                'Custom Event',
                'Any custom analytics event',
                'name, parameters (flexible)',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCard(
          'Error Reporting',
          Icons.bug_report,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The module provides comprehensive error reporting with:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 16),
              _buildFeatureItem('Automatic Crash Detection', 'Catches unhandled exceptions'),
              _buildFeatureItem('Stack Traces', 'Full stack trace capture'),
              _buildFeatureItem('App Context', 'Version, build, environment info'),
              _buildFeatureItem('Severity Levels', 'Info, Warning, Error, Fatal'),
              _buildFeatureItem('User Context', 'User ID and properties (with consent)'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _simulateError,
                icon: const Icon(Icons.bug_report),
                label: const Text('Simulate Error'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          'Error Severity Levels',
          Icons.priority_high,
          Column(
            children: [
              _buildSeverityItem('Info', 'Informational messages', Colors.blue),
              _buildSeverityItem('Warning', 'Non-critical issues', Colors.orange),
              _buildSeverityItem('Error', 'Handled errors', Colors.red),
              _buildSeverityItem('Fatal', 'Critical crashes', Colors.purple),
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

  Widget _buildProviderItem(String name, String description, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.extension,
            color: enabled ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildEventCard(String name, Map<String, dynamic> params, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Icon(Icons.play_arrow, size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              params.entries.map((e) => '${e.key}: ${e.value}').join(', '),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTypeInfo(String title, String description, String params) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          Text(
            'Parameters: $params',
            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityItem(String level, String description, Color color) {
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
                  level,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
    _analyticsManager.dispose();
    _errorLogger.dispose();
    super.dispose();
  }
}
