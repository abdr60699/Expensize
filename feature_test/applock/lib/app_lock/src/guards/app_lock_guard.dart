import 'package:flutter/material.dart';
import '../app_lock_manager.dart';
import '../widgets/app_lock_screen.dart';

/// Widget that blocks child until app is unlocked
///
/// Can be used to wrap a screen or as a navigation guard for routes.
/// Shows lock screen when app is locked, and shows child when unlocked.
///
/// Example usage:
/// ```dart
/// AppLockGuard(
///   manager: appLockManager,
///   child: HomePage(),
/// )
/// ```
class AppLockGuard extends StatefulWidget {
  /// The child widget to show when unlocked
  final Widget child;

  /// App lock manager instance
  final AppLockManager manager;

  /// Custom lock screen widget (if null, uses default AppLockScreen)
  final Widget? lockScreen;

  /// Whether to show lock screen as fullscreen or dialog
  final bool showAsDialog;

  /// Whether to check lock state on init
  final bool checkOnInit;

  /// Callback when unlocked
  final VoidCallback? onUnlocked;

  /// Callback when locked
  final VoidCallback? onLocked;

  const AppLockGuard({
    super.key,
    required this.child,
    required this.manager,
    this.lockScreen,
    this.showAsDialog = false,
    this.checkOnInit = true,
    this.onUnlocked,
    this.onLocked,
  });

  @override
  State<AppLockGuard> createState() => _AppLockGuardState();
}

class _AppLockGuardState extends State<AppLockGuard>
    with WidgetsBindingObserver {
  bool _isLocked = true;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.checkOnInit) {
      _checkLockState();
    } else {
      setState(() => _isChecking = false);
    }

    // Listen to lock state changes
    widget.manager.onLockStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isLocked = state.locked;
        });

        if (state.locked) {
          widget.onLocked?.call();
        } else {
          widget.onUnlocked?.call();
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Lock when app goes to background
        widget.manager.lockNow();
        break;

      case AppLifecycleState.resumed:
        // Check lock state when app resumes
        _checkLockState();
        break;

      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _checkLockState() async {
    final isEnabled = await widget.manager.isEnabled();
    final isLocked = await widget.manager.isLocked();

    if (mounted) {
      setState(() {
        _isLocked = isEnabled && isLocked;
        _isChecking = false;
      });
    }
  }

  Future<void> _handleUnlock() async {
    if (mounted) {
      setState(() {
        _isLocked = false;
      });
      widget.onUnlocked?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking initial state
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show child if not locked
    if (!_isLocked) {
      return widget.child;
    }

    // Show lock screen
    if (widget.showAsDialog) {
      return Stack(
        children: [
          // Blurred background
          widget.child,

          // Lock screen overlay
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: _buildLockScreen(),
            ),
          ),
        ],
      );
    } else {
      return _buildLockScreen();
    }
  }

  Widget _buildLockScreen() {
    if (widget.lockScreen != null) {
      return widget.lockScreen!;
    }

    return AppLockScreen(
      manager: widget.manager,
      mode: AppLockMode.verify,
      onVerified: _handleUnlock,
      showBiometric: true,
    );
  }
}

/// Route-aware app lock guard
///
/// Use this in navigation routes to protect specific screens.
/// Automatically locks/unlocks based on route changes.
class AppLockRouteGuard extends StatelessWidget {
  /// The child widget (route screen)
  final Widget child;

  /// App lock manager instance
  final AppLockManager manager;

  /// Custom lock screen
  final Widget? lockScreen;

  const AppLockRouteGuard({
    super.key,
    required this.child,
    required this.manager,
    this.lockScreen,
  });

  @override
  Widget build(BuildContext context) {
    return AppLockGuard(
      manager: manager,
      lockScreen: lockScreen,
      checkOnInit: true,
      child: child,
    );
  }
}
