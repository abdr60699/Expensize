/// Social Authentication Module - Example Application
///
/// This app demonstrates the production-ready social authentication module
/// supporting Google, Apple, and Facebook sign-in.
///
/// Features:
/// - Google Sign-In
/// - Apple Sign-In (iOS/macOS/Android with web flow)
/// - Facebook Login
/// - Firebase Integration
/// - Token Storage
/// - Error Handling
/// - Platform Support Detection
///
/// IMPORTANT: This is a demonstration app. To use actual social sign-in:
/// - Configure Firebase project (optional)
/// - Set up Google Sign-In (OAuth client IDs)
/// - Configure Apple Sign-In (Service ID for web/Android)
/// - Set up Facebook App (App ID and Client Token)
/// - Follow platform-specific setup guides

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'social_auth/social_auth.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (optional - graceful fallback if not configured)
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp();
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase not configured: $e');
  }

  runApp(SocialAuthApp(firebaseInitialized: firebaseInitialized));
}

class SocialAuthApp extends StatelessWidget {
  final bool firebaseInitialized;

  const SocialAuthApp({super.key, required this.firebaseInitialized});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Auth Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: SocialAuthDemoScreen(firebaseInitialized: firebaseInitialized),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Main Demo Screen
class SocialAuthDemoScreen extends StatefulWidget {
  final bool firebaseInitialized;

  const SocialAuthDemoScreen({super.key, required this.firebaseInitialized});

  @override
  State<SocialAuthDemoScreen> createState() => _SocialAuthDemoScreenState();
}

class _SocialAuthDemoScreenState extends State<SocialAuthDemoScreen> {
  SocialAuth? _socialAuth;
  AuthResult? _currentAuthResult;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeSocialAuth();
  }

  void _initializeSocialAuth() {
    try {
      // Initialize with Firebase or standalone
      AuthService? authService;
      if (widget.firebaseInitialized) {
        authService = FirebaseAuthService();
      }

      _socialAuth = SocialAuth(
        authService: authService,
        tokenStorage: SecureTokenStorage(),
        logger: ConsoleLogger(),
        enableGoogle: true,
        googleScopes: ['email', 'profile'],
        enableApple: _isAppleSupported(),
        appleClientId: 'your.bundle.id', // Configure in production
        appleRedirectUri: 'https://your-app.com/auth/callback',
        enableFacebook: true,
        facebookPermissions: ['email', 'public_profile'],
      );
    } catch (e) {
      debugPrint('Error initializing SocialAuth: $e');
    }
  }

  bool _isAppleSupported() {
    if (kIsWeb) return false; // Web needs additional setup
    return Platform.isIOS || Platform.isMacOS || Platform.isAndroid;
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _socialAuth!.signInWithGoogle();
      setState(() {
        _currentAuthResult = result;
        _isLoading = false;
      });
      _showSuccessDialog('Google Sign-In Successful');
    } on SocialAuthError catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
      _showErrorDialog('Google Sign-In Failed', e.message);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      _showErrorDialog('Google Sign-In Failed', e.toString());
    }
  }

  Future<void> _signInWithApple() async {
    if (!_isAppleSupported()) {
      _showErrorDialog(
        'Platform Not Supported',
        'Apple Sign-In requires iOS 13+, macOS 10.15+, or Android with web flow',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _socialAuth!.signInWithApple();
      setState(() {
        _currentAuthResult = result;
        _isLoading = false;
      });
      _showSuccessDialog('Apple Sign-In Successful');
    } on SocialAuthError catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
      _showErrorDialog('Apple Sign-In Failed', e.message);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      _showErrorDialog('Apple Sign-In Failed', e.toString());
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _socialAuth!.signInWithFacebook();
      setState(() {
        _currentAuthResult = result;
        _isLoading = false;
      });
      _showSuccessDialog('Facebook Sign-In Successful');
    } on SocialAuthError catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
      _showErrorDialog('Facebook Sign-In Failed', e.message);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      _showErrorDialog('Facebook Sign-In Failed', e.toString());
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _socialAuth!.signOut();
      setState(() {
        _currentAuthResult = null;
        _isLoading = false;
        _errorMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Sign Out Failed', e.toString());
    }
  }

  void _showSuccessDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: _currentAuthResult == null
            ? const Text('Authentication successful!')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Provider: ${_currentAuthResult!.provider.name}'),
                  const SizedBox(height: 8),
                  Text('User: ${_currentAuthResult!.user.name ?? "N/A"}'),
                  const SizedBox(height: 4),
                  Text('Email: ${_currentAuthResult!.user.email ?? "N/A"}'),
                  const SizedBox(height: 4),
                  Text('ID: ${_currentAuthResult!.user.id}'),
                ],
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

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.firebaseInitialized) {
      return _buildFirebaseNotConfiguredScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Authentication Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentAuthResult != null
              ? _buildSignedInView()
              : _buildSignInView(),
    );
  }

  Widget _buildFirebaseNotConfiguredScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Auth - Setup Required'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 80, color: Colors.orange.shade700),
              const SizedBox(height: 24),
              const Text(
                'Firebase Not Configured',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'This demo requires Firebase configuration. To set up:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '1. Create Firebase Project',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('   Visit https://console.firebase.google.com'),
                      SizedBox(height: 12),
                      Text(
                        '2. Add Your App',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('   Add Android/iOS/Web apps to your project'),
                      SizedBox(height: 12),
                      Text(
                        '3. Download Configuration',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('   • Android: google-services.json'),
                      Text('   • iOS: GoogleService-Info.plist'),
                      SizedBox(height: 12),
                      Text(
                        '4. Enable Authentication',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('   Enable Google, Apple, Facebook sign-in'),
                      SizedBox(height: 12),
                      Text(
                        '5. Configure Social Providers',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('   • Google: OAuth client IDs'),
                      Text('   • Apple: Service ID'),
                      Text('   • Facebook: App ID'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SocialAuthInfoScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('View Module Info'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.login, color: Colors.blue.shade700, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Social Authentication',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sign in with your preferred social account. '
                    'This demo shows how to integrate Google, Apple, and Facebook authentication.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Error message
          if (_errorMessage != null)
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_errorMessage != null) const SizedBox(height: 16),

          // Social Sign-In Buttons
          _buildSignInButton(
            onPressed: _signInWithGoogle,
            icon: Icons.g_mobiledata,
            label: 'Sign in with Google',
            color: Colors.red,
            supported: true,
          ),
          const SizedBox(height: 12),
          _buildSignInButton(
            onPressed: _signInWithApple,
            icon: Icons.apple,
            label: 'Sign in with Apple',
            color: Colors.black,
            supported: _isAppleSupported(),
          ),
          const SizedBox(height: 12),
          _buildSignInButton(
            onPressed: _signInWithFacebook,
            icon: Icons.facebook,
            label: 'Sign in with Facebook',
            color: Colors.blue.shade800,
            supported: true,
          ),

          const SizedBox(height: 32),

          // Platform Support Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Platform Support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPlatformInfo('Google', true, 'All platforms'),
                  _buildPlatformInfo(
                    'Apple',
                    _isAppleSupported(),
                    'iOS 13+, macOS 10.15+, Android (web flow)',
                  ),
                  _buildPlatformInfo('Facebook', true, 'All platforms'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Module Info Button
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SocialAuthInfoScreen(),
                ),
              );
            },
            icon: const Icon(Icons.info_outline),
            label: const Text('View Module Documentation'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    required bool supported,
  }) {
    return ElevatedButton.icon(
      onPressed: supported ? onPressed : null,
      icon: Icon(icon, size: 24),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: supported ? color : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildPlatformInfo(String provider, bool supported, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            supported ? Icons.check_circle : Icons.cancel,
            color: supported ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: '$provider: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: info),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignedInView() {
    final user = _currentAuthResult!.user;
    final provider = _currentAuthResult!.provider;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User Profile Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (user.avatarUrl != null)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(user.avatarUrl!),
                      backgroundColor: Colors.grey.shade200,
                    )
                  else
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        user.name?.substring(0, 1).toUpperCase() ?? '?',
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    user.name ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? 'No email',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Chip(
                    avatar: Icon(
                      _getProviderIcon(provider),
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text('Signed in with ${provider.name}'),
                    backgroundColor: _getProviderColor(provider),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // User Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('User ID', user.id),
                  _buildDetailRow('Email', user.email ?? 'N/A'),
                  _buildDetailRow('Name', user.name ?? 'N/A'),
                  if (user.firstName != null)
                    _buildDetailRow('First Name', user.firstName!),
                  if (user.lastName != null)
                    _buildDetailRow('Last Name', user.lastName!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Authentication Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Authentication Info',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Provider', provider.name),
                  _buildDetailRow('Provider ID', provider.id),
                  _buildDetailRow(
                    'Access Token',
                    _currentAuthResult!.accessToken != null
                        ? '${_currentAuthResult!.accessToken!.substring(0, 20)}...'
                        : 'N/A',
                  ),
                  _buildDetailRow(
                    'ID Token',
                    _currentAuthResult!.idToken != null
                        ? '${_currentAuthResult!.idToken!.substring(0, 20)}...'
                        : 'N/A',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sign Out Button
          ElevatedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  IconData _getProviderIcon(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        return Icons.g_mobiledata;
      case SocialProvider.apple:
        return Icons.apple;
      case SocialProvider.facebook:
        return Icons.facebook;
    }
  }

  Color _getProviderColor(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        return Colors.red;
      case SocialProvider.apple:
        return Colors.black;
      case SocialProvider.facebook:
        return Colors.blue.shade800;
    }
  }
}

/// Module Info Screen
class SocialAuthInfoScreen extends StatelessWidget {
  const SocialAuthInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Auth Module'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue.shade700, size: 32),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Social Authentication Module',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Production-ready social authentication supporting Google, Apple, and Facebook sign-in with Firebase and REST API integration.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            'Google Sign-In',
            Icons.g_mobiledata,
            Colors.red,
            [
              'All platforms supported',
              'OAuth 2.0 authentication',
              'Customizable scopes',
              'Server auth code support',
              'Account selection',
            ],
          ),
          _buildFeatureCard(
            'Apple Sign-In',
            Icons.apple,
            Colors.black,
            [
              'iOS 13+ native support',
              'macOS 10.15+ support',
              'Android via web flow',
              'Privacy-focused',
              'Email relay option',
            ],
          ),
          _buildFeatureCard(
            'Facebook Login',
            Icons.facebook,
            Colors.blue.shade800,
            [
              'All platforms supported',
              'Customizable permissions',
              'Profile data access',
              'Friends list support',
              'Account linking',
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Setup Required',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '1. Configure Firebase Project\n'
                    '2. Set up OAuth client IDs (Google)\n'
                    '3. Configure Service ID (Apple)\n'
                    '4. Create Facebook App\n'
                    '5. Add platform-specific configurations\n'
                    '6. Enable authentication methods in Firebase Console\n\n'
                    'See README.md for detailed setup instructions.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    IconData icon,
    Color color,
    List<String> features,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: color, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Console Logger Implementation
class ConsoleLogger implements SocialAuthLogger {
  @override
  void info(String message) {
    debugPrint('ℹ️ [INFO] $message');
  }

  @override
  void warning(String message) {
    debugPrint('⚠️ [WARNING] $message');
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('❌ [ERROR] $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('Stack trace: $stackTrace');
  }
}
