import 'dart:typed_data';
import 'package:vector_math/vector_math_64.dart';

/// Abstract interface for 3D model parsers
abstract class ModelParserInterface {
  /// Parse a 3D model file and extract vertex data
  /// 
  /// [filePath] - Path to the file (native platforms)
  /// [fileBytes] - Raw file bytes (web platform or when available)
  /// [fileName] - Original file name for context
  /// 
  /// Returns list of 3D vertices
  Future<List<Vector3>> parseFile({
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  });

  /// Get the file extensions supported by this parser
  List<String> get supportedExtensions;

  /// Sample vertices evenly to reduce computation load
  static List<Vector3> sampleVertices(List<Vector3> vertices, int targetCount) {
    if (vertices.isEmpty || vertices.length <= targetCount) {
      return List.from(vertices);
    }

    final sampled = <Vector3>[];
    final step = vertices.length / targetCount;

    for (int i = 0; i < targetCount; i++) {
      final index = (i * step).floor();
      if (index < vertices.length) {
        sampled.add(vertices[index]);
      }
    }

    return sampled;
  }

  /// Get recommended sample size based on vertex count
  static int getRecommendedSampleSize(int vertexCount) {
    if (vertexCount <= 100) return vertexCount;
    if (vertexCount <= 1000) return 500;
    if (vertexCount <= 10000) return 1000;
    return 2000; // Max sample size for performance
  }
}
