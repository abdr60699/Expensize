import 'package:flutter_test/flutter_test.dart';
import '../src/utils/crypto_utils.dart';

void main() {
  group('CryptoUtils', () {
    group('generateSalt', () {
      test('generates non-empty salt', () {
        final salt = CryptoUtils.generateSalt();
        expect(salt, isNotEmpty);
      });

      test('generates unique salts', () {
        final salt1 = CryptoUtils.generateSalt();
        final salt2 = CryptoUtils.generateSalt();
        expect(salt1, isNot(equals(salt2)));
      });

      test('salt is base64 encoded', () {
        final salt = CryptoUtils.generateSalt();
        // Should not throw
        expect(() => CryptoUtils.deriveKeyFromPin('test', salt, 1000), returnsNormally);
      });
    });

    group('deriveKeyFromPin', () {
      test('derives consistent hash from same inputs', () {
        final salt = CryptoUtils.generateSalt();
        final pin = '1234';
        const iterations = 1000;

        final hash1 = CryptoUtils.deriveKeyFromPin(pin, salt, iterations);
        final hash2 = CryptoUtils.deriveKeyFromPin(pin, salt, iterations);

        expect(hash1, equals(hash2));
      });

      test('derives different hashes for different PINs', () {
        final salt = CryptoUtils.generateSalt();
        const iterations = 1000;

        final hash1 = CryptoUtils.deriveKeyFromPin('1234', salt, iterations);
        final hash2 = CryptoUtils.deriveKeyFromPin('5678', salt, iterations);

        expect(hash1, isNot(equals(hash2)));
      });

      test('derives different hashes for different salts', () {
        final salt1 = CryptoUtils.generateSalt();
        final salt2 = CryptoUtils.generateSalt();
        const pin = '1234';
        const iterations = 1000;

        final hash1 = CryptoUtils.deriveKeyFromPin(pin, salt1, iterations);
        final hash2 = CryptoUtils.deriveKeyFromPin(pin, salt2, iterations);

        expect(hash1, isNot(equals(hash2)));
      });

      test('returns base64 encoded hash', () {
        final salt = CryptoUtils.generateSalt();
        final hash = CryptoUtils.deriveKeyFromPin('1234', salt, 1000);

        expect(hash, isNotEmpty);
        expect(hash, matches(RegExp(r'^[A-Za-z0-9+/=]+$')));
      });
    });

    group('verifyPin', () {
      test('verifies correct PIN', () {
        final salt = CryptoUtils.generateSalt();
        const pin = '1234';
        const iterations = 1000;

        final hash = CryptoUtils.deriveKeyFromPin(pin, salt, iterations);
        final result = CryptoUtils.verifyPin(pin, salt, hash, iterations);

        expect(result, isTrue);
      });

      test('rejects incorrect PIN', () {
        final salt = CryptoUtils.generateSalt();
        const correctPin = '1234';
        const wrongPin = '5678';
        const iterations = 1000;

        final hash = CryptoUtils.deriveKeyFromPin(correctPin, salt, iterations);
        final result = CryptoUtils.verifyPin(wrongPin, salt, hash, iterations);

        expect(result, isFalse);
      });

      test('rejects PIN with wrong salt', () {
        final correctSalt = CryptoUtils.generateSalt();
        final wrongSalt = CryptoUtils.generateSalt();
        const pin = '1234';
        const iterations = 1000;

        final hash = CryptoUtils.deriveKeyFromPin(pin, correctSalt, iterations);
        final result = CryptoUtils.verifyPin(pin, wrongSalt, hash, iterations);

        expect(result, isFalse);
      });

      test('handles invalid inputs gracefully', () {
        final salt = CryptoUtils.generateSalt();

        // Should not throw, should return false
        expect(
          CryptoUtils.verifyPin('1234', salt, 'invalid_hash', 1000),
          isFalse,
        );
      });
    });

    group('generateEncryptionKey', () {
      test('generates non-empty key', () {
        final key = CryptoUtils.generateEncryptionKey();
        expect(key, isNotEmpty);
      });

      test('generates unique keys', () {
        final key1 = CryptoUtils.generateEncryptionKey();
        final key2 = CryptoUtils.generateEncryptionKey();
        expect(key1, isNot(equals(key2)));
      });
    });

    group('HMAC operations', () {
      test('computes consistent HMAC', () {
        final key = CryptoUtils.generateEncryptionKey();
        const data = 'test data';

        final hmac1 = CryptoUtils.computeHmac(data, key);
        final hmac2 = CryptoUtils.computeHmac(data, key);

        expect(hmac1, equals(hmac2));
      });

      test('computes different HMACs for different data', () {
        final key = CryptoUtils.generateEncryptionKey();

        final hmac1 = CryptoUtils.computeHmac('data1', key);
        final hmac2 = CryptoUtils.computeHmac('data2', key);

        expect(hmac1, isNot(equals(hmac2)));
      });

      test('verifies correct HMAC', () {
        final key = CryptoUtils.generateEncryptionKey();
        const data = 'test data';

        final hmac = CryptoUtils.computeHmac(data, key);
        final result = CryptoUtils.verifyHmac(data, key, hmac);

        expect(result, isTrue);
      });

      test('rejects incorrect HMAC', () {
        final key = CryptoUtils.generateEncryptionKey();
        const data = 'test data';

        final correctHmac = CryptoUtils.computeHmac(data, key);
        final wrongHmac = CryptoUtils.computeHmac('wrong data', key);

        final result = CryptoUtils.verifyHmac(data, key, wrongHmac);

        expect(result, isFalse);
      });
    });

    group('security properties', () {
      test('different iterations produce different hashes', () {
        final salt = CryptoUtils.generateSalt();
        const pin = '1234';

        final hash1 = CryptoUtils.deriveKeyFromPin(pin, salt, 1000);
        final hash2 = CryptoUtils.deriveKeyFromPin(pin, salt, 2000);

        expect(hash1, isNot(equals(hash2)));
      });

      test('salt is sufficiently long (>= 32 bytes)', () {
        final salt = CryptoUtils.generateSalt();
        // Base64 encoding of 32 bytes should be >= 44 characters
        expect(salt.length, greaterThanOrEqualTo(44));
      });
    });
  });
}
