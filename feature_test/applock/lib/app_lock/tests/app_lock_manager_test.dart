import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../src/app_lock_manager.dart';
import '../src/models/app_lock_config.dart';
import '../src/services/secure_storage_adapter.dart';
import '../src/services/settings_storage.dart';
import '../src/services/local_auth_service.dart';

// Mocks
class MockSecureStorageAdapter extends Mock implements SecureStorageAdapter {}

class MockSettingsStorage extends Mock implements SettingsStorage {}

class MockLocalAuthService extends Mock implements LocalAuthService {}

void main() {
  late MockSecureStorageAdapter mockSecureStorage;
  late MockSettingsStorage mockSettingsStorage;
  late MockLocalAuthService mockLocalAuth;
  late AppLockManager manager;

  setUp(() {
    mockSecureStorage = MockSecureStorageAdapter();
    mockSettingsStorage = MockSettingsStorage();
    mockLocalAuth = MockLocalAuthService();

    // Default stubs
    when(() => mockSecureStorage.readSecure(any())).thenAnswer((_) async => null);
    when(() => mockSecureStorage.writeSecure(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockSecureStorage.deleteSecure(any())).thenAnswer((_) async {});
    when(() => mockSecureStorage.deleteAll()).thenAnswer((_) async {});
    when(() => mockSecureStorage.containsKey(any())).thenAnswer((_) async => false);

    when(() => mockSettingsStorage.read(any())).thenAnswer((_) async => null);
    when(() => mockSettingsStorage.readInt(any())).thenAnswer((_) async => null);
    when(() => mockSettingsStorage.readBool(any())).thenAnswer((_) async => null);
    when(() => mockSettingsStorage.write(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockSettingsStorage.writeInt(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockSettingsStorage.writeBool(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockSettingsStorage.delete(any())).thenAnswer((_) async {});
    when(() => mockSettingsStorage.clear()).thenAnswer((_) async {});

    when(() => mockLocalAuth.canCheckBiometrics()).thenAnswer((_) async => true);
    when(() => mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

    manager = AppLockManager(
      config: const AppLockConfig(
        pinMinLength: 4,
        maxAttempts: 3,
        lockoutDuration: Duration(minutes: 5),
      ),
      secureAdapter: mockSecureStorage,
      settingsStorage: mockSettingsStorage,
      localAuth: mockLocalAuth,
    );
  });

  tearDown(() {
    manager.dispose();
  });

  group('AppLockManager', () {
    group('initialization', () {
      test('initializes successfully', () async {
        await manager.initialize();
        // Should not throw
      });

      test('throws if not initialized', () async {
        expect(
          () => manager.isEnabled(),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('isEnabled', () {
      test('returns false when PIN not set', () async {
        await manager.initialize();

        when(() => mockSecureStorage.readSecure(any()))
            .thenAnswer((_) async => null);

        final result = await manager.isEnabled();
        expect(result, isFalse);
      });

      test('returns true when PIN is set', () async {
        await manager.initialize();

        when(() => mockSecureStorage.readSecure('reusable_app_lock_pin_hash'))
            .thenAnswer((_) async => 'some_hash');

        final result = await manager.isEnabled();
        expect(result, isTrue);
      });
    });

    group('setPin', () {
      test('sets PIN successfully', () async {
        await manager.initialize();

        final result = await manager.setPin('1234');

        expect(result, isTrue);
        verify(() => mockSecureStorage.writeSecure(
              'reusable_app_lock_pin_salt',
              any(),
            )).called(1);
        verify(() => mockSecureStorage.writeSecure(
              'reusable_app_lock_pin_hash',
              any(),
            )).called(1);
      });

      test('rejects PIN shorter than minimum', () async {
        await manager.initialize();

        final result = await manager.setPin('12'); // Too short

        expect(result, isFalse);
        verifyNever(() => mockSecureStorage.writeSecure(any(), any()));
      });

      test('resets failed attempts after setting PIN', () async {
        await manager.initialize();

        await manager.setPin('1234');

        verify(() => mockSettingsStorage.writeInt(
              'reusable_app_lock_failed_attempts',
              0,
            )).called(1);
      });
    });

    group('verifyPin', () {
      test('verifies correct PIN', () async {
        await manager.initialize();

        // Set up PIN
        await manager.setPin('1234');

        // Capture the stored hash and salt
        final capturedHash = verify(
          () => mockSecureStorage.writeSecure(
            'reusable_app_lock_pin_hash',
            captureAny(),
          ),
        ).captured.last as String;

        final capturedSalt = verify(
          () => mockSecureStorage.writeSecure(
            'reusable_app_lock_pin_salt',
            captureAny(),
          ),
        ).captured.last as String;

        // Reset mocks for verification
        reset(mockSecureStorage);
        when(() => mockSecureStorage.readSecure('reusable_app_lock_pin_hash'))
            .thenAnswer((_) async => capturedHash);
        when(() => mockSecureStorage.readSecure('reusable_app_lock_pin_salt'))
            .thenAnswer((_) async => capturedSalt);

        // Verify
        final result = await manager.verifyPin('1234');

        expect(result.success, isTrue);
        expect(result.attemptsRemaining, 0);
        expect(result.lockedOut, isFalse);
      });

      test('rejects incorrect PIN', () async {
        await manager.initialize();

        // Set up PIN
        await manager.setPin('1234');

        // Capture stored values
        final capturedHash = verify(
          () => mockSecureStorage.writeSecure(
            'reusable_app_lock_pin_hash',
            captureAny(),
          ),
        ).captured.last as String;

        final capturedSalt = verify(
          () => mockSecureStorage.writeSecure(
            'reusable_app_lock_pin_salt',
            captureAny(),
          ),
        ).captured.last as String;

        // Reset
        reset(mockSecureStorage);
        reset(mockSettingsStorage);
        when(() => mockSecureStorage.readSecure('reusable_app_lock_pin_hash'))
            .thenAnswer((_) async => capturedHash);
        when(() => mockSecureStorage.readSecure('reusable_app_lock_pin_salt'))
            .thenAnswer((_) async => capturedSalt);
        when(() => mockSettingsStorage.readInt(any()))
            .thenAnswer((_) async => 0);
        when(() => mockSettingsStorage.writeInt(any(), any()))
            .thenAnswer((_) async {});

        // Verify with wrong PIN
        final result = await manager.verifyPin('9999');

        expect(result.success, isFalse);
        expect(result.attemptsRemaining, 2); // maxAttempts is 3
        expect(result.lockedOut, isFalse);
      });

      test('locks out after max failed attempts', () async {
        await manager.initialize();

        // Set up PIN
        await manager.setPin('1234');

        // Capture stored values
        final capturedHash = verify(
          () => mockSecureStorage.writeSecure(
            'reusable_app_lock_pin_hash',
            captureAny(),
          ),
        ).captured.last as String;

        final capturedSalt = verify(
          () => mockSecureStorage.writeSecure(
            'reusable_app_lock_pin_salt',
            captureAny(),
          ),
        ).captured.last as String;

        // Reset
        reset(mockSecureStorage);
        reset(mockSettingsStorage);
        when(() => mockSecureStorage.readSecure('reusable_app_lock_pin_hash'))
            .thenAnswer((_) async => capturedHash);
        when(() => mockSecureStorage.readSecure('reusable_app_lock_pin_salt'))
            .thenAnswer((_) async => capturedSalt);

        var failedAttempts = 0;
        when(() => mockSettingsStorage.readInt('reusable_app_lock_failed_attempts'))
            .thenAnswer((_) async => failedAttempts);
        when(() => mockSettingsStorage.writeInt(
              'reusable_app_lock_failed_attempts',
              any(),
            )).thenAnswer((invocation) async {
          failedAttempts = invocation.positionalArguments[1] as int;
        });
        when(() => mockSettingsStorage.write(any(), any()))
            .thenAnswer((_) async {});

        // Attempt 1
        var result = await manager.verifyPin('9999');
        expect(result.success, isFalse);
        expect(result.attemptsRemaining, 2);

        // Attempt 2
        result = await manager.verifyPin('9999');
        expect(result.success, isFalse);
        expect(result.attemptsRemaining, 1);

        // Attempt 3 - should trigger lockout
        result = await manager.verifyPin('9999');
        expect(result.success, isFalse);
        expect(result.lockedOut, isTrue);
        expect(result.attemptsRemaining, 0);
      });
    });

    group('changePin', () {
      test('changes PIN with correct old PIN', () async {
        await manager.initialize();

        // Set initial PIN
        await manager.setPin('1234');

        // Capture values
        final capturedHash = verify(
          () => mockSecureStorage.writeSecure(
            'reusable_app_lock_pin_hash',
            captureAny(),
          ),
        ).captured.last as String;

        final capturedSalt = verify(
          () => mockSecureStorage.writeSecure(
            'reusable_app_lock_pin_salt',
            captureAny(),
          ),
        ).captured.last as String;

        // Reset
        reset(mockSecureStorage);
        reset(mockSettingsStorage);
        when(() => mockSecureStorage.readSecure('reusable_app_lock_pin_hash'))
            .thenAnswer((_) async => capturedHash);
        when(() => mockSecureStorage.readSecure('reusable_app_lock_pin_salt'))
            .thenAnswer((_) async => capturedSalt);
        when(() => mockSecureStorage.writeSecure(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockSettingsStorage.readInt(any()))
            .thenAnswer((_) async => 0);
        when(() => mockSettingsStorage.writeInt(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockSettingsStorage.write(any(), any()))
            .thenAnswer((_) async {});

        // Change PIN
        final result = await manager.changePin(
          oldPin: '1234',
          newPin: '5678',
        );

        expect(result, isTrue);
      });

      test('rejects change with incorrect old PIN', () async {
        await manager.initialize();

        // Set initial PIN
        await manager.setPin('1234');

        // Capture values
        final capturedHash = verify(
          () => mockSecureStorage.writeSecure(
            'reusable_app_lock_pin_hash',
            captureAny(),
          ),
        ).captured.last as String;

        final capturedSalt = verify(
          () => mockSecureStorage.writeSecure(
            'reusable_app_lock_pin_salt',
            captureAny(),
          ),
        ).captured.last as String;

        // Reset
        reset(mockSecureStorage);
        reset(mockSettingsStorage);
        when(() => mockSecureStorage.readSecure('reusable_app_lock_pin_hash'))
            .thenAnswer((_) async => capturedHash);
        when(() => mockSecureStorage.readSecure('reusable_app_lock_pin_salt'))
            .thenAnswer((_) async => capturedSalt);
        when(() => mockSettingsStorage.readInt(any()))
            .thenAnswer((_) async => 0);
        when(() => mockSettingsStorage.writeInt(any(), any()))
            .thenAnswer((_) async {});

        // Try to change with wrong old PIN
        final result = await manager.changePin(
          oldPin: '9999',
          newPin: '5678',
        );

        expect(result, isFalse);
      });
    });

    group('biometric', () {
      test('enables biometric successfully', () async {
        await manager.initialize();

        when(() => mockLocalAuth.authenticate(reason: any(named: 'reason')))
            .thenAnswer((_) async => true);

        final result = await manager.enableBiometric();

        expect(result, isTrue);
        verify(() => mockSecureStorage.writeSecure(
              'reusable_app_lock_biometric_enabled',
              'true',
            )).called(1);
      });

      test('fails to enable biometric when device not supported', () async {
        await manager.initialize();

        when(() => mockLocalAuth.canCheckBiometrics())
            .thenAnswer((_) async => false);

        final result = await manager.enableBiometric();

        expect(result, isFalse);
      });

      test('disables biometric successfully', () async {
        await manager.initialize();

        final result = await manager.disableBiometric();

        expect(result, isTrue);
        verify(() => mockSecureStorage.deleteSecure(
              'reusable_app_lock_biometric_enabled',
            )).called(1);
      });
    });

    group('lock/unlock', () {
      test('locks app manually', () async {
        await manager.initialize();

        await manager.lockNow();

        final isLocked = await manager.isLocked();
        expect(isLocked, isTrue);
      });

      test('unlocks app', () async {
        await manager.initialize();

        await manager.lockNow();
        await manager.unlock();

        final isLocked = await manager.isLocked();
        expect(isLocked, isFalse);
      });
    });

    group('reset', () {
      test('resets and removes all data', () async {
        await manager.initialize();

        await manager.reset();

        verify(() => mockSecureStorage.deleteSecure('reusable_app_lock_pin_hash'))
            .called(1);
        verify(() => mockSecureStorage.deleteSecure('reusable_app_lock_pin_salt'))
            .called(1);
        verify(() => mockSecureStorage.deleteSecure(
              'reusable_app_lock_biometric_enabled',
            )).called(1);
      });
    });
  });
}
