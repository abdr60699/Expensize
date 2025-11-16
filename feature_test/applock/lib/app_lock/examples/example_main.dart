import 'package:flutter/material.dart';
import '../reusable_app_lock.dart';

/// Example app demonstrating the Reusable App Lock module
///
/// This example shows:
/// - Initial PIN setup
/// - Unlocking with PIN
/// - Biometric authentication
/// - Route protection with AppLockGuard
/// - Changing PIN
/// - Auto-lock on background
/// - Lockout on too many failed attempts
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create and initialize app lock manager
  final appLockManager = AppLockManager(
    config: const AppLockConfig(
      pinMinLength: 4,
      maxAttempts: 5,
      lockoutDuration: Duration(minutes: 5),
      autoLockTimeout: Duration(seconds: 30),
      allowBiometrics: true,
      primaryColor: Colors.blue,
    ),
  );

  await appLockManager.initialize();

  runApp(AppLockExampleApp(manager: appLockManager));
}

class AppLockExampleApp extends StatelessWidget {
  final AppLockManager manager;

  const AppLockExampleApp({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Lock Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: AppInitializer(manager: manager),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Handles initial app state (setup vs main app)
class AppInitializer extends StatefulWidget {
  final AppLockManager manager;

  const AppInitializer({super.key, required this.manager});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _isPinSet = false;

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    final isEnabled = await widget.manager.isEnabled();
    setState(() {
      _isPinSet = isEnabled;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isPinSet) {
      // Show PIN setup screen
      return AppLockScreen(
        manager: widget.manager,
        mode: AppLockMode.setup,
        onSetupComplete: () {
          setState(() {
            _isPinSet = true;
          });
        },
        title: 'Welcome!',
        subtitle: 'Set up a PIN to secure your app',
      );
    }

    // Show main app with lock guard
    return AppLockGuard(
      manager: widget.manager,
      child: const MainApp(),
    );
  }
}

/// Main app content
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}

/// Home page with various options
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppLockManager _manager;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get manager from context (in real app, use Provider, Riverpod, or GetIt)
    _manager = (context
            .findAncestorWidgetOfExactType<AppLockGuard>()
            as AppLockGuard)
        .manager;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Lock Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () async {
              await _manager.lockNow();
            },
            tooltip: 'Lock Now',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Lock Demo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This app demonstrates all features of the reusable app lock module.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Features section
          const Text(
            'Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          _buildFeatureCard(
            icon: Icons.pin,
            title: 'Change PIN',
            subtitle: 'Update your PIN',
            onTap: () => _navigateToChangePIN(context),
          ),

          _buildFeatureCard(
            icon: Icons.fingerprint,
            title: 'Biometric Settings',
            subtitle: 'Enable or disable biometric unlock',
            onTap: () => _navigateToBiometricSettings(context),
          ),

          _buildFeatureCard(
            icon: Icons.shield,
            title: 'Protected Screen',
            subtitle: 'A screen protected by AppLockGuard',
            onTap: () => _navigateToProtectedScreen(context),
          ),

          _buildFeatureCard(
            icon: Icons.timer,
            title: 'Auto-Lock Settings',
            subtitle: 'Configure auto-lock timeout',
            onTap: () => _showAutoLockSettings(context),
          ),

          _buildFeatureCard(
            icon: Icons.delete_forever,
            title: 'Reset App Lock',
            subtitle: 'Remove PIN and reset all settings',
            onTap: () => _confirmReset(context),
          ),

          const SizedBox(height: 16),

          // Info section
          const Text(
            'Try These',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          const Card(
            color: Colors.blue,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Tips',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '• Press the lock icon to manually lock the app\n'
                    '• Put the app in background to test auto-lock\n'
                    '• Try entering wrong PIN 5 times to trigger lockout\n'
                    '• Enable biometric for faster unlock',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _navigateToChangePIN(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangePINScreen(manager: _manager),
      ),
    );
  }

  void _navigateToBiometricSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BiometricSettingsScreen(manager: _manager),
      ),
    );
  }

  void _navigateToProtectedScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppLockGuard(
          manager: _manager,
          child: const ProtectedScreen(),
        ),
      ),
    );
  }

  void _showAutoLockSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Auto-Lock Settings'),
        content: const Text(
          'Auto-lock is currently configured for 30 seconds of inactivity.\n\n'
          'The app will also lock immediately when moved to background.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset App Lock?'),
        content: const Text(
          'This will remove your PIN and all app lock settings. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _manager.reset();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('App lock has been reset'),
                  ),
                );
              }
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/// Change PIN screen
class ChangePINScreen extends StatelessWidget {
  final AppLockManager manager;

  const ChangePINScreen({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppLockScreen(
        manager: manager,
        mode: AppLockMode.change,
        onChangeComplete: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN changed successfully')),
          );
        },
        showCancel: true,
        onCancelled: () => Navigator.pop(context),
      ),
    );
  }
}

/// Biometric settings screen
class BiometricSettingsScreen extends StatefulWidget {
  final AppLockManager manager;

  const BiometricSettingsScreen({super.key, required this.manager});

  @override
  State<BiometricSettingsScreen> createState() =>
      _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState extends State<BiometricSettingsScreen> {
  bool _isEnabled = false;
  bool _isLoading = true;
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final canCheck = await FlutterLocalAuthService().canCheckBiometrics();
    // Check if biometric is enabled (simplified check)
    setState(() {
      _isAvailable = canCheck;
      _isLoading = false;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final success = await widget.manager.enableBiometric();
      if (success && mounted) {
        setState(() => _isEnabled = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric enabled')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to enable biometric')),
        );
      }
    } else {
      final success = await widget.manager.disableBiometric();
      if (success && mounted) {
        setState(() => _isEnabled = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric disabled')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!_isAvailable)
                  const Card(
                    color: Colors.orange,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Biometric authentication is not available on this device.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                else ...[
                  SwitchListTile(
                    title: const Text('Enable Biometric Unlock'),
                    subtitle: const Text(
                      'Use fingerprint or face recognition to unlock',
                    ),
                    value: _isEnabled,
                    onChanged: _toggleBiometric,
                  ),
                  const SizedBox(height: 16),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About Biometric Authentication',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• Biometric data never leaves your device\n'
                            '• PIN is always available as fallback\n'
                            '• You can disable biometric anytime',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

/// Protected screen that requires unlock
class ProtectedScreen extends StatelessWidget {
  const ProtectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Protected Screen'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              const Text(
                'This Screen is Protected',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'You had to unlock to see this content. '
                'This demonstrates how AppLockGuard can protect sensitive screens in your app.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
