import 'package:flutter/material.dart';
import '../facade/auth_repository.dart';

/// A widget that protects routes and requires authentication
///
/// Automatically redirects to sign-in screen if user is not authenticated
/// and shows the child widget when authenticated.
class ReusableAuthGuard extends StatelessWidget {
  /// The widget to show when authenticated
  final Widget child;

  /// The widget to show when not authenticated (defaults to sign-in prompt)
  final Widget? unauthenticatedWidget;

  /// Optional callback when user is not authenticated
  final VoidCallback? onUnauthenticated;

  /// Show loading indicator while checking auth state
  final bool showLoadingIndicator;

  const ReusableAuthGuard({
    Key? key,
    required this.child,
    this.unauthenticatedWidget,
    this.onUnauthenticated,
    this.showLoadingIndicator = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthRepository.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (showLoadingIndicator) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is authenticated - show protected content
          return child;
        } else {
          // User is not authenticated
          onUnauthenticated?.call();

          if (unauthenticatedWidget != null) {
            return unauthenticatedWidget!;
          }

          // Default unauthenticated view
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Authentication Required',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please sign in to access this content',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to sign in - implementer should handle this
                        onUnauthenticated?.call();
                      },
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
