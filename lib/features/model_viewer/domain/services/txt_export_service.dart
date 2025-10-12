import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../entities/procrustes_result.dart';
import '../entities/object_3d.dart';
import 'comparison_logger.dart';

/// Service for exporting comparison results and logs to TXT format
class TxtExportService {
  /// Export comparison results with logs to TXT file
  static Future<String> exportComparisonToTxt({
    required Object3D objectA,
    required Object3D objectB,
    ProcrustesResult? procrustesResult,
    bool includeLogs = true,
  }) async {
    final buffer = StringBuffer();
    final timestamp = DateTime.now();

    // Header
    buffer.writeln('=' * 80);
    buffer.writeln('3D OBJECT COMPARISON REPORT');
    buffer.writeln('=' * 80);
    buffer.writeln('Generated: ${timestamp.toIso8601String()}');
    buffer.writeln('Platform: ${_getPlatformName()}');
    buffer.writeln('=' * 80);
    buffer.writeln();

    // Object Information
    buffer.writeln('OBJECT INFORMATION');
    buffer.writeln('-' * 80);
    buffer.writeln();

    buffer.writeln('Object A:');
    buffer.writeln('  Name: ${objectA.name}');
    buffer.writeln('  File Path: ${objectA.filePath}');
    buffer.writeln('  Format: ${objectA.fileExtension.toUpperCase()}');
    buffer.writeln('  Vertices: ${objectA.vertices?.length ?? 0}');
    buffer.writeln(
      '  Position: (${objectA.position.x.toStringAsFixed(3)}, ${objectA.position.y.toStringAsFixed(3)}, ${objectA.position.z.toStringAsFixed(3)})',
    );
    buffer.writeln(
      '  Rotation: (${objectA.rotation.x.toStringAsFixed(3)}, ${objectA.rotation.y.toStringAsFixed(3)}, ${objectA.rotation.z.toStringAsFixed(3)})',
    );
    buffer.writeln(
      '  Scale: (${objectA.scale.x.toStringAsFixed(3)}, ${objectA.scale.y.toStringAsFixed(3)}, ${objectA.scale.z.toStringAsFixed(3)})',
    );
    buffer.writeln(
      '  Color: RGB(${objectA.color.red.toStringAsFixed(2)}, ${objectA.color.green.toStringAsFixed(2)}, ${objectA.color.blue.toStringAsFixed(2)})',
    );
    buffer.writeln('  Opacity: ${objectA.opacity.toStringAsFixed(2)}');
    buffer.writeln();

    buffer.writeln('Object B:');
    buffer.writeln('  Name: ${objectB.name}');
    buffer.writeln('  File Path: ${objectB.filePath}');
    buffer.writeln('  Format: ${objectB.fileExtension.toUpperCase()}');
    buffer.writeln('  Vertices: ${objectB.vertices?.length ?? 0}');
    buffer.writeln(
      '  Position: (${objectB.position.x.toStringAsFixed(3)}, ${objectB.position.y.toStringAsFixed(3)}, ${objectB.position.z.toStringAsFixed(3)})',
    );
    buffer.writeln(
      '  Rotation: (${objectB.rotation.x.toStringAsFixed(3)}, ${objectB.rotation.y.toStringAsFixed(3)}, ${objectB.rotation.z.toStringAsFixed(3)})',
    );
    buffer.writeln(
      '  Scale: (${objectB.scale.x.toStringAsFixed(3)}, ${objectB.scale.y.toStringAsFixed(3)}, ${objectB.scale.z.toStringAsFixed(3)})',
    );
    buffer.writeln(
      '  Color: RGB(${objectB.color.red.toStringAsFixed(2)}, ${objectB.color.green.toStringAsFixed(2)}, ${objectB.color.blue.toStringAsFixed(2)})',
    );
    buffer.writeln('  Opacity: ${objectB.opacity.toStringAsFixed(2)}');
    buffer.writeln();
    buffer.writeln('=' * 80);
    buffer.writeln();

    // Procrustes Analysis Results
    if (procrustesResult != null) {
      buffer.writeln('PROCRUSTES ANALYSIS RESULTS');
      buffer.writeln('-' * 80);
      buffer.writeln();

      buffer.writeln('PRIMARY SCIENTIFIC METRICS:');
      buffer.writeln(
        '  Minimum Distance:       ${procrustesResult.minimumDistance.toStringAsFixed(8)}',
      );
      buffer.writeln(
        '  Standard Deviation:     ${procrustesResult.standardDeviation.toStringAsFixed(8)}',
      );
      buffer.writeln(
        '  Root Mean Square Error: ${procrustesResult.rootMeanSquareError.toStringAsFixed(8)}',
      );
      buffer.writeln(
        '  Number of Points:       ${procrustesResult.numberOfPoints}',
      );
      buffer.writeln();

      buffer.writeln('TRANSFORMATION PARAMETERS:');
      buffer.writeln('  Translation:');
      buffer.writeln(
        '    X: ${procrustesResult.translation.x.toStringAsFixed(8)}',
      );
      buffer.writeln(
        '    Y: ${procrustesResult.translation.y.toStringAsFixed(8)}',
      );
      buffer.writeln(
        '    Z: ${procrustesResult.translation.z.toStringAsFixed(8)}',
      );
      buffer.writeln();

      buffer.writeln('  Rotation Matrix:');
      buffer.writeln(
        '    [ ${procrustesResult.rotation.entry(0, 0).toStringAsFixed(6)}  ${procrustesResult.rotation.entry(0, 1).toStringAsFixed(6)}  ${procrustesResult.rotation.entry(0, 2).toStringAsFixed(6)} ]',
      );
      buffer.writeln(
        '    [ ${procrustesResult.rotation.entry(1, 0).toStringAsFixed(6)}  ${procrustesResult.rotation.entry(1, 1).toStringAsFixed(6)}  ${procrustesResult.rotation.entry(1, 2).toStringAsFixed(6)} ]',
      );
      buffer.writeln(
        '    [ ${procrustesResult.rotation.entry(2, 0).toStringAsFixed(6)}  ${procrustesResult.rotation.entry(2, 1).toStringAsFixed(6)}  ${procrustesResult.rotation.entry(2, 2).toStringAsFixed(6)} ]',
      );
      buffer.writeln();

      buffer.writeln(
        '  Scale Factor: ${procrustesResult.scale.toStringAsFixed(8)}',
      );
      buffer.writeln();

      buffer.writeln('LEGACY METRICS:');
      buffer.writeln(
        '  Similarity Score: ${procrustesResult.similarityScore.toStringAsFixed(2)}%',
      );
      buffer.writeln();

      buffer.writeln(
        'Analysis Computed: ${procrustesResult.computedAt.toIso8601String()}',
      );
      buffer.writeln();
      buffer.writeln('=' * 80);
      buffer.writeln();
    } else {
      buffer.writeln('PROCRUSTES ANALYSIS RESULTS');
      buffer.writeln('-' * 80);
      buffer.writeln();
      buffer.writeln('No Procrustes analysis has been performed yet.');
      buffer.writeln(
        'Run the Procrustes Analysis to get scientific comparison metrics.',
      );
      buffer.writeln();
      buffer.writeln('=' * 80);
      buffer.writeln();
    }

    // Logs
    if (includeLogs) {
      final logger = ComparisonLogger();
      if (logger.hasLogs) {
        buffer.writeln('PROCESSING LOGS');
        buffer.writeln('-' * 80);
        buffer.writeln();
        buffer.writeln(logger.getAllLogs());
        buffer.writeln();
        buffer.writeln('=' * 80);
        buffer.writeln();
      }
    }

    // Footer
    buffer.writeln('END OF REPORT');
    buffer.writeln('Total log entries: ${ComparisonLogger().logCount}');
    buffer.writeln('=' * 80);

    return buffer.toString();
  }

  /// Save and share TXT export
  static Future<void> saveAndShareTxt({
    required Object3D objectA,
    required Object3D objectB,
    ProcrustesResult? procrustesResult,
    bool includeLogs = true,
  }) async {
    try {
      final txtContent = await exportComparisonToTxt(
        objectA: objectA,
        objectB: objectB,
        procrustesResult: procrustesResult,
        includeLogs: includeLogs,
      );

      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')[0];
      final filename = 'comparison_report_$timestamp.txt';

      if (kIsWeb) {
        // For web, use Share API
        await Share.share(
          txtContent,
          subject: 'Comparison Report: ${objectA.name} vs ${objectB.name}',
        );
      } else {
        // For native platforms, save to file and share
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsString(txtContent);

        await Share.shareXFiles([
          XFile(file.path),
        ], subject: 'Comparison Report: ${objectA.name} vs ${objectB.name}');
      }
    } catch (e) {
      throw Exception('Failed to export comparison: $e');
    }
  }

  static String _getPlatformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}
