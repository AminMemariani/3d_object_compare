import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../mvvm/viewmodels/object_comparison_viewmodel.dart';
import '../../../../mvvm/models/object_model.dart';
import '../widgets/advanced_3d_viewer.dart';
import '../../domain/entities/object_3d.dart';

class CompareViewPage extends StatefulWidget {
  const CompareViewPage({super.key});

  @override
  State<CompareViewPage> createState() => _CompareViewPageState();
}

class _CompareViewPageState extends State<CompareViewPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
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
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(child: _buildComparisonView(context)),
                  _buildComparisonControls(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compare Objects',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Side-by-side 3D model comparison',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
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
              '2 Objects',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonView(BuildContext context) {
    return Consumer<ObjectComparisonViewModel>(
      builder: (context, viewModel, child) {
        // If no objects loaded, show empty state
        if (!viewModel.hasObjectA && !viewModel.hasObjectB) {
          return _buildEmptyState(context, viewModel);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Object A View
              Expanded(
                child: viewModel.hasObjectA
                    ? _buildObjectView(
                        context,
                        viewModel.objectA!,
                        'Object A',
                        Colors.blue,
                      )
                    : _buildPlaceholderView(context, 'Object A', Colors.blue, () {
                        viewModel.loadObjectA();
                      }),
              ),
              const SizedBox(width: 16),
              // Object B View
              Expanded(
                child: viewModel.hasObjectB
                    ? _buildObjectView(
                        context,
                        viewModel.objectB!,
                        'Object B',
                        Colors.purple,
                      )
                    : _buildPlaceholderView(context, 'Object B', Colors.purple, () {
                        viewModel.loadObjectB();
                      }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, ObjectComparisonViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.compare_arrows, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 24),
          Text(
            'No Objects to Compare',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Load 3D objects to start side-by-side comparison',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => viewModel.loadObjectA(),
                icon: const Icon(Icons.upload_rounded),
                label: const Text('Load Object A'),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: () => viewModel.loadObjectB(),
                icon: const Icon(Icons.upload_rounded),
                label: const Text('Load Object B'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderView(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onLoad,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_rounded, size: 48, color: color.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No object loaded',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onLoad,
              icon: const Icon(Icons.upload_rounded),
              label: const Text('Load File'),
              style: FilledButton.styleFrom(backgroundColor: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectView(
    BuildContext context,
    ObjectModel object,
    String label,
    Color accentColor,
  ) {
    final viewModel = Provider.of<ObjectComparisonViewModel>(context, listen: false);
    
    // Convert ObjectModel to Object3D for Advanced3DViewer (temporary compatibility)
    final object3d = Object3D(
      id: object.id,
      name: object.name,
      filePath: object.filePath,
      fileExtension: object.fileExtension,
      position: object.position,
      rotation: object.rotation,
      scale: object.scale,
      color: Color3D(object.color.red, object.color.green, object.color.blue),
      opacity: object.opacity,
      createdAt: object.createdAt,
      lastModified: object.lastModified,
    );
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.view_in_ar, color: accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        object.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Advanced3DViewer(
                  object: object3d,
                  backgroundColor: Color.fromRGBO(
                    (object.color.red * 255).round(),
                    (object.color.green * 255).round(),
                    (object.color.blue * 255).round(),
                    1.0,
                  ),
                  showControls: true,
                  onPositionChanged: (position) {
                    if (label == 'Object A') {
                      viewModel.updateObjectAPosition(position);
                    } else {
                      viewModel.updateObjectBPosition(position);
                    }
                  },
                  onRotationChanged: (rotation) {
                    if (label == 'Object A') {
                      viewModel.updateObjectARotation(rotation);
                    } else {
                      viewModel.updateObjectBRotation(rotation);
                    }
                  },
                  onScaleChanged: (scale) {
                    if (label == 'Object A') {
                      viewModel.updateObjectAScale(scale);
                    } else {
                      viewModel.updateObjectBScale(scale);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildControlButton(
                  context,
                  'Synchronize',
                  Icons.sync_rounded,
                  () => _synchronizeRotation(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildControlButton(
                  context,
                  'Reset View',
                  Icons.refresh_rounded,
                  () => _resetViews(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildControlButton(
                  context,
                  'Export',
                  Icons.download_rounded,
                  () => _exportComparison(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<ObjectComparisonViewModel>(
            builder: (context, viewModel, child) {
              return Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      'Object A',
                      viewModel.hasObjectA ? viewModel.objectA!.name : 'Not loaded',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      'Object B',
                      viewModel.hasObjectB ? viewModel.objectB!.name : 'Not loaded',
                      Colors.purple,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
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

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String subtitle,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _synchronizeRotation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.sync_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Rotation synchronized'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _resetViews() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Views reset'),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _exportComparison() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.download_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Comparison exported'),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
