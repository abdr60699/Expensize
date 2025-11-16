// ignore_for_file: use_build_context_synchronously

/// Firebase Auth Module - Example Application
///
/// This demonstrates the full Firebase Authentication module with:
/// - Email/Password authentication
/// - Social sign-in (Google, Facebook, Apple)
/// - Phone OTP verification
/// - Firebase Cloud Messaging (FCM)
/// - Account linking
/// - Email verification
///
/// IMPORTANT: Before running this app, you must:
/// 1. Set up a Firebase project
/// 2. Download google-services.json (Android) and GoogleService-Info.plist (iOS)
/// 3. Follow the setup instructions in TESTING_GUIDE.md

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // Note: This requires firebase_options.dart or platform-specific config files
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // If Firebase is not configured, show error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 64,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Firebase Not Configured',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $e',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please set up Firebase by following the instructions in TESTING_GUIDE.md',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Firebase Auth Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const HomeScreen();
          } else {
            return const SignInScreen();
          }
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Retry
                    ref.invalidate(authStateProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Auth Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Welcome header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You are successfully authenticated with Firebase.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // User information
          const Text(
            'User Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoCard('UID', user?.uid ?? 'N/A'),
          _buildInfoCard('Email', user?.email ?? 'Not set'),
          _buildInfoCard('Phone', user?.phoneNumber ?? 'Not set'),
          _buildInfoCard('Display Name', user?.displayName ?? 'Not set'),
          _buildInfoCard(
              'Email Verified', user?.emailVerified == true ? 'Yes' : 'No'),
          _buildInfoCard(
              'Anonymous', user?.isAnonymous == true ? 'Yes' : 'No'),
          _buildInfoCard('Auth Providers', user?.providerIds.join(', ') ?? 'N/A'),
          const SizedBox(height: 24),

          // Actions
          const Text(
            'Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (user?.email != null && !(user!.emailVerified))
            Card(
              child: ListTile(
                leading: const Icon(Icons.mark_email_unread),
                title: const Text('Email Not Verified'),
                subtitle: const Text('Send verification email'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    try {
                      await authService.sendEmailVerification();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verification email sent!'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Send'),
                ),
              ),
            ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Manage Linked Accounts'),
              subtitle: const Text('Link or unlink auth providers'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountLinksScreen(),
                  ),
                );
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('FCM Token'),
              subtitle: const Text('View Firebase Cloud Messaging token'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FcmTokenScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Info
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
                        'Features Included',
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
                    '• Email/Password authentication\n'
                    '• Social sign-in (Google, Facebook, Apple)\n'
                    '• Phone OTP verification\n'
                    '• Account linking/unlinking\n'
                    '• Email verification\n'
                    '• Firebase Cloud Messaging (FCM)\n'
                    '• Secure token storage',
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

  Widget _buildInfoCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(
                '$label:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountLinksScreen extends ConsumerWidget {
  const AccountLinksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Linked Accounts'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'You can link multiple authentication providers to your account. '
                'This allows you to sign in using different methods.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildProviderTile(
            context,
            ref,
            name: 'Google',
            providerId: 'google.com',
            icon: Icons.g_mobiledata,
            color: Colors.red,
            isLinked: user?.hasProvider('google.com') ?? false,
            onLink: () async {
              final result = await authService.linkWithGoogle();
              _handleResult(context, result, 'Google linked!');
            },
            onUnlink: () async {
              final result = await authService.unlinkProvider('google.com');
              _handleResult(context, result, 'Google unlinked!');
            },
          ),
          const Divider(),
          _buildProviderTile(
            context,
            ref,
            name: 'Facebook',
            providerId: 'facebook.com',
            icon: Icons.facebook,
            color: Colors.blue,
            isLinked: user?.hasProvider('facebook.com') ?? false,
            onLink: () async {
              final result = await authService.linkWithFacebook();
              _handleResult(context, result, 'Facebook linked!');
            },
            onUnlink: () async {
              final result = await authService.unlinkProvider('facebook.com');
              _handleResult(context, result, 'Facebook unlinked!');
            },
          ),
          const Divider(),
          _buildProviderTile(
            context,
            ref,
            name: 'Apple',
            providerId: 'apple.com',
            icon: Icons.apple,
            color: Colors.black,
            isLinked: user?.hasProvider('apple.com') ?? false,
            onLink: () async {
              final result = await authService.linkWithApple();
              _handleResult(context, result, 'Apple linked!');
            },
            onUnlink: () async {
              final result = await authService.unlinkProvider('apple.com');
              _handleResult(context, result, 'Apple unlinked!');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProviderTile(
    BuildContext context,
    WidgetRef ref, {
    required String name,
    required String providerId,
    required IconData icon,
    required Color color,
    required bool isLinked,
    required VoidCallback onLink,
    required VoidCallback onUnlink,
  }) {
    final user = ref.watch(currentUserProvider);
    final canUnlink = (user?.providerIds.length ?? 0) > 1;

    return ListTile(
      leading: Icon(icon, color: isLinked ? color : Colors.grey, size: 32),
      title: Text(name),
      subtitle: Text(isLinked ? 'Linked' : 'Not linked'),
      trailing: isLinked
          ? (canUnlink
              ? TextButton(
                  onPressed: onUnlink,
                  child: const Text('Unlink'),
                )
              : const Chip(label: Text('Primary')))
          : ElevatedButton(
              onPressed: onLink,
              child: const Text('Link'),
            ),
    );
  }

  void _handleResult(BuildContext context, AuthResult result, String successMsg) {
    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMsg)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error!.friendlyMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class FcmTokenScreen extends StatelessWidget {
  const FcmTokenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Token'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_outlined, size: 64, color: Colors.blue),
              SizedBox(height: 24),
              Text(
                'Firebase Cloud Messaging',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'FCM integration is ready. Configure FCM service to receive push notifications.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'See fcm/README.md for detailed FCM setup instructions.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
