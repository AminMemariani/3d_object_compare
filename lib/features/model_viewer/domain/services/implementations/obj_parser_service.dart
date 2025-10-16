import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:vector_math/vector_math_64.dart';
import 'model_parser_interface.dart';

/// Service for parsing OBJ file format and extracting vertex data
class ObjParserService implements ModelParserInterface {
  @override
  List<String> get supportedExtensions => ['obj'];

  @override
  Future<List<Vector3>> parseFile({
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    if (fileBytes != null) {
      return _parseObjFromBytes(fileBytes, fileName);
    } else if (!kIsWeb && filePath != null) {
      return parseObjFile(filePath);
    } else {
      throw Exception('No file data provided for OBJ parsing');
    }
  }

  /// Parse OBJ from bytes data
  Future<List<Vector3>> _parseObjFromBytes(
    Uint8List fileBytes,
    String? fileName,
  ) async {
    try {
      final content = utf8.decode(fileBytes);
      final vertices = <Vector3>[];
      final lines = content.split('\n');

      for (final line in lines) {
        final trimmed = line.trim();
        // Parse vertex lines (starts with 'v ')
        if (trimmed.startsWith('v ')) {
          final parts = trimmed.split(RegExp(r'\s+'));
          if (parts.length >= 4) {
            try {
              final x = double.parse(parts[1]);
              final y = double.parse(parts[2]);
              final z = double.parse(parts[3]);
              vertices.add(Vector3(x, y, z));
            } catch (e) {
              // Skip malformed lines
              continue;
            }
          }
        }
      }

      if (vertices.isEmpty) {
        debugPrint(
          '⚠️ No vertices found in OBJ file: ${fileName ?? "unknown"}',
        );
        return [];
      }

      debugPrint('✅ Parsed OBJ file: ${vertices.length} vertices');
      return vertices;
    } catch (e) {
      debugPrint('❌ Error parsing OBJ from bytes: $e');
      return [];
    }
  }

  /// Parse OBJ file and extract vertices
  static Future<List<Vector3>> parseObjFile(String filePath) async {
    try {
      if (kIsWeb) {
        // On web, we can't read files directly from file system
        // Return empty list - will use placeholder vertices
        return [];
      }

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('OBJ file not found: $filePath');
      }

      final vertices = <Vector3>[];
      final lines = await file.readAsLines();

      for (final line in lines) {
        final trimmed = line.trim();
        // Parse vertex lines (starts with 'v ')
        if (trimmed.startsWith('v ')) {
          final parts = trimmed.split(RegExp(r'\s+'));
          if (parts.length >= 4) {
            try {
              final x = double.parse(parts[1]);
              final y = double.parse(parts[2]);
              final z = double.parse(parts[3]);
              vertices.add(Vector3(x, y, z));
            } catch (e) {
              // Skip malformed lines
              continue;
            }
          }
        }
      }

      if (vertices.isEmpty) {
        debugPrint('⚠️ No vertices found in OBJ file: $filePath');
        return [];
      }

      debugPrint('✅ Parsed OBJ file: ${vertices.length} vertices');
      return vertices;
    } catch (e) {
      debugPrint('❌ Error parsing OBJ file: $e');
      return [];
    }
  }

  /// Sample vertices evenly to reduce computation
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

    debugPrint('📊 Sampled ${sampled.length} vertices from ${vertices.length}');
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
