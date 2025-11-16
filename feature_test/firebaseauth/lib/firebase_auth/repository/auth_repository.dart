import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user_model.dart';
import '../models/auth_result.dart';
import '../errors/auth_error.dart';
import '../storage/token_store.dart';
import '../utils/auth_constants.dart';

/// Repository that handles Firebase Auth SDK interactions and data persistence.
///
/// This layer:
/// - Maps Firebase User to UserModel
/// - Handles token/session persistence
/// - Provides clean error handling
/// - Manages auth state streams
class AuthRepository {
  final fb.FirebaseAuth _firebaseAuth;
  final ITokenStore _tokenStore;

  /// Stream controller for user state changes
  final _userStreamController = StreamController<UserModel?>.broadcast();

  /// Current user cache
  UserModel? _cachedUser;

  /// Auth state subscription
  StreamSubscription<fb.User?>? _authStateSubscription;

  AuthRepository({
    fb.FirebaseAuth? firebaseAuth,
    required ITokenStore tokenStore,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _tokenStore = tokenStore {
    _initAuthStateListener();
  }

  /// Initialize auth state listener
  void _initAuthStateListener() {
    _authStateSubscription = _firebaseAuth.authStateChanges().listen(
      (fb.User? user) async {
        if (user != null) {
          final userModel = UserModel.fromFirebaseUser(user);
          _cachedUser = userModel;
          await _persistUser(userModel);
          _userStreamController.add(userModel);
        } else {
          _cachedUser = null;
          await _clearPersistedUser();
          _userStreamController.add(null);
        }
      },
      onError: (error) {
        _userStreamController.addError(
          AuthError.fromException(error),
        );
      },
    );
  }

  /// Stream of user state changes
  Stream<UserModel?> get authStateChanges => _userStreamController.stream;

  /// Get current user (cached)
  UserModel? get currentUser => _cachedUser;

  /// Get current Firebase user
  fb.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Refresh current user from Firebase
  Future<UserModel?> refreshUser() async {
    try {
      await _firebaseAuth.currentUser?.reload();
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final userModel = UserModel.fromFirebaseUser(user);
        _cachedUser = userModel;
        await _persistUser(userModel);
        _userStreamController.add(userModel);
        return userModel;
      }
      return null;
    } catch (e) {
      throw AuthError.fromException(e);
    }
  }

  /// Get ID token for the current user
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      return await user.getIdToken(forceRefresh);
    } catch (e) {
      throw AuthError.fromException(e);
    }
  }

  /// Sign up with email and password
  Future<AuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel.fromFirebaseUser(credential.user!);
      await _persistUser(user);

      return AuthResult.success(
        user,
        requiresVerification: !user.emailVerified,
      );
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(AuthError.fromFirebaseException(e));
    } catch (e) {
      return AuthResult.failure(AuthError.fromException(e));
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel.fromFirebaseUser(credential.user!);
      await _persistUser(user);

      return AuthResult.success(user);
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(AuthError.fromFirebaseException(e));
    } catch (e) {
      return AuthResult.failure(AuthError.fromException(e));
    }
  }

  /// Sign in with credential (used by social providers)
  Future<AuthResult> signInWithCredential(fb.AuthCredential credential) async {
    try {
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final user = UserModel.fromFirebaseUser(userCredential.user!);
      await _persistUser(user);

      return AuthResult.success(user);
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(AuthError.fromFirebaseException(e));
    } catch (e) {
      return AuthResult.failure(AuthError.fromException(e));
    }
  }

  /// Sign in anonymously
  Future<AuthResult> signInAnonymously() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();

      final user = UserModel.fromFirebaseUser(credential.user!);
      await _persistUser(user);

      return AuthResult.success(user);
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(AuthError.fromFirebaseException(e));
    } catch (e) {
      return AuthResult.failure(AuthError.fromException(e));
    }
  }

  /// Link credential to current user
  Future<AuthResult> linkWithCredential(fb.AuthCredential credential) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return AuthResult.failure(
          AuthError.custom(
            code: AuthErrorCode.userNotFound,
            message: 'No user signed in',
          ),
        );
      }

      final userCredential = await currentUser.linkWithCredential(credential);

      final user = UserModel.fromFirebaseUser(userCredential.user!);
      await _persistUser(user);

      return AuthResult.success(user);
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(AuthError.fromFirebaseException(e));
    } catch (e) {
      return AuthResult.failure(AuthError.fromException(e));
    }
  }

  /// Unlink provider from current user
  Future<AuthResult> unlinkProvider(String providerId) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return AuthResult.failure(
          AuthError.custom(
            code: AuthErrorCode.userNotFound,
            message: 'No user signed in',
          ),
        );
      }

      final userCredential = await currentUser.unlink(providerId);

      final user = UserModel.fromFirebaseUser(userCredential.user!);
      await _persistUser(user);

      return AuthResult.success(user);
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(AuthError.fromFirebaseException(e));
    } catch (e) {
      return AuthResult.failure(AuthError.fromException(e));
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthError.custom(
          code: AuthErrorCode.userNotFound,
          message: 'No user signed in',
        );
      }

      await user.sendEmailVerification();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthError.fromFirebaseException(e);
    } catch (e) {
      throw AuthError.fromException(e);
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthError.fromFirebaseException(e);
    } catch (e) {
      throw AuthError.fromException(e);
    }
  }

  /// Reauthenticate with email and password
  Future<void> reauthenticateWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthError.custom(
          code: AuthErrorCode.userNotFound,
          message: 'No user signed in',
        );
      }

      final credential = fb.EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthError.fromFirebaseException(e);
    } catch (e) {
      throw AuthError.fromException(e);
    }
  }

  /// Reauthenticate with credential
  Future<void> reauthenticateWithCredential(
    fb.AuthCredential credential,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthError.custom(
          code: AuthErrorCode.userNotFound,
          message: 'No user signed in',
        );
      }

      await user.reauthenticateWithCredential(credential);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthError.fromFirebaseException(e);
    } catch (e) {
      throw AuthError.fromException(e);
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthError.custom(
          code: AuthErrorCode.userNotFound,
          message: 'No user signed in',
        );
      }

      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoUrl);
      await refreshUser();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthError.fromFirebaseException(e);
    } catch (e) {
      throw AuthError.fromException(e);
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthError.custom(
          code: AuthErrorCode.userNotFound,
          message: 'No user signed in',
        );
      }

      await user.delete();
      await _clearPersistedUser();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthError.fromFirebaseException(e);
    } catch (e) {
      throw AuthError.fromException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _clearPersistedUser();
      _cachedUser = null;
      _userStreamController.add(null);
    } catch (e) {
      throw AuthError.fromException(e);
    }
  }

  /// Persist user to storage
  Future<void> _persistUser(UserModel user) async {
    try {
      // Store user data
      await _tokenStore.writeSessionData(
        StorageKeys.userId,
        user.uid,
      );

      if (user.email != null) {
        await _tokenStore.writeSessionData(
          StorageKeys.userEmail,
          user.email!,
        );
      }

      await _tokenStore.writeSessionData(
        StorageKeys.lastLoginTime,
        DateTime.now().toIso8601String(),
      );

      // Store full user model as JSON
      await _tokenStore.writeSessionData(
        'user_model',
        jsonEncode(user.toJson()),
      );
    } catch (e) {
      // Non-critical error, just log
      print('Failed to persist user: $e');
    }
  }

  /// Clear persisted user
  Future<void> _clearPersistedUser() async {
    try {
      await _tokenStore.deleteSessionData(StorageKeys.userId);
      await _tokenStore.deleteSessionData(StorageKeys.userEmail);
      await _tokenStore.deleteSessionData(StorageKeys.lastLoginTime);
      await _tokenStore.deleteSessionData('user_model');
      await _tokenStore.clearAll();
    } catch (e) {
      print('Failed to clear persisted user: $e');
    }
  }

  /// Load persisted user (for offline support)
  Future<UserModel?> loadPersistedUser() async {
    try {
      final userJson = await _tokenStore.readSessionData('user_model');
      if (userJson != null) {
        return UserModel.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      print('Failed to load persisted user: $e');
      return null;
    }
  }

  /// Dispose repository resources
  void dispose() {
    _authStateSubscription?.cancel();
    _userStreamController.close();
  }
}
