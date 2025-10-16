import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:vector_math/vector_math_64.dart';
import 'model_parser_interface.dart';
import 'obj_parser_service.dart';
import 'stl_parser_service.dart';
import 'gltf_parser_service.dart';
import 'glb_parser_service.dart';

/// Factory class for creating appropriate 3D model parsers based on file extension
class ModelParserFactory {
  static final Map<String, ModelParserInterface> _parsers = {
    'obj': ObjParserService(),
    'stl': StlParserService(),
    'gltf': GltfParserService(),
    'glb': GlbParserService(),
  };

  /// Get parser for the given file extension
  static ModelParserInterface? getParser(String extension) {
    final normalizedExtension = extension.toLowerCase().replaceAll('.', '');
    return _parsers[normalizedExtension];
  }

  /// Parse a 3D model file and extract vertices using the appropriate parser
  static Future<List<Vector3>> parseFile({
    required String fileExtension,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final parser = getParser(fileExtension);
    if (parser == null) {
      throw Exception('Unsupported file format: $fileExtension');
    }

    try {
      final vertices = await parser.parseFile(
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
      );

      // Apply sampling if there are too many vertices
      if (vertices.isNotEmpty) {
        final sampleSize = ModelParserInterface.getRecommendedSampleSize(vertices.length);
        if (vertices.length > sampleSize) {
          final sampledVertices = ModelParserInterface.sampleVertices(vertices, sampleSize);
          debugPrint(
            '📊 Sampled ${sampledVertices.length} vertices from ${vertices.length} for performance',
          );
          return sampledVertices;
        }
      }

      return vertices;
    } catch (e) {
      debugPrint('❌ Error parsing ${fileExtension.toUpperCase()} file: $e');
      return [];
    }
  }

  /// Get all supported file extensions
  static List<String> getSupportedExtensions() {
    return _parsers.keys.toList();
  }

  /// Check if a file extension is supported
  static bool isExtensionSupported(String extension) {
    final normalizedExtension = extension.toLowerCase().replaceAll('.', '');
    return _parsers.containsKey(normalizedExtension);
  }

  /// Get parser information for debugging
  static Map<String, String> getParserInfo() {
    return _parsers.map((ext, parser) => 
      MapEntry(ext, parser.runtimeType.toString()));
  }
}
