import 'auth_result.dart';

/// Interface for backend authentication service
///
/// Implement this interface to handle server-side authentication
/// with your custom backend or Firebase.
abstract class AuthService {
  /// Authenticate user with provider tokens
  ///
  /// This method should:
  /// 1. Validate the provider tokens
  /// 2. Create or link the user account on your backend
  /// 3. Return your app's session token or user data
  ///
  /// Returns a Map containing your backend response (e.g., session token, user data)
  Future<Map<String, dynamic>> authenticateWithProvider(AuthResult authResult);

  /// Sign out from the backend
  Future<void> signOut();

  /// Optional: Check if user is currently authenticated
  Future<bool> isAuthenticated() async => false;

  /// Optional: Get current user information
  Future<Map<String, dynamic>?> getCurrentUser() async => null;
}
