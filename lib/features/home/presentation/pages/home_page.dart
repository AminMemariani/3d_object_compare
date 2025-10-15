import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../model_viewer/presentation/providers/object_loader_provider.dart';
import '../../../tutorial/presentation/widgets/tutorial_button.dart';
import '../../../tutorial/presentation/widgets/tutorial_overlay.dart';
import '../../../tutorial/presentation/providers/tutorial_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surfaceContainerLowest,
                ],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 32),
                        _buildObjectLoaderSection(context),
                        const SizedBox(height: 24),
                        _buildQuickActionsSection(context),
                        const Spacer(),
                        _buildFooter(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Tutorial overlay
          Consumer<TutorialProvider>(
            builder: (context, tutorialProvider, child) {
              if (tutorialProvider.isTutorialActive) {
                return TutorialOverlay(
                  currentStep: tutorialProvider.currentStep,
                  onNext: tutorialProvider.nextStep,
                  onPrevious: tutorialProvider.previousStep,
                  onSkip: tutorialProvider.skipTutorial,
                  onComplete: tutorialProvider.completeTutorial,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '3D Object Viewer',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Load, view, and compare 3D objects',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        TutorialButton(
          onPressed: () {
            context.read<TutorialProvider>().startTutorial();
          },
        ),
      ],
    );
  }

  Widget _buildObjectLoaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Load Objects',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildObjectCard(
                context,
                'Object A',
                'Load first 3D object',
                Icons.view_in_ar,
                () => _loadObjectA(context),
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildObjectCard(
                context,
                'Object B',
                'Load second 3D object',
                Icons.view_in_ar,
                () => _loadObjectB(context),
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildObjectCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    Color accentColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 32, color: accentColor),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Compare',
                Icons.compare_arrows_rounded,
                // Disable compare until both objects are loaded
                (Provider.of<ObjectLoaderProvider>(context).hasObjectA &&
                        Provider.of<ObjectLoaderProvider>(context).hasObjectB)
                    ? () => _openCompareView(context)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(), // Empty space to maintain layout
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback? onTap,
  ) {
    final bool isEnabled = onTap != null;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Opacity(
              opacity: isEnabled ? 1.0 : 0.5,
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: isEnabled
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: Theme.of(context,
                    ).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isEnabled
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Load objects to start viewing and comparing 3D models',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadObjectA(BuildContext context) async {
    // DIAGNOSTIC: Verify button click is working
    print('🔴 DEBUG: _loadObjectA called - button click IS working!');
    debugPrint('🔴 DEBUG: _loadObjectA called - button click IS working!');

    final objectProvider = Provider.of<ObjectLoaderProvider>(
      context,
      listen: false,
    );

    // Show loading indicator
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Opening file picker...'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );

    print('🔴 DEBUG: About to call objectProvider.loadObjectA()');
    await objectProvider.loadObjectA();
    print('🔴 DEBUG: objectProvider.loadObjectA() returned');

    if (!mounted) return;

    // Clear the loading message
    ScaffoldMessenger.of(context).clearSnackBars();

    if (objectProvider.error != null) {
      print('🔴 DEBUG: Error occurred: ${objectProvider.error}');
      _showErrorMessage(context, objectProvider.error!);
    } else if (objectProvider.hasObjectA) {
      print('🔴 DEBUG: Object A loaded successfully');
      _showSuccessMessage(context, 'Object A loaded successfully!');
      // Navigate to viewer to show the object
      Navigator.of(context).pushNamed('/compare-view');
    } else {
      print('🔴 DEBUG: No object loaded, no error - user cancelled');
      // User cancelled file picker - show subtle message
      _showInfoMessage(context, 'File selection cancelled');
    }
  }

  Future<void> _loadObjectB(BuildContext context) async {
    final objectProvider = Provider.of<ObjectLoaderProvider>(
      context,
      listen: false,
    );

    // Show loading indicator
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Opening file picker...'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );

    await objectProvider.loadObjectB();

    if (!mounted) return;

    // Clear the loading message
    ScaffoldMessenger.of(context).clearSnackBars();

    if (objectProvider.error != null) {
      _showErrorMessage(context, objectProvider.error!);
    } else if (objectProvider.hasObjectB) {
      _showSuccessMessage(context, 'Object B loaded successfully!');
      // Navigate to viewer to show the object
      Navigator.of(context).pushNamed('/compare-view');
    } else {
      // User cancelled file picker - show subtle message
      _showInfoMessage(context, 'File selection cancelled');
    }
  }

  void _openCompareView(BuildContext context) {
    Navigator.of(context).pushNamed('/compare-view');
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showInfoMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.grey.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
