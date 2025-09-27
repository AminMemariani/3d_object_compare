import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../viewmodels/object_view_model.dart';
import '../viewmodels/ui_view_model.dart';
import '../../domain/entities/object_3d.dart';
import '../../domain/entities/procrustes_result.dart';
import '../widgets/procrustes_results_card.dart';

/// Superimposed Viewer Page using MVVM architecture with new providers
class SuperimposedViewerMVVMPage extends StatefulWidget {
  const SuperimposedViewerMVVMPage({super.key});

  @override
  State<SuperimposedViewerMVVMPage> createState() =>
      _SuperimposedViewerMVVMPageState();
}

class _SuperimposedViewerMVVMPageState extends State<SuperimposedViewerMVVMPage>
    with TickerProviderStateMixin {
  late AnimationController _panelController;
  late Animation<double> _panelAnimation;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  bool _isControlPanelVisible = true; // Start with panel visible

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _panelAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _panelController, curve: Curves.easeInOut),
    );

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    _panelController.forward(); // Show panel initially
    _fabController.forward();
  }

  @override
  void dispose() {
    _panelController.dispose();
    _fabController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Superimposed Viewer (MVVM)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: Consumer2<ObjectViewModel, UIViewModel>(
        builder: (context, objectVM, uiVM, child) {
          if (objectVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (objectVM.error != null) {
            return _buildErrorView(context, objectVM.error!, objectVM);
          }

          return Stack(
            children: [
              _build3DViewport(context, objectVM, uiVM),
              _buildTopControls(context, objectVM, uiVM),
              _buildControlPanel(context, objectVM, uiVM),
              _buildFloatingActionButtons(context, objectVM),
              _buildResultsCard(context, objectVM),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    String error,
    ObjectViewModel objectVM,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => objectVM.clearError(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _build3DViewport(
    BuildContext context,
    ObjectViewModel objectVM,
    UIViewModel uiVM,
  ) {
    return Container(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      child: Center(
        child: !objectVM.hasObjectA && !objectVM.hasObjectB
            ? _buildNoObjectsView(context, objectVM)
            : _buildSuperimposedView(context, objectVM, uiVM),
      ),
    );
  }

  Widget _buildNoObjectsView(BuildContext context, ObjectViewModel objectVM) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.layers_rounded, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        Text(
          'No 3D Objects Loaded',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Load 3D objects for superimposed view',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: () => objectVM.loadObjectA(),
              icon: const Icon(Icons.upload_rounded),
              label: const Text('Load Object A'),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: () => objectVM.loadObjectB(),
              icon: const Icon(Icons.upload_rounded),
              label: const Text('Load Object B'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuperimposedView(
    BuildContext context,
    ObjectViewModel objectVM,
    UIViewModel uiVM,
  ) {
    return Stack(
      children: [
        // Object A (Base object)
        if (uiVM.showObjectA && objectVM.objectA != null)
          _buildObjectView(context, objectVM.objectA!, 'Object A'),

        // Object B (Overlay object)
        if (uiVM.showObjectB && objectVM.objectB != null)
          _buildObjectView(context, objectVM.objectB!, 'Object B'),

        // Alignment indicator
        if (objectVM.hasObjectA && objectVM.hasObjectB)
          _buildAlignmentIndicator(context, objectVM),
      ],
    );
  }

  Widget _buildObjectView(BuildContext context, Object3D object, String label) {
    return Positioned.fill(
      child: Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Color.fromRGBO(
              (object.color.red * 255).round(),
              (object.color.green * 255).round(),
              (object.color.blue * 255).round(),
              object.opacity,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: object.color.red > 0.5 ? Colors.red : Colors.blue,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.view_in_ar_rounded, size: 48, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                object.name,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlignmentIndicator(
    BuildContext context,
    ObjectViewModel objectVM,
  ) {
    final alignmentScore = objectVM.getAlignmentScore();
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
            Icon(Icons.star_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Alignment: ${alignmentScore.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls(
    BuildContext context,
    ObjectViewModel objectVM,
    UIViewModel uiVM,
  ) {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Superimposed 3D Viewer',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    uiVM.showObjectA ? Icons.visibility : Icons.visibility_off,
                    color: Colors.blue,
                  ),
                  onPressed: () => uiVM.toggleObjectAVisibility(),
                  tooltip: 'Toggle Object A',
                ),
                IconButton(
                  icon: Icon(
                    uiVM.showObjectB ? Icons.visibility : Icons.visibility_off,
                    color: Colors.pink,
                  ),
                  onPressed: () => uiVM.toggleObjectBVisibility(),
                  tooltip: 'Toggle Object B',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel(
    BuildContext context,
    ObjectViewModel objectVM,
    UIViewModel uiVM,
  ) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _panelController,
                curve: Curves.easeOutCubic,
              ),
            ),
        child: FadeTransition(
          opacity: _panelAnimation,
          child: _isControlPanelVisible
              ? _buildControlPanelContent(context, objectVM, uiVM)
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildControlPanelContent(
    BuildContext context,
    ObjectViewModel objectVM,
    UIViewModel uiVM,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPanelHandle(),
            const SizedBox(height: 16),
            Text(
              'Object B Controls',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            if (objectVM.objectB == null)
              _buildLoadObjectBButton(context, objectVM)
            else
              Column(
                children: [
                  _buildVisibilityControls(context, objectVM, uiVM),
                  const SizedBox(height: 16),
                  _buildTransformationControls(context, objectVM),
                  const SizedBox(height: 16),
                  _buildProcrustesAnalysis(context, objectVM),
                  const SizedBox(height: 24),
                  _buildActionButtons(context, objectVM),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildLoadObjectBButton(
    BuildContext context,
    ObjectViewModel objectVM,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.upload_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Load Object B',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Load a 3D object to enable controls',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => objectVM.loadObjectB(),
            icon: const Icon(Icons.upload_rounded),
            label: const Text('Load Object B'),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityControls(
    BuildContext context,
    ObjectViewModel objectVM,
    UIViewModel uiVM,
  ) {
    return _buildControlSection(
      context,
      'Visibility',
      Icons.visibility_rounded,
      [
        SwitchListTile(
          title: const Text('Object A Visible'),
          value: uiVM.showObjectA,
          onChanged: (_) => uiVM.toggleObjectAVisibility(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        SwitchListTile(
          title: const Text('Object B Visible'),
          value: uiVM.showObjectB,
          onChanged: (_) => uiVM.toggleObjectBVisibility(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildTransformationControls(
    BuildContext context,
    ObjectViewModel objectVM,
  ) {
    return Column(
      children: [
        _buildPositionControls(context, objectVM),
        const SizedBox(height: 16),
        _buildRotationControls(context, objectVM),
        const SizedBox(height: 16),
        _buildScaleControls(context, objectVM),
        const SizedBox(height: 16),
        _buildColorControls(context, objectVM),
      ],
    );
  }

  Widget _buildPositionControls(
    BuildContext context,
    ObjectViewModel objectVM,
  ) {
    return _buildControlSection(context, 'Position', Icons.open_with_rounded, [
      _buildVector3Slider(
        context,
        'X',
        objectVM.objectB!.position.x,
        -10.0,
        10.0,
        (value) => objectVM.updateObjectBPosition(
          vm.Vector3(
            value,
            objectVM.objectB!.position.y,
            objectVM.objectB!.position.z,
          ),
        ),
      ),
      _buildVector3Slider(
        context,
        'Y',
        objectVM.objectB!.position.y,
        -10.0,
        10.0,
        (value) => objectVM.updateObjectBPosition(
          vm.Vector3(
            objectVM.objectB!.position.x,
            value,
            objectVM.objectB!.position.z,
          ),
        ),
      ),
      _buildVector3Slider(
        context,
        'Z',
        objectVM.objectB!.position.z,
        -10.0,
        10.0,
        (value) => objectVM.updateObjectBPosition(
          vm.Vector3(
            objectVM.objectB!.position.x,
            objectVM.objectB!.position.y,
            value,
          ),
        ),
      ),
    ]);
  }

  Widget _buildRotationControls(
    BuildContext context,
    ObjectViewModel objectVM,
  ) {
    return _buildControlSection(
      context,
      'Rotation',
      Icons.rotate_right_rounded,
      [
        _buildVector3Slider(
          context,
          'X',
          objectVM.objectB!.rotation.x,
          0.0,
          360.0,
          (value) => objectVM.updateObjectBRotation(
            vm.Vector3(
              value,
              objectVM.objectB!.rotation.y,
              objectVM.objectB!.rotation.z,
            ),
          ),
        ),
        _buildVector3Slider(
          context,
          'Y',
          objectVM.objectB!.rotation.y,
          0.0,
          360.0,
          (value) => objectVM.updateObjectBRotation(
            vm.Vector3(
              objectVM.objectB!.rotation.x,
              value,
              objectVM.objectB!.rotation.z,
            ),
          ),
        ),
        _buildVector3Slider(
          context,
          'Z',
          objectVM.objectB!.rotation.z,
          0.0,
          360.0,
          (value) => objectVM.updateObjectBRotation(
            vm.Vector3(
              objectVM.objectB!.rotation.x,
              objectVM.objectB!.rotation.y,
              value,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScaleControls(BuildContext context, ObjectViewModel objectVM) {
    return _buildControlSection(context, 'Scale', Icons.zoom_in_rounded, [
      _buildVector3Slider(
        context,
        'X',
        objectVM.objectB!.scale.x,
        0.1,
        5.0,
        (value) => objectVM.updateObjectBScale(
          vm.Vector3(
            value,
            objectVM.objectB!.scale.y,
            objectVM.objectB!.scale.z,
          ),
        ),
      ),
      _buildVector3Slider(
        context,
        'Y',
        objectVM.objectB!.scale.y,
        0.1,
        5.0,
        (value) => objectVM.updateObjectBScale(
          vm.Vector3(
            objectVM.objectB!.scale.x,
            value,
            objectVM.objectB!.scale.z,
          ),
        ),
      ),
      _buildVector3Slider(
        context,
        'Z',
        objectVM.objectB!.scale.z,
        0.1,
        5.0,
        (value) => objectVM.updateObjectBScale(
          vm.Vector3(
            objectVM.objectB!.scale.x,
            objectVM.objectB!.scale.y,
            value,
          ),
        ),
      ),
    ]);
  }

  Widget _buildColorControls(BuildContext context, ObjectViewModel objectVM) {
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
                    value: objectVM.objectB!.opacity,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    onChanged: (value) => objectVM.updateObjectBOpacity(value),
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
                '${(objectVM.objectB!.opacity * 100).toStringAsFixed(0)}%',
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
    ObjectViewModel objectVM,
  ) {
    return _buildControlSection(
      context,
      'Procrustes Analysis',
      Icons.analytics_rounded,
      [
        if (objectVM.isAnalyzing)
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
                      value: objectVM.analysisProgress,
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
                    '${(objectVM.analysisProgress * 100).toStringAsFixed(0)}%',
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
            onPressed: objectVM.hasObjectA && objectVM.hasObjectB
                ? () => objectVM.performProcrustesAnalysis()
                : null,
            icon: const Icon(Icons.compare_arrows_rounded),
            label: const Text('Compare Objects'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
          ),
          const SizedBox(height: 12),
          if (objectVM.procrustesResult != null)
            _buildProcrustesResults(context, objectVM.procrustesResult!),
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

  Widget _buildActionButtons(BuildContext context, ObjectViewModel objectVM) {
    return _buildControlSection(context, 'Actions', Icons.settings_rounded, [
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: objectVM.canUndo ? () => objectVM.undo() : null,
              icon: const Icon(Icons.undo_rounded),
              label: const Text('Undo'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: objectVM.canRedo ? () => objectVM.redo() : null,
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
              onPressed: () => objectVM.resetObjectB(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reset'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => objectVM.autoAlignObjectB(),
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Auto Align'),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildFloatingActionButtons(
    BuildContext context,
    ObjectViewModel objectVM,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ScaleTransition(
          scale: _fabAnimation,
          child: FloatingActionButton.extended(
            heroTag: 'loadAButton',
            onPressed: () => objectVM.loadObjectA(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.upload_rounded),
            label: const Text('Load A'),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 12),
        ScaleTransition(
          scale: _fabAnimation,
          child: FloatingActionButton.extended(
            heroTag: 'loadBButton',
            onPressed: () => objectVM.loadObjectB(),
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.upload_rounded),
            label: const Text('Load B'),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 12),
        ScaleTransition(
          scale: _fabAnimation,
          child: FloatingActionButton(
            heroTag: 'togglePanelButton',
            onPressed: _toggleControlPanel,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            child: Icon(
              _isControlPanelVisible ? Icons.close_rounded : Icons.tune_rounded,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsCard(BuildContext context, ObjectViewModel objectVM) {
    if (!objectVM.showResultsCard ||
        objectVM.procrustesResult == null ||
        objectVM.objectA == null ||
        objectVM.objectB == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: ProcrustesResultsCard(
            result: objectVM.procrustesResult!,
            objectA: objectVM.objectA!,
            objectB: objectVM.objectB!,
            onClose: () => objectVM.hideResultsCard(),
          ),
        ),
      ),
    );
  }

  // Helper methods
  Widget _buildControlSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
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
      ),
    );
  }

  Widget _buildVector3Slider(
    BuildContext context,
    String axis,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            axis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 10).round(),
            onChanged: onChanged,
          ),
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
}
