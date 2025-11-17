/// Supabase Authentication Module - Example Application
///
/// This app demonstrates the production-ready Supabase authentication module.
///
/// Features:
/// - Email/Password Authentication
/// - Magic Link (OTP) Authentication
/// - OAuth (Google, Apple, Facebook, GitHub, Twitter)
/// - Password Reset
/// - Session Management
/// - Secure Token Storage
/// - Reusable UI Widgets
///
/// IMPORTANT: This is a demonstration app. To use actual Supabase:
/// - Create a Supabase project at https://supabase.com
/// - Get your project URL and anon key
/// - Configure OAuth providers in Supabase Dashboard
/// - Update SupabaseAuthConfig with your credentials

import 'package:flutter/material.dart';
import 'supabase_auth/supabase_auth.dart';

void main() {
  runApp(const SupabaseAuthApp());
}

class SupabaseAuthApp extends StatelessWidget {
  const SupabaseAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Auth Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SupabaseAuthDemoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Main Demo Screen
class SupabaseAuthDemoScreen extends StatefulWidget {
  const SupabaseAuthDemoScreen({super.key});

  @override
  State<SupabaseAuthDemoScreen> createState() => _SupabaseAuthDemoScreenState();
}

class _SupabaseAuthDemoScreenState extends State<SupabaseAuthDemoScreen> {
  AuthRepository? _authRepository;
  AuthResult? _currentSession;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeSupabase();
  }

  Future<void> _initializeSupabase() async {
    try {
      // Configure Supabase
      // IMPORTANT: Replace with your actual Supabase credentials
      final config = SupabaseAuthConfig(
        supabaseUrl: 'YOUR_SUPABASE_URL', // e.g., https://xxxxx.supabase.co
        supabaseAnonKey: 'YOUR_SUPABASE_ANON_KEY',
        redirectUrl: 'your-app://auth-callback',
        useSecureStorageForSession: true,
      );

      // Initialize auth service
      final authService = SupabaseAuthService(
        config: config,
        tokenStorage: SecureTokenStorage(),
      );

      // Create repository using initialize factory method
      _authRepository = await AuthRepository.initialize(config);

      // Check for existing session
      final session = await _authRepository!.getCurrentSession();

      setState(() {
        _currentSession = session;
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing Supabase...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null && _errorMessage!.contains('not configured')) {
      return _buildNotConfiguredScreen();
    }

    if (_currentSession != null) {
      return _buildHomeScreen();
    }

    return _buildAuthSelectionScreen();
  }

  Widget _buildNotConfiguredScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Auth - Setup Required'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 80, color: Colors.orange.shade700),
              const SizedBox(height: 24),
              const Text(
                'Supabase Not Configured',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'This demo requires a Supabase project. To set up:',
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
                        '1. Create Supabase Project',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('   Visit https://supabase.com'),
                      SizedBox(height: 12),
                      Text(
                        '2. Get Your Credentials',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('   Project Settings > API'),
                      Text('   • Project URL'),
                      Text('   • Anon/Public Key'),
                      SizedBox(height: 12),
                      Text(
                        '3. Configure OAuth Providers',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('   Authentication > Providers'),
                      Text('   • Enable Google, Apple, Facebook, etc.'),
                      SizedBox(height: 12),
                      Text(
                        '4. Update lib/main.dart',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('   Replace placeholders with your credentials'),
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
                      builder: (_) => const SupabaseAuthInfoScreen(),
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

  Widget _buildAuthSelectionScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Authentication'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, color: Colors.green.shade700, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Supabase Authentication',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Choose your authentication method. Supabase supports email/password, magic links, and OAuth providers.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Email/Password Auth
            _buildAuthMethodCard(
              title: 'Email & Password',
              description: 'Traditional email and password authentication',
              icon: Icons.email,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EmailPasswordAuthScreen(
                      authRepository: _authRepository!,
                      onSuccess: (result) {
                        setState(() {
                          _currentSession = result;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Magic Link Auth
            _buildAuthMethodCard(
              title: 'Magic Link',
              description: 'Passwordless authentication via email',
              icon: Icons.link,
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MagicLinkAuthScreen(
                      authRepository: _authRepository!,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // OAuth Auth
            _buildAuthMethodCard(
              title: 'Social Sign-In (OAuth)',
              description: 'Google, Apple, Facebook, GitHub, Twitter',
              icon: Icons.people,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OAuthAuthScreen(
                      authRepository: _authRepository!,
                      onSuccess: (result) {
                        setState(() {
                          _currentSession = result;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Module Info Button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SupabaseAuthInfoScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.info_outline),
              label: const Text('View Module Documentation'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthMethodCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildHomeScreen() {
    final user = _currentSession!.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.green.shade100,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? Text(
                              user.email?.substring(0, 1).toUpperCase() ?? '?',
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.green.shade700,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name ?? user.email ?? 'User',
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
                      label: Text('Provider: ${_currentSession!.provider}'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Session Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Session Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('User ID', user.id),
                    _buildInfoRow('Email', user.email ?? 'N/A'),
                    _buildInfoRow('Name', user.name ?? 'N/A'),
                    _buildInfoRow(
                      'Confirmed',
                      user.confirmedAt != null ? 'Yes' : 'No',
                    ),
                    if (_currentSession!.expiresAt != null)
                      _buildInfoRow(
                        'Session Expires',
                        _currentSession!.expiresAt!.toLocal().toString(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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

  Future<void> _signOut() async {
    try {
      await _authRepository!.signOut();
      setState(() {
        _currentSession = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: $e')),
      );
    }
  }
}

/// Email/Password Auth Screen
class EmailPasswordAuthScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final Function(AuthResult) onSuccess;

  const EmailPasswordAuthScreen({
    super.key,
    required this.authRepository,
    required this.onSuccess,
  });

  @override
  State<EmailPasswordAuthScreen> createState() => _EmailPasswordAuthScreenState();
}

class _EmailPasswordAuthScreenState extends State<EmailPasswordAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  Future<void> _authenticate() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = _isSignUp
          ? await widget.authRepository.signUpWithEmail(
              email: _emailController.text,
              password: _passwordController.text,
            )
          : await widget.authRepository.signInWithEmail(
              email: _emailController.text,
              password: _passwordController.text,
            );

      widget.onSuccess(result);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _authenticate,
                    child: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() => _isSignUp = !_isSignUp);
                    },
                    child: Text(_isSignUp
                        ? 'Already have an account? Sign In'
                        : 'Don\'t have an account? Sign Up'),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Magic Link Auth Screen
class MagicLinkAuthScreen extends StatefulWidget {
  final AuthRepository authRepository;

  const MagicLinkAuthScreen({super.key, required this.authRepository});

  @override
  State<MagicLinkAuthScreen> createState() => _MagicLinkAuthScreenState();
}

class _MagicLinkAuthScreenState extends State<MagicLinkAuthScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _sendMagicLink() async {
    if (_emailController.text.isEmpty) {
      _showError('Please enter your email');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.authRepository.signInWithMagicLink(
        email: _emailController.text,
      );
      setState(() => _emailSent = true);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magic Link'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_emailSent) ...[
                    const Text(
                      'Enter your email to receive a magic link',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _sendMagicLink,
                      child: const Text('Send Magic Link'),
                    ),
                  ] else ...[
                    const Icon(Icons.email, size: 64, color: Colors.green),
                    const SizedBox(height: 24),
                    const Text(
                      'Magic link sent!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Check your email (${_emailController.text}) and click the link to sign in.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

/// OAuth Auth Screen
class OAuthAuthScreen extends StatelessWidget {
  final AuthRepository authRepository;
  final Function(AuthResult) onSuccess;

  const OAuthAuthScreen({
    super.key,
    required this.authRepository,
    required this.onSuccess,
  });

  Future<void> _signInWithProvider(
    BuildContext context,
    SocialProvider provider,
  ) async {
    try {
      final result = await authRepository.signInWithOAuth(provider);
      onSuccess(result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OAuth failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Sign-In'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOAuthButton(
              context,
              'Sign in with Google',
              Icons.g_mobiledata,
              Colors.red,
              SocialProvider.google,
            ),
            const SizedBox(height: 12),
            _buildOAuthButton(
              context,
              'Sign in with Apple',
              Icons.apple,
              Colors.black,
              SocialProvider.apple,
            ),
            const SizedBox(height: 12),
            _buildOAuthButton(
              context,
              'Sign in with Facebook',
              Icons.facebook,
              Colors.blue,
              SocialProvider.facebook,
            ),
            const SizedBox(height: 12),
            _buildOAuthButton(
              context,
              'Sign in with GitHub',
              Icons.code,
              Colors.grey,
              SocialProvider.github,
            ),
            const SizedBox(height: 12),
            _buildOAuthButton(
              context,
              'Sign in with Twitter',
              Icons.tag,
              Colors.lightBlue,
              SocialProvider.twitter,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOAuthButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    SocialProvider provider,
  ) {
    return ElevatedButton.icon(
      onPressed: () => _signInWithProvider(context, provider),
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}

/// Module Info Screen
class SupabaseAuthInfoScreen extends StatelessWidget {
  const SupabaseAuthInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Auth Module'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.green.shade700, size: 32),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Supabase Authentication',
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
                    'Production-ready Supabase authentication module with email/password, magic link, OAuth, and session management.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            'Email & Password',
            Icons.email,
            Colors.blue,
            [
              'Sign up with email and password',
              'Email verification',
              'Password strength validation',
              'Secure password hashing',
            ],
          ),
          _buildFeatureCard(
            'Magic Link',
            Icons.link,
            Colors.purple,
            [
              'Passwordless authentication',
              'One-time email links',
              'Auto-expiring tokens',
              'No password to remember',
            ],
          ),
          _buildFeatureCard(
            'OAuth Providers',
            Icons.people,
            Colors.orange,
            [
              'Google Sign-In',
              'Apple Sign-In',
              'Facebook Login',
              'GitHub OAuth',
              'Twitter OAuth',
            ],
          ),
          _buildFeatureCard(
            'Security',
            Icons.security,
            Colors.green,
            [
              'Secure token storage',
              'Session management',
              'Token refresh',
              'Row-level security',
            ],
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

/// Secure Token Storage Implementation
class SecureTokenStorage implements TokenStorage {
  // Note: Placeholder - uses memory storage for demo
  // In production, use flutter_secure_storage
  final Map<String, String> _storage = {};

  @override
  Future<void> saveToken(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> getToken(String key) async {
    return _storage[key];
  }

  @override
  Future<void> deleteToken(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }

  @override
  Future<bool> hasToken(String key) async {
    return _storage.containsKey(key);
  }
}
