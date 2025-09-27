import 'package:flutter/material.dart';

/// A tutorial overlay widget that shows step-by-step guidance
class TutorialOverlay extends StatefulWidget {
  final int currentStep;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;
  final VoidCallback onComplete;

  const TutorialOverlay({
    super.key,
    required this.currentStep,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
    required this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tutorialSteps = _getTutorialSteps();

    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildContent(context, tutorialSteps),
                  const SizedBox(height: 24),
                  _buildNavigation(context, tutorialSteps),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Tutorial',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: widget.onSkip,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, List<TutorialStep> steps) {
    if (widget.currentStep >= steps.length) {
      return const SizedBox.shrink();
    }

    final step = steps[widget.currentStep];

    return Column(
      children: [
        if (step.icon != null) ...[
          Icon(
            step.icon,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
        ],
        Text(
          step.title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          step.description,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNavigation(BuildContext context, List<TutorialStep> steps) {
    final isLastStep = widget.currentStep >= steps.length - 1;
    final isFirstStep = widget.currentStep <= 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: isFirstStep ? null : widget.onPrevious,
          child: const Text('Previous'),
        ),
        Row(
          children: [
            for (int i = 0; i < steps.length; i++) ...[
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == widget.currentStep
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
            ],
          ],
        ),
        Row(
          children: [
            TextButton(onPressed: widget.onSkip, child: const Text('Skip')),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: isLastStep ? widget.onComplete : widget.onNext,
              child: Text(isLastStep ? 'Complete' : 'Next'),
            ),
          ],
        ),
      ],
    );
  }

  List<TutorialStep> _getTutorialSteps() {
    return [
      TutorialStep(
        title: 'Welcome to 3D Object Viewer',
        description:
            'This tutorial will guide you through loading, viewing, and comparing 3D objects.',
        icon: Icons.view_in_ar_rounded,
      ),
      TutorialStep(
        title: 'Load Your First Object',
        description:
            'Tap "Load Object A" to select a 3D model file (.obj or .stl format).',
        icon: Icons.upload_file_rounded,
      ),
      TutorialStep(
        title: 'Load a Second Object',
        description:
            'Tap "Load Object B" to load another 3D model for comparison.',
        icon: Icons.upload_file_rounded,
      ),
      TutorialStep(
        title: 'Navigate to 3D Viewer',
        description:
            'Tap "View Objects" to open the 3D viewer where you can manipulate and compare your objects.',
        icon: Icons.view_in_ar_rounded,
      ),
      TutorialStep(
        title: 'Transform Objects',
        description:
            'Use the control panel to move, rotate, and scale Object B to align it with Object A.',
        icon: Icons.transform_rounded,
      ),
      TutorialStep(
        title: 'Run Procrustes Analysis',
        description:
            'Tap "Compare" to run the Procrustes analysis and get detailed similarity metrics.',
        icon: Icons.analytics_rounded,
      ),
      TutorialStep(
        title: 'Export Results',
        description:
            'Export your analysis results as JSON or CSV files for further analysis.',
        icon: Icons.file_download_rounded,
      ),
      TutorialStep(
        title: 'You\'re All Set!',
        description:
            'You now know how to use the 3D Object Viewer. Start exploring with your own 3D models!',
        icon: Icons.check_circle_rounded,
      ),
    ];
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData? icon;

  TutorialStep({required this.title, required this.description, this.icon});
}
