import 'package:flutter/material.dart';
import '../../domain/entities/procrustes_result.dart';
import '../../domain/entities/object_3d.dart';
import '../../domain/services/export_service.dart';

/// A comprehensive results card for displaying Procrustes analysis results
class ProcrustesResultsCard extends StatefulWidget {
  final ProcrustesResult result;
  final Object3D objectA;
  final Object3D objectB;
  final VoidCallback? onClose;

  const ProcrustesResultsCard({
    super.key,
    required this.result,
    required this.objectA,
    required this.objectB,
    this.onClose,
  });

  @override
  State<ProcrustesResultsCard> createState() => _ProcrustesResultsCardState();
}

class _ProcrustesResultsCardState extends State<ProcrustesResultsCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

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
    return AnimatedBuilder(
      animation: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              _buildContent(context),
              _buildActions(context),
            ],
          ),
        ),
      ),
      builder: (context, child) {
        return Opacity(opacity: _fadeAnimation.value, child: child);
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.analytics_rounded,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Procrustes Analysis Results',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'Generated ${_formatTimestamp(widget.result.computedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: Icon(
              Icons.close_rounded,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSimilaritySection(context),
          const SizedBox(height: 24),
          _buildMetricsSection(context),
          const SizedBox(height: 24),
          _buildTransformationSection(context),
        ],
      ),
    );
  }

  Widget _buildSimilaritySection(BuildContext context) {
    final metrics = ProcrustesMetrics(
      similarityScore: widget.result.similarityScore,
      minimumDistance: widget.result.minimumDistance,
      standardDeviation: widget.result.standardDeviation,
      rootMeanSquareError: widget.result.rootMeanSquareError,
      meanDistance: widget.result.minimumDistance,
      maxDistance:
          widget.result.minimumDistance + widget.result.standardDeviation,
      numberOfPoints: widget.result.numberOfPoints,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Object Similarity',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSimilarityMetric(
                  context,
                  'Min Distance',
                  widget.result.minimumDistance,
                  Icons.straighten_rounded,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSimilarityMetric(
                  context,
                  'Std Deviation',
                  widget.result.standardDeviation,
                  Icons.show_chart_rounded,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getQualityIcon(widget.result.rootMeanSquareError),
                  color: _getScoreColor(widget.result.similarityScore),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    metrics.alignmentStatus,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarityMetric(
    BuildContext context,
    String label,
    double value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value.toStringAsFixed(6),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  IconData _getQualityIcon(double rmse) {
    if (rmse <= 0.1) return Icons.check_circle_rounded;
    if (rmse <= 0.5) return Icons.verified_rounded;
    if (rmse <= 1.0) return Icons.info_rounded;
    return Icons.warning_rounded;
  }

  Widget _buildMetricsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analysis Metrics',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            context,
            'Root Mean Square Error',
            widget.result.rootMeanSquareError.toStringAsFixed(6),
          ),
          _buildMetricRow(
            context,
            'Minimum Distance',
            widget.result.minimumDistance.toStringAsFixed(6),
          ),
          _buildMetricRow(
            context,
            'Standard Deviation',
            widget.result.standardDeviation.toStringAsFixed(6),
          ),
          _buildMetricRow(
            context,
            'Number of Points',
            widget.result.numberOfPoints.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransformationSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transformation Parameters',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            context,
            'Translation X',
            widget.result.translation.x.toStringAsFixed(6),
          ),
          _buildMetricRow(
            context,
            'Translation Y',
            widget.result.translation.y.toStringAsFixed(6),
          ),
          _buildMetricRow(
            context,
            'Translation Z',
            widget.result.translation.z.toStringAsFixed(6),
          ),
          _buildMetricRow(
            context,
            'Scale Factor',
            widget.result.scale.toStringAsFixed(6),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _exportAsJson(context),
              icon: const Icon(Icons.code_rounded),
              label: const Text('Export JSON'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _exportAsCsv(context),
              icon: const Icon(Icons.table_chart_rounded),
              label: const Text('Export CSV'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Future<void> _exportAsJson(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final jsonContent = await ExportService.exportAsJson(
        widget.result,
        widget.objectA,
        widget.objectB,
      );

      final timestamp = DateTime.now().toIso8601String().split('T')[0];
      final filename = 'procrustes_analysis_$timestamp.json';
      final filePath = await ExportService.saveToFile(jsonContent, filename);

      await ExportService.shareFile(
        filePath,
        'Procrustes Analysis Results (JSON)',
      );

      if (mounted) {
        _showSuccessMessage(scaffoldMessenger, 'JSON exported successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(scaffoldMessenger, 'Failed to export JSON: $e');
      }
    }
  }

  Future<void> _exportAsCsv(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final csvContent = await ExportService.exportAsCsv(
        widget.result,
        widget.objectA,
        widget.objectB,
      );

      final timestamp = DateTime.now().toIso8601String().split('T')[0];
      final filename = 'procrustes_analysis_$timestamp.csv';
      final filePath = await ExportService.saveToFile(csvContent, filename);

      await ExportService.shareFile(
        filePath,
        'Procrustes Analysis Results (CSV)',
      );

      if (mounted) {
        _showSuccessMessage(scaffoldMessenger, 'CSV exported successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(scaffoldMessenger, 'Failed to export CSV: $e');
      }
    }
  }

  void _showSuccessMessage(
    ScaffoldMessengerState scaffoldMessenger,
    String message,
  ) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorMessage(
    ScaffoldMessengerState scaffoldMessenger,
    String message,
  ) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
