import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/onboarding_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingService', () {
    late OnboardingService service;

    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
      service = OnboardingService();
      await service.initialize();
    });

    test('initializes successfully', () {
      expect(service.isInitialized, true);
    });

    test('throws when not initialized', () {
      final uninitializedService = OnboardingService();

      expect(
        () => uninitializedService.isOnboardingCompleted(),
        throwsStateError,
      );
    });

    test('defaults to not completed', () async {
      final completed = await service.isOnboardingCompleted();
      expect(completed, false);
    });

    test('marks onboarding as completed', () async {
      await service.completeOnboarding();

      final completed = await service.isOnboardingCompleted();
      expect(completed, true);
    });

    test('stores completion timestamp', () async {
      final beforeCompletion = DateTime.now();
      await service.completeOnboarding();
      final afterCompletion = DateTime.now();

      final completedAt = await service.getCompletedAt();

      expect(completedAt, isNotNull);
      expect(completedAt!.isAfter(beforeCompletion), true);
      expect(completedAt.isBefore(afterCompletion), true);
    });

    test('stores last page reached', () async {
      await service.completeOnboarding(pageReached: 4);

      final lastPage = await service.getLastPageReached();
      expect(lastPage, 4);
    });

    test('marks onboarding as skipped', () async {
      await service.skipOnboarding(pageReached: 2);

      final completed = await service.isOnboardingCompleted();
      final skipped = await service.wasOnboardingSkipped();

      expect(completed, true); // Skipping also completes
      expect(skipped, true);
    });

    test('distinguishes between completed and skipped', () async {
      // Complete normally
      await service.completeOnboarding();

      final skipped = await service.wasOnboardingSkipped();
      expect(skipped, false);
    });

    test('resets onboarding state', () async {
      await service.completeOnboarding(pageReached: 3);
      await service.resetOnboarding();

      final completed = await service.isOnboardingCompleted();
      final completedAt = await service.getCompletedAt();
      final lastPage = await service.getLastPageReached();

      expect(completed, false);
      expect(completedAt, null);
      expect(lastPage, null);
    });

    test('updates last page without completing', () async {
      await service.updateLastPage(2);

      final completed = await service.isOnboardingCompleted();
      final lastPage = await service.getLastPageReached();

      expect(completed, false);
      expect(lastPage, 2);
    });

    test('persists across sessions', () async {
      await service.completeOnboarding(pageReached: 5);

      // Create new service instance (simulating new session)
      final newService = OnboardingService();
      await newService.initialize();

      final completed = await newService.isOnboardingCompleted();
      final lastPage = await newService.getLastPageReached();

      expect(completed, true);
      expect(lastPage, 5);
    });

    test('exports onboarding data', () async {
      await service.completeOnboarding(pageReached: 3);

      final data = await service.getOnboardingData();

      expect(data['completed'], true);
      expect(data['completed_at'], isNotNull);
      expect(data['last_page'], 3);
      expect(data['skipped'], false);
    });
  });

  group('OnboardingService with versioning', () {
    late OnboardingService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = OnboardingService(version: '1.0.0');
      await service.initialize();
    });

    test('tracks version on completion', () async {
      await service.completeOnboarding();

      final version = await service.getCompletedVersion();
      expect(version, '1.0.0');
    });

    test('detects version change', () async {
      await service.completeOnboarding();

      // Create new service with different version
      final newService = OnboardingService(version: '2.0.0');
      await newService.initialize();

      final hasChanged = await newService.hasVersionChanged();
      expect(hasChanged, true);
    });

    test('requires re-onboarding when version changes', () async {
      await service.completeOnboarding();

      // Create new service with different version
      final newService = OnboardingService(version: '2.0.0');
      await newService.initialize();

      final completed = await newService.isOnboardingCompleted();
      expect(completed, false); // Should show onboarding again
    });

    test('maintains completion with same version', () async {
      await service.completeOnboarding();

      // Create new service with same version
      final newService = OnboardingService(version: '1.0.0');
      await newService.initialize();

      final completed = await newService.isOnboardingCompleted();
      expect(completed, true);
    });

    test('shouldShowOnboarding respects version', () async {
      await service.completeOnboarding();

      // Same version - should not show
      final sameVersionService = OnboardingService(version: '1.0.0');
      await sameVersionService.initialize();
      expect(await sameVersionService.shouldShowOnboarding(), false);

      // Different version - should show
      final newVersionService = OnboardingService(version: '2.0.0');
      await newVersionService.initialize();
      expect(await newVersionService.shouldShowOnboarding(), true);
    });
  });
}
