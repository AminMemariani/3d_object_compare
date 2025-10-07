import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../providers/model_viewer_provider.dart';

class ModelViewerPage extends StatefulWidget {
  const ModelViewerPage({super.key});

  @override
  State<ModelViewerPage> createState() => _ModelViewerPageState();
}

class _ModelViewerPageState extends State<ModelViewerPage>
    with TickerProviderStateMixin {
  late AnimationController _panelController;
  late AnimationController _fabController;
  late Animation<double> _panelAnimation;
  late Animation<double> _fabAnimation;

  bool _isControlPanelVisible = false;
  bool _isComparing = false;

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _panelAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _panelController, curve: Curves.easeInOut),
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    _fabController.forward();
  }

  @override
  void dispose() {
    _panelController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.15),
              Theme.of(context).colorScheme.surface,
              Theme.of(
                context,
              ).colorScheme.secondaryContainer.withValues(alpha: 0.12),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _build3DViewport(context),
              _buildTopControls(context),
              _buildControlPanel(context),
              _buildFloatingCompareButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DViewport(BuildContext context) {
    return Consumer<ModelViewerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading 3D model...'),
              ],
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => provider.setError(null),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.currentModel == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.view_in_ar_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No 3D model loaded',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Load a model from the home screen to start viewing',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Go to Home'),
                ),
              ],
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ModelViewer(
              src: provider.currentModel!.path,
              alt: provider.currentModel!.name,
              ar: true,
              autoRotate: provider.isAutoRotating,
              cameraControls: true,
              backgroundColor: Color(
                int.parse(provider.backgroundColor.replaceFirst('#', '0xFF')),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopControls(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Consumer<ModelViewerProvider>(
                builder: (context, provider, child) {
                  return Text(
                    provider.currentModel?.name ?? '3D Viewer',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
            Consumer<ModelViewerProvider>(
              builder: (context, provider, child) {
                return IconButton(
                  icon: Icon(
                    provider.isAutoRotating
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                  ),
                  onPressed: () => provider.toggleAutoRotate(),
                  tooltip: provider.isAutoRotating
                      ? 'Pause rotation'
                      : 'Start rotation',
                );
              },
            ),
            IconButton(
              icon: Icon(
                _isControlPanelVisible
                    ? Icons.tune_rounded
                    : Icons.tune_outlined,
              ),
              onPressed: _toggleControlPanel,
              tooltip: 'Toggle controls',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context) {
    return AnimatedBuilder(
      animation: _panelAnimation,
      builder: (context, child) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Transform.translate(
            offset: Offset(0, (1 - _panelAnimation.value) * 400),
            child: Opacity(
              opacity: _panelAnimation.value,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildPanelHandle(),
                    Expanded(child: _buildPanelContent(context)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPanelHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildPanelContent(BuildContext context) {
    return Consumer<ModelViewerProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Model Controls',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildScaleControl(context, provider),
                      const SizedBox(height: 24),
                      _buildRotationControls(context, provider),
                      const SizedBox(height: 24),
                      _buildBackgroundControl(context, provider),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScaleControl(
    BuildContext context,
    ModelViewerProvider provider,
  ) {
    return _buildControlSection(context, 'Scale', Icons.zoom_in_rounded, [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Model Scale',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: provider.currentScale,
                  min: 0.1,
                  max: 3.0,
                  divisions: 29,
                  onChanged: (value) => provider.updateScale(value),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${provider.currentScale.toStringAsFixed(1)}x',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildRotationControls(
    BuildContext context,
    ModelViewerProvider provider,
  ) {
    return _buildControlSection(
      context,
      'Rotation',
      Icons.rotate_right_rounded,
      [
        Row(
          children: [
            Expanded(
              child: _buildRotationButton(
                context,
                'X',
                Icons.rotate_90_degrees_cw_rounded,
                () => _rotateModel(provider, 'x'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRotationButton(
                context,
                'Y',
                Icons.rotate_90_degrees_cw_rounded,
                () => _rotateModel(provider, 'y'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRotationButton(
                context,
                'Z',
                Icons.rotate_90_degrees_cw_rounded,
                () => _rotateModel(provider, 'z'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Auto Rotate'),
          subtitle: const Text('Continuously rotate the model'),
          value: provider.isAutoRotating,
          onChanged: (value) => provider.toggleAutoRotate(),
        ),
      ],
    );
  }

  Widget _buildRotationButton(
    BuildContext context,
    String axis,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 8),
                Text(
                  axis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundControl(
    BuildContext context,
    ModelViewerProvider provider,
  ) {
    return _buildControlSection(context, 'Background', Icons.palette_rounded, [
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildColorOption(provider, '#FFFFFF', Colors.white, 'White'),
          _buildColorOption(provider, '#000000', Colors.black, 'Black'),
          _buildColorOption(
            provider,
            '#F5F5F5',
            Colors.grey[200]!,
            'Light Gray',
          ),
          _buildColorOption(provider, '#E3F2FD', Colors.blue[50]!, 'Blue'),
          _buildColorOption(provider, '#E8F5E8', Colors.green[50]!, 'Green'),
          _buildColorOption(provider, '#FFF3E0', Colors.orange[50]!, 'Orange'),
        ],
      ),
    ]);
  }

  Widget _buildColorOption(
    ModelViewerProvider provider,
    String color,
    Color materialColor,
    String label,
  ) {
    final isSelected = provider.backgroundColor == color;
    return GestureDetector(
      onTap: () => provider.updateBackgroundColor(color),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: materialColor,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ),
    );
  }

  Widget _buildControlSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildFloatingCompareButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        return Positioned(
          bottom: _isControlPanelVisible ? 420 : 24,
          right: 24,
          child: Transform.scale(
            scale: _fabAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: _isComparing ? _exitCompareMode : _enterCompareMode,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                icon: Icon(
                  _isComparing
                      ? Icons.close_rounded
                      : Icons.compare_arrows_rounded,
                ),
                label: Text(_isComparing ? 'Exit Compare' : 'Compare'),
                elevation: 0,
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleControlPanel() {
    setState(() {
      _isControlPanelVisible = !_isControlPanelVisible;
    });

    if (_isControlPanelVisible) {
      _panelController.forward();
    } else {
      _panelController.reverse();
    }
  }

  void _rotateModel(ModelViewerProvider provider, String axis) {
    // This would integrate with the 3D model rotation
    // For now, we'll just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rotating model on $axis axis'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _enterCompareMode() {
    setState(() {
      _isComparing = true;
    });
    // Navigate to compare view or show comparison UI
    Navigator.of(context).pushNamed('/compare-view');
  }

  void _exitCompareMode() {
    setState(() {
      _isComparing = false;
    });
    Navigator.of(context).pop();
  }
}
