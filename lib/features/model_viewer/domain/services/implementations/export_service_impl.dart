import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../entities/object_3d.dart';
import '../../entities/procrustes_result.dart';
import '../interfaces/procrustes_service_interface.dart';

/// Implementation of ExportServiceInterface
class ExportServiceImpl implements ExportServiceInterface {
  @override
  Future<String> exportAsJson(
    ProcrustesResult result,
    Object3D objectA,
    Object3D objectB,
  ) async {
    final exportData = {
      'analysis': {
        'timestamp': result.computedAt.toIso8601String(),
        'similarityScore': result.similarityScore,
        'minimumDistance': result.minimumDistance,
        'standardDeviation': result.standardDeviation,
        'rootMeanSquareError': result.rootMeanSquareError,
        'numberOfPoints': result.numberOfPoints,
      },
      'transformation': {
        'translation': {
          'x': result.translation.x,
          'y': result.translation.y,
          'z': result.translation.z,
        },
        'rotation': {
          'm00': result.rotation.entry(0, 0),
          'm01': result.rotation.entry(0, 1),
          'm02': result.rotation.entry(0, 2),
          'm10': result.rotation.entry(1, 0),
          'm11': result.rotation.entry(1, 1),
          'm12': result.rotation.entry(1, 2),
          'm20': result.rotation.entry(2, 0),
          'm21': result.rotation.entry(2, 1),
          'm22': result.rotation.entry(2, 2),
        },
        'scale': result.scale,
      },
      'objects': {
        'objectA': _objectToJson(objectA),
        'objectB': _objectToJson(objectB),
      },
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  @override
  Future<String> exportAsCsv(
    ProcrustesResult result,
    Object3D objectA,
    Object3D objectB,
  ) async {
    final csvBuffer = StringBuffer();

    // Header
    csvBuffer.writeln('Procrustes Analysis Results');
    csvBuffer.writeln('Generated: ${result.computedAt.toIso8601String()}');
    csvBuffer.writeln();

    // Analysis Results
    csvBuffer.writeln('Analysis Results');
    csvBuffer.writeln('Metric,Value');
    csvBuffer.writeln(
      'Similarity Score,${result.similarityScore.toStringAsFixed(2)}%',
    );
    csvBuffer.writeln(
      'Minimum Distance,${result.minimumDistance.toStringAsFixed(6)}',
    );
    csvBuffer.writeln(
      'Standard Deviation,${result.standardDeviation.toStringAsFixed(6)}',
    );
    csvBuffer.writeln(
      'Root Mean Square Error,${result.rootMeanSquareError.toStringAsFixed(6)}',
    );
    csvBuffer.writeln('Number of Points,${result.numberOfPoints}');
    csvBuffer.writeln();

    // Transformation Parameters
    csvBuffer.writeln('Transformation Parameters');
    csvBuffer.writeln('Parameter,Value');
    csvBuffer.writeln(
      'Translation X,${result.translation.x.toStringAsFixed(6)}',
    );
    csvBuffer.writeln(
      'Translation Y,${result.translation.y.toStringAsFixed(6)}',
    );
    csvBuffer.writeln(
      'Translation Z,${result.translation.z.toStringAsFixed(6)}',
    );
    csvBuffer.writeln('Scale,${result.scale.toStringAsFixed(6)}');
    csvBuffer.writeln();

    // Object Information
    csvBuffer.writeln('Object Information');
    csvBuffer.writeln('Property,Object A,Object B');
    csvBuffer.writeln('Name,"${objectA.name}","${objectB.name}"');
    csvBuffer.writeln('File Path,"${objectA.filePath}","${objectB.filePath}"');
    csvBuffer.writeln(
      'Position X,${objectA.position.x.toStringAsFixed(6)},${objectB.position.x.toStringAsFixed(6)}',
    );
    csvBuffer.writeln(
      'Position Y,${objectA.position.y.toStringAsFixed(6)},${objectB.position.y.toStringAsFixed(6)}',
    );
    csvBuffer.writeln(
      'Position Z,${objectA.position.z.toStringAsFixed(6)},${objectB.position.z.toStringAsFixed(6)}',
    );
    csvBuffer.writeln(
      'Scale X,${objectA.scale.x.toStringAsFixed(6)},${objectB.scale.x.toStringAsFixed(6)}',
    );
    csvBuffer.writeln(
      'Scale Y,${objectA.scale.y.toStringAsFixed(6)},${objectB.scale.y.toStringAsFixed(6)}',
    );
    csvBuffer.writeln(
      'Scale Z,${objectA.scale.z.toStringAsFixed(6)},${objectB.scale.z.toStringAsFixed(6)}',
    );
    csvBuffer.writeln(
      'Opacity,${objectA.opacity.toStringAsFixed(3)},${objectB.opacity.toStringAsFixed(3)}',
    );

    return csvBuffer.toString();
  }

  @override
  Future<String> saveToFile(String content, String filename) async {
    if (kIsWeb) {
      // Web implementation - for now, just return the filename
      // In a real implementation, you would use dart:html for browser download
      return filename;
    } else {
      // Native implementation - for now, just return the filename
      // In a real implementation, you would use dart:io and path_provider
      return filename;
    }
  }

  @override
  Future<void> shareFile(String filePath, String subject) async {
    if (kIsWeb) {
      // Web implementation - for now, just do nothing
      // In a real implementation, you would use dart:html for Web Share API
      return;
    } else {
      // Native implementation - for now, just do nothing
      // In a real implementation, you would use share_plus
      return;
    }
  }

  /// Converts Object3D to JSON
  Map<String, dynamic> _objectToJson(Object3D object) {
    return {
      'id': object.id,
      'name': object.name,
      'filePath': object.filePath,
      'fileExtension': object.fileExtension,
      'position': {
        'x': object.position.x,
        'y': object.position.y,
        'z': object.position.z,
      },
      'rotation': {
        'x': object.rotation.x,
        'y': object.rotation.y,
        'z': object.rotation.z,
      },
      'scale': {'x': object.scale.x, 'y': object.scale.y, 'z': object.scale.z},
      'color': {
        'red': object.color.red,
        'green': object.color.green,
        'blue': object.color.blue,
      },
      'opacity': object.opacity,
      'createdAt': object.createdAt.toIso8601String(),
      'lastModified': object.lastModified.toIso8601String(),
    };
  }
}
