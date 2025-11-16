import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Cryptographic utilities for PIN hashing and verification
///
/// Uses PBKDF2 (Password-Based Key Derivation Function 2) with SHA-256
/// for secure PIN hashing. This provides protection against brute-force
/// and rainbow table attacks.
class CryptoUtils {
  CryptoUtils._();

  /// Generates a cryptographically secure random salt
  ///
  /// Returns a base64-encoded salt string.
  /// Salt length is 32 bytes (256 bits) which is recommended for PBKDF2.
  static String generateSalt() {
    final random = Random.secure();
    final saltBytes = Uint8List(32);
    for (var i = 0; i < 32; i++) {
      saltBytes[i] = random.nextInt(256);
    }
    return base64Encode(saltBytes);
  }

  /// Derives a key from a PIN using PBKDF2-HMAC-SHA256
  ///
  /// [pin] - The plain-text PIN to hash
  /// [salt] - Base64-encoded salt
  /// [iterations] - Number of iterations (recommended: >= 100,000)
  ///
  /// Returns the derived key as a base64-encoded string.
  ///
  /// Note: Higher iteration counts provide better security but take longer.
  /// 100,000 iterations is a good balance as of 2024.
  static String deriveKeyFromPin(
    String pin,
    String salt,
    int iterations,
  ) {
    final saltBytes = base64Decode(salt);
    final pinBytes = utf8.encode(pin);

    // Implement PBKDF2 using HMAC-SHA256
    final derivedKey = _pbkdf2(
      pinBytes,
      saltBytes,
      iterations,
      32, // 256-bit key
    );

    return base64Encode(derivedKey);
  }

  /// Verifies a PIN against a stored hash
  ///
  /// [pin] - The plain-text PIN to verify
  /// [salt] - Base64-encoded salt used during hashing
  /// [storedHash] - Base64-encoded stored hash to compare against
  /// [iterations] - Number of iterations used in original hash
  ///
  /// Returns true if PIN matches, false otherwise.
  static bool verifyPin(
    String pin,
    String salt,
    String storedHash,
    int iterations,
  ) {
    try {
      final derivedHash = deriveKeyFromPin(pin, salt, iterations);
      return _constantTimeEquals(derivedHash, storedHash);
    } catch (e) {
      // If any error occurs during verification, fail securely
      return false;
    }
  }

  /// Implements PBKDF2 using HMAC-SHA256
  ///
  /// This is a simplified but secure implementation of PBKDF2.
  /// For production, consider using a dedicated crypto library if available.
  static Uint8List _pbkdf2(
    List<int> password,
    List<int> salt,
    int iterations,
    int keyLength,
  ) {
    final hmac = Hmac(sha256, password);
    final blockCount = (keyLength / 32).ceil();
    final derivedKey = <int>[];

    for (var block = 1; block <= blockCount; block++) {
      // Compute U1 = HMAC(password, salt || block)
      final blockBytes = Uint8List(4);
      blockBytes[0] = (block >> 24) & 0xFF;
      blockBytes[1] = (block >> 16) & 0xFF;
      blockBytes[2] = (block >> 8) & 0xFF;
      blockBytes[3] = block & 0xFF;

      var u = hmac.convert([...salt, ...blockBytes]).bytes;
      var result = List<int>.from(u);

      // Compute U2 through Uc (iterations)
      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < result.length; j++) {
          result[j] ^= u[j];
        }
      }

      derivedKey.addAll(result);
    }

    return Uint8List.fromList(derivedKey.sublist(0, keyLength));
  }

  /// Constant-time string comparison to prevent timing attacks
  ///
  /// This ensures that the comparison takes the same amount of time
  /// regardless of where the strings differ, preventing attackers from
  /// using timing information to guess the hash.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;

    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }

    return result == 0;
  }

  /// Generates a random encryption key for backup encryption
  ///
  /// Returns a base64-encoded 256-bit key suitable for AES encryption.
  static String generateEncryptionKey() {
    final random = Random.secure();
    final keyBytes = Uint8List(32); // 256 bits
    for (var i = 0; i < 32; i++) {
      keyBytes[i] = random.nextInt(256);
    }
    return base64Encode(keyBytes);
  }

  /// Computes HMAC-SHA256 for data integrity verification
  ///
  /// [data] - The data to compute HMAC for
  /// [key] - Base64-encoded key
  ///
  /// Returns base64-encoded HMAC.
  static String computeHmac(String data, String key) {
    final keyBytes = base64Decode(key);
    final dataBytes = utf8.encode(data);
    final hmac = Hmac(sha256, keyBytes);
    final digest = hmac.convert(dataBytes);
    return base64Encode(digest.bytes);
  }

  /// Verifies HMAC for data integrity
  ///
  /// Returns true if HMAC matches, false otherwise.
  static bool verifyHmac(String data, String key, String expectedHmac) {
    final computedHmac = computeHmac(data, key);
    return _constantTimeEquals(computedHmac, expectedHmac);
  }
}
