/// Conflict resolution strategy
enum ConflictResolutionStrategy {
  serverWins,
  clientWins,
  merge,
  promptUser,
}

/// Synchronization policy
class SyncPolicy {
  final ConflictResolutionStrategy conflictResolution;
  final bool syncOnlyOnWifi;
  final bool syncOnlyWhenCharging;
  final bool requiresBackgroundData;

  const SyncPolicy({
    this.conflictResolution = ConflictResolutionStrategy.serverWins,
    this.syncOnlyOnWifi = false,
    this.syncOnlyWhenCharging = false,
    this.requiresBackgroundData = true,
  });

  const SyncPolicy.conservative()
      : this(
          syncOnlyOnWifi: true,
          syncOnlyWhenCharging: true,
        );

  const SyncPolicy.aggressive()
      : this(
          syncOnlyOnWifi: false,
          syncOnlyWhenCharging: false,
        );
}
