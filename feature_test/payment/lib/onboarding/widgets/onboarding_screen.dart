import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/onboarding_config.dart';
import '../models/onboarding_page.dart';
import '../services/onboarding_service.dart';
import 'page_indicator.dart';
import 'onboarding_page_widget.dart';

/// Main onboarding screen widget
///
/// Displays a series of onboarding pages with navigation controls.
///
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => OnboardingScreen(
///       config: OnboardingConfig(
///         pages: [
///           OnboardingPage.withIcon(
///             title: 'Welcome',
///             description: 'Welcome to our app!',
///             icon: Icons.waving_hand,
///           ),
///         ],
///         onComplete: () => Navigator.pop(context),
///       ),
///     ),
///   ),
/// );
/// ```
class OnboardingScreen extends StatefulWidget {
  /// Configuration for the onboarding flow
  final OnboardingConfig config;

  /// Optional onboarding service for persistence
  final OnboardingService? onboardingService;

  const OnboardingScreen({
    super.key,
    required this.config,
    this.onboardingService,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoAdvanceTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    if (widget.config.autoAdvance) {
      _startAutoAdvance();
    }
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(widget.config.autoAdvanceDuration, () {
      if (_currentPage < widget.config.pages.length - 1) {
        _goToNextPage();
      }
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    // Update last page in service
    widget.onboardingService?.updateLastPage(page);

    // Haptic feedback
    if (widget.config.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }

    // Callback
    widget.config.onPageChanged?.call(page);

    // Restart auto-advance timer
    if (widget.config.autoAdvance) {
      _startAutoAdvance();
    }
  }

  void _goToNextPage() {
    if (_currentPage < widget.config.pages.length - 1) {
      _pageController.nextPage(
        duration: widget.config.transitionDuration,
        curve: widget.config.transitionCurve,
      );
    } else {
      _handleComplete();
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: widget.config.transitionDuration,
        curve: widget.config.transitionCurve,
      );
    }
  }

  void _handleSkip() async {
    // Mark as skipped in service
    await widget.onboardingService?.skipOnboarding(pageReached: _currentPage);

    // Haptic feedback
    if (widget.config.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    // Callback
    widget.config.onSkip?.call();
  }

  void _handleComplete() async {
    // Mark as completed in service
    await widget.onboardingService?.completeOnboarding(
      pageReached: widget.config.pages.length - 1,
    );

    // Haptic feedback
    if (widget.config.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    // Callback
    widget.config.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: widget.config.backgroundGradientColors != null
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.config.backgroundGradientColors!,
                  begin: widget.config.gradientBegin ?? Alignment.topCenter,
                  end: widget.config.gradientEnd ?? Alignment.bottomCenter,
                ),
              )
            : null,
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with skip button and progress
              _buildTopBar(),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: widget.config.allowPageSwipe
                      ? const PageScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  itemCount: widget.config.pages.length,
                  itemBuilder: (context, index) {
                    return OnboardingPageWidget(
                      page: widget.config.pages[index],
                      config: widget.config,
                    );
                  },
                ),
              ),

              // Bottom controls
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skip button
          if (widget.config.showSkipButton && _currentPage < widget.config.pages.length - 1)
            TextButton(
              onPressed: _handleSkip,
              style: widget.config.skipButtonStyle,
              child: Text(widget.config.skipButtonText),
            )
          else
            const SizedBox(width: 80),

          // Progress indicator
          if (widget.config.showProgress)
            ProgressPageIndicator(
              pageCount: widget.config.pages.length,
              currentPage: _currentPage,
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    final isLastPage = _currentPage == widget.config.pages.length - 1;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page indicator (dots)
          if (widget.config.showPageIndicator)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: PageIndicator(
                pageCount: widget.config.pages.length,
                currentPage: _currentPage,
                style: widget.config.indicatorStyle,
                onDotTapped: widget.config.allowPageSwipe
                    ? (index) {
                        _pageController.animateToPage(
                          index,
                          duration: widget.config.transitionDuration,
                          curve: widget.config.transitionCurve,
                        );
                      }
                    : null,
              ),
            ),

          // Next/Done button
          if (widget.config.showNextButton)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goToNextPage,
                style: widget.config.buttonStyle,
                child: Text(
                  isLastPage
                      ? widget.config.doneButtonText
                      : widget.config.nextButtonText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
