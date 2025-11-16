// ignore_for_file: use_build_context_synchronously

/// Example main.dart showing Riverpod integration
///
/// To use this:
/// 1. Replace your main.dart with this file
/// 2. Add Firebase configuration files (google-services.json, GoogleService-Info.plist)
/// 3. Update platform-specific config (see README.md)
/// 4. Run: flutter run

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

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
        title: const Text('Home'),
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            _buildInfoTile('UID', user?.uid ?? 'N/A'),
            _buildInfoTile('Email', user?.email ?? 'N/A'),
            _buildInfoTile('Phone', user?.phoneNumber ?? 'N/A'),
            _buildInfoTile('Display Name', user?.displayName ?? 'N/A'),
            _buildInfoTile('Email Verified',
                user?.emailVerified == true ? 'Yes' : 'No'),
            _buildInfoTile('Anonymous', user?.isAnonymous == true ? 'Yes' : 'No'),
            _buildInfoTile('Providers', user?.providerIds.join(', ') ?? 'N/A'),
            const SizedBox(height: 24),
            if (user?.email != null && !(user!.emailVerified))
              ElevatedButton(
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
                child: const Text('Send Verification Email'),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountLinksScreen(),
                  ),
                );
              },
              child: const Text('Manage Linked Accounts'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
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
          _buildProviderTile(
            context,
            ref,
            name: 'Google',
            providerId: 'google.com',
            icon: Icons.g_mobiledata,
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
    required bool isLinked,
    required VoidCallback onLink,
    required VoidCallback onUnlink,
  }) {
    final user = ref.watch(currentUserProvider);
    final canUnlink = (user?.providerIds.length ?? 0) > 1;

    return ListTile(
      leading: Icon(icon, color: isLinked ? Colors.green : Colors.grey),
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
