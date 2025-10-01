import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../providers/object_loader_provider.dart';
import '../../domain/entities/object_3d.dart';
import '../../domain/entities/procrustes_result.dart';
import '../widgets/procrustes_results_card.dart';

class SuperimposedViewerPage extends StatefulWidget {
  const SuperimposedViewerPage({super.key});

  @override
  State<SuperimposedViewerPage> createState() => _SuperimposedViewerPageState();
}

class _SuperimposedViewerPageState extends State<SuperimposedViewerPage>
    with TickerProviderStateMixin {
  late AnimationController _panelController;
  late AnimationController _fabController;
  late Animation<double> _panelAnimation;
  late Animation<double> _fabAnimation;

  bool _isControlPanelVisible = false;
  bool _showObjectA = true;
  bool _showObjectB = true;

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _build3DViewport(context),
              _buildTopControls(context),
              _buildControlPanel(context),
              _buildFloatingActionButtons(context),
              _buildResultsCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DViewport(BuildContext context) {
    return Consumer<ObjectLoaderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading 3D objects...'),
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
                  onPressed: () {
                    // Clear error by reloading
                    Navigator.of(
                      context,
                    ).pushReplacementNamed('/superimposed-viewer');
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!provider.hasObjectA && !provider.hasObjectB) {
          return _buildEmptyState(context);
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
            child: _buildSuperimposedView(context, provider),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            'No 3D Objects Loaded',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Load .obj or .stl files to start viewing',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => Provider.of<ObjectLoaderProvider>(
                  context,
                  listen: false,
                ).loadObjectA(),
                icon: const Icon(Icons.upload_rounded),
                label: const Text('Load Object A'),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: () => Provider.of<ObjectLoaderProvider>(
                  context,
                  listen: false,
                ).loadObjectB(),
                icon: const Icon(Icons.upload_rounded),
                label: const Text('Load Object B'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuperimposedView(
    BuildContext context,
    ObjectLoaderProvider provider,
  ) {
    return Stack(
      children: [
        // Object A (Base object)
        if (_showObjectA && provider.objectA != null)
          _buildObjectView(context, provider.objectA!, 'Object A'),

        // Object B (Overlay object)
        if (_showObjectB && provider.objectB != null)
          _buildObjectView(context, provider.objectB!, 'Object B'),

        // Alignment indicator
        if (provider.hasObjectA && provider.hasObjectB)
          _buildAlignmentIndicator(context, provider),
      ],
    );
  }

  Widget _buildObjectView(BuildContext context, Object3D object, String label) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: object.color.red > 0.5 ? Colors.red : Colors.blue,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Placeholder for 3D object (since we can't directly render .obj/.stl)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(
                    (object.color.red * 255).round(),
                    (object.color.green * 255).round(),
                    (object.color.blue * 255).round(),
                    object.opacity * 0.3,
                  ),
                  Color.fromRGBO(
                    (object.color.red * 255).round(),
                    (object.color.green * 255).round(),
                    (object.color.blue * 255).round(),
                    object.opacity * 0.6,
                  ),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.view_in_ar_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            object.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.greenAccent, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Successfully Loaded',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, color: Colors.white70, size: 20),
                          const SizedBox(height: 8),
                          Text(
                            'Object data is loaded and ready for analysis',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Visual 3D rendering coming in future update',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Transform info overlay
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Pos: ${object.position.x.toStringAsFixed(1)}, ${object.position.y.toStringAsFixed(1)}, ${object.position.z.toStringAsFixed(1)}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlignmentIndicator(
    BuildContext context,
    ObjectLoaderProvider provider,
  ) {
    final alignmentScore = provider.getAlignmentScore();
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: alignmentScore > 80
              ? Colors.green.withValues(alpha: 0.9)
              : alignmentScore > 50
              ? Colors.orange.withValues(alpha: 0.9)
              : Colors.red.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              alignmentScore > 80 ? Icons.check_circle : Icons.warning,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'Alignment: ${alignmentScore.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
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
              child: Text(
                'Superimposed 3D Viewer',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Consumer<ObjectLoaderProvider>(
              builder: (context, provider, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _showObjectA ? Icons.visibility : Icons.visibility_off,
                        color: Colors.blue,
                      ),
                      onPressed: () =>
                          setState(() => _showObjectA = !_showObjectA),
                      tooltip: 'Toggle Object A',
                    ),
                    IconButton(
                      icon: Icon(
                        _showObjectB ? Icons.visibility : Icons.visibility_off,
                        color: Colors.pink,
                      ),
                      onPressed: () =>
                          setState(() => _showObjectB = !_showObjectB),
                      tooltip: 'Toggle Object B',
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded),
                      onPressed: _toggleControlPanel,
                      tooltip: 'Toggle controls',
                    ),
                  ],
                );
              },
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
            offset: Offset(0, (1 - _panelAnimation.value) * 500),
            child: Opacity(
              opacity: _panelAnimation.value,
              child: Container(
                height: 500,
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
    return Consumer<ObjectLoaderProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Object B Controls',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (provider.hasObjectB) ...[
                        _buildPositionControls(context, provider),
                        const SizedBox(height: 24),
                        _buildRotationControls(context, provider),
                        const SizedBox(height: 24),
                        _buildScaleControls(context, provider),
                        const SizedBox(height: 24),
                        _buildColorControls(context, provider),
                        const SizedBox(height: 24),
                        _buildProcrustesAnalysis(context, provider),
                        const SizedBox(height: 24),
                        _buildActionButtons(context, provider),
                      ] else
                        _buildLoadObjectBButton(context, provider),
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

  Widget _buildLoadObjectBButton(
    BuildContext context,
    ObjectLoaderProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.upload_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Load Object B',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Load a .obj or .stl file to start alignment',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => provider.loadObjectB(),
            icon: const Icon(Icons.upload_rounded),
            label: const Text('Choose File'),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionControls(
    BuildContext context,
    ObjectLoaderProvider provider,
  ) {
    return _buildControlSection(context, 'Position', Icons.open_with_rounded, [
      _buildVector3Slider(
        context,
        'X',
        provider.objectB!.position.x,
        -10.0,
        10.0,
        (value) => provider.updateObjectBPosition(
          vm.Vector3(
            value,
            provider.objectB!.position.y,
            provider.objectB!.position.z,
          ),
        ),
      ),
      _buildVector3Slider(
        context,
        'Y',
        provider.objectB!.position.y,
        -10.0,
        10.0,
        (value) => provider.updateObjectBPosition(
          vm.Vector3(
            provider.objectB!.position.x,
            value,
            provider.objectB!.position.z,
          ),
        ),
      ),
      _buildVector3Slider(
        context,
        'Z',
        provider.objectB!.position.z,
        -10.0,
        10.0,
        (value) => provider.updateObjectBPosition(
          vm.Vector3(
            provider.objectB!.position.x,
            provider.objectB!.position.y,
            value,
          ),
        ),
      ),
    ]);
  }

  Widget _buildRotationControls(
    BuildContext context,
    ObjectLoaderProvider provider,
  ) {
    return _buildControlSection(
      context,
      'Rotation',
      Icons.rotate_right_rounded,
      [
        _buildVector3Slider(
          context,
          'X',
          provider.objectB!.rotation.x,
          0.0,
          360.0,
          (value) => provider.updateObjectBRotation(
            vm.Vector3(
              value,
              provider.objectB!.rotation.y,
              provider.objectB!.rotation.z,
            ),
          ),
        ),
        _buildVector3Slider(
          context,
          'Y',
          provider.objectB!.rotation.y,
          0.0,
          360.0,
          (value) => provider.updateObjectBRotation(
            vm.Vector3(
              provider.objectB!.rotation.x,
              value,
              provider.objectB!.rotation.z,
            ),
          ),
        ),
        _buildVector3Slider(
          context,
          'Z',
          provider.objectB!.rotation.z,
          0.0,
          360.0,
          (value) => provider.updateObjectBRotation(
            vm.Vector3(
              provider.objectB!.rotation.x,
              provider.objectB!.rotation.y,
              value,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScaleControls(
    BuildContext context,
    ObjectLoaderProvider provider,
  ) {
    return _buildControlSection(context, 'Scale', Icons.zoom_in_rounded, [
      _buildVector3Slider(
        context,
        'X',
        provider.objectB!.scale.x,
        0.1,
        5.0,
        (value) => provider.updateObjectBScale(
          vm.Vector3(
            value,
            provider.objectB!.scale.y,
            provider.objectB!.scale.z,
          ),
        ),
      ),
      _buildVector3Slider(
        context,
        'Y',
        provider.objectB!.scale.y,
        0.1,
        5.0,
        (value) => provider.updateObjectBScale(
          vm.Vector3(
            provider.objectB!.scale.x,
            value,
            provider.objectB!.scale.z,
          ),
        ),
      ),
      _buildVector3Slider(
        context,
        'Z',
        provider.objectB!.scale.z,
        0.1,
        5.0,
        (value) => provider.updateObjectBScale(
          vm.Vector3(
            provider.objectB!.scale.x,
            provider.objectB!.scale.y,
            value,
          ),
        ),
      ),
    ]);
  }

  Widget _buildColorControls(
    BuildContext context,
    ObjectLoaderProvider provider,
  ) {
    return _buildControlSection(
      context,
      'Color & Opacity',
      Icons.palette_rounded,
      [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Opacity'),
                  Slider(
                    value: provider.objectB!.opacity,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    onChanged: (value) => provider.updateObjectBOpacity(value),
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
                '${(provider.objectB!.opacity * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProcrustesAnalysis(
    BuildContext context,
    ObjectLoaderProvider provider,
  ) {
    return _buildControlSection(
      context,
      'Procrustes Analysis',
      Icons.analytics_rounded,
      [
        if (provider.isAnalyzing)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: provider.analysisProgress,
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Analyzing alignment...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(provider.analysisProgress * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          FilledButton.icon(
            onPressed: provider.hasObjectA && provider.hasObjectB
                ? () => provider.performProcrustesAnalysis()
                : null,
            icon: const Icon(Icons.compare_arrows_rounded),
            label: const Text('Compare Objects'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
          ),
          const SizedBox(height: 12),
          if (provider.procrustesResult != null)
            _buildProcrustesResults(context, provider.procrustesResult!),
        ],
      ],
    );
  }

  Widget _buildProcrustesResults(
    BuildContext context,
    ProcrustesResult result,
  ) {
    final metrics = ProcrustesMetrics(
      similarityScore: result.similarityScore,
      minimumDistance: result.minimumDistance,
      standardDeviation: result.standardDeviation,
      rootMeanSquareError: result.rootMeanSquareError,
      meanDistance: result.minimumDistance,
      maxDistance: result.minimumDistance + result.standardDeviation,
      numberOfPoints: result.numberOfPoints,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: _getScoreColor(metrics.similarityScore),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Similarity: ${metrics.similarityScore.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getScoreColor(metrics.similarityScore),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            metrics.qualityDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _buildMetricRow(
            context,
            'RMSE',
            metrics.rootMeanSquareError.toStringAsFixed(3),
          ),
          _buildMetricRow(
            context,
            'Min Distance',
            metrics.minimumDistance.toStringAsFixed(3),
          ),
          _buildMetricRow(
            context,
            'Std Dev',
            metrics.standardDeviation.toStringAsFixed(3),
          ),
          _buildMetricRow(context, 'Points', metrics.numberOfPoints.toString()),
        ],
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  Widget _buildResultsCard(BuildContext context) {
    return Consumer<ObjectLoaderProvider>(
      builder: (context, provider, child) {
        if (!provider.showResultsCard ||
            provider.procrustesResult == null ||
            provider.objectA == null ||
            provider.objectB == null) {
          return const SizedBox.shrink();
        }

        return Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: ProcrustesResultsCard(
                result: provider.procrustesResult!,
                objectA: provider.objectA!,
                objectB: provider.objectB!,
                onClose: () => provider.hideResultsCard(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ObjectLoaderProvider provider,
  ) {
    return _buildControlSection(context, 'Actions', Icons.settings_rounded, [
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: provider.canUndo ? () => provider.undo() : null,
              icon: const Icon(Icons.undo_rounded),
              label: const Text('Undo'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: provider.canRedo ? () => provider.redo() : null,
              icon: const Icon(Icons.redo_rounded),
              label: const Text('Redo'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () => provider.resetObjectB(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reset'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => provider.autoAlignObjectB(),
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Auto Align'),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildVector3Slider(
    BuildContext context,
    String axis,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(
            axis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 10).round(),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            value.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.end,
          ),
        ),
      ],
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

  Widget _buildFloatingActionButtons(BuildContext context) {
    return Consumer<ObjectLoaderProvider>(
      builder: (context, provider, child) {
        return Positioned(
          bottom: _isControlPanelVisible ? 520 : 24,
          right: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _fabAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _fabAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FloatingActionButton.extended(
                        onPressed: () => provider.loadObjectA(),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: const Icon(Icons.upload_rounded),
                        label: const Text('Load A'),
                        elevation: 0,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _fabAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _fabAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FloatingActionButton.extended(
                        onPressed: () => provider.loadObjectB(),
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        icon: const Icon(Icons.upload_rounded),
                        label: const Text('Load B'),
                        elevation: 0,
                      ),
                    ),
                  );
                },
              ),
            ],
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
}
