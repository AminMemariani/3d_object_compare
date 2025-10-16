import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:vector_math/vector_math_64.dart';
import 'model_parser_interface.dart';

/// Service for parsing GLTF (GL Transmission Format) file format and extracting vertex data
/// Supports JSON-based GLTF with embedded or external binary data
class GltfParserService implements ModelParserInterface {
  @override
  List<String> get supportedExtensions => ['gltf'];

  @override
  Future<List<Vector3>> parseFile({
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      String jsonContent;

      if (fileBytes != null) {
        jsonContent = utf8.decode(fileBytes);
      } else if (!kIsWeb && filePath != null) {
        final file = File(filePath);
        if (!await file.exists()) {
          throw Exception('GLTF file not found: $filePath');
        }
        jsonContent = await file.readAsString();
      } else {
        throw Exception('No file data provided for GLTF parsing');
      }

      final vertices = await _parseGltfJson(jsonContent, filePath);

      if (vertices.isEmpty) {
        debugPrint(
          '⚠️ No vertices found in GLTF file: ${fileName ?? filePath ?? "unknown"}',
        );
        return [];
      }

      debugPrint('✅ Parsed GLTF file: ${vertices.length} vertices');
      return vertices;
    } catch (e) {
      debugPrint('❌ Error parsing GLTF file: $e');
      return [];
    }
  }

  /// Parse GLTF JSON content and extract vertices
  Future<List<Vector3>> _parseGltfJson(String jsonContent, String? basePath) async {
    final vertices = <Vector3>[];
    
    try {
      final gltf = json.decode(jsonContent) as Map<String, dynamic>;
      
      // Get accessors, bufferViews, and buffers
      final accessors = gltf['accessors'] as List<dynamic>?;
      final bufferViews = gltf['bufferViews'] as List<dynamic>?;
      final buffers = gltf['buffers'] as List<dynamic>?;
      final meshes = gltf['meshes'] as List<dynamic>?;
      
      if (meshes == null || accessors == null || bufferViews == null) {
        debugPrint(
          '⚠️ GLTF missing required structures (meshes, accessors, or bufferViews)',
        );
        return vertices;
      }

      // Load buffer data
      final bufferData = <int, Uint8List>{};
      if (buffers != null) {
        for (int i = 0; i < buffers.length; i++) {
          final buffer = buffers[i] as Map<String, dynamic>;
          final uri = buffer['uri'] as String?;
          
          if (uri != null) {
            if (uri.startsWith('data:')) {
              // Embedded base64 data
              bufferData[i] = _parseDataUri(uri);
            } else if (!kIsWeb && basePath != null) {
              // External binary file
              final bufferFile = File('${basePath.substring(0, basePath.lastIndexOf('/'))}/$uri');
              if (await bufferFile.exists()) {
                bufferData[i] = await bufferFile.readAsBytes();
              }
            }
          }
        }
      }
      
      // Extract vertices from meshes
      for (final mesh in meshes) {
        final primitives = mesh['primitives'] as List<dynamic>?;
        if (primitives == null) continue;
        
        for (final primitive in primitives) {
          final attributes = primitive['attributes'] as Map<String, dynamic>?;
          if (attributes == null) continue;
          
          final positionAccessor = attributes['POSITION'] as int?;
          if (positionAccessor == null) continue;
          
          final positions = _extractVertices(
            positionAccessor,
            accessors,
            bufferViews,
            bufferData,
          );
          vertices.addAll(positions);
        }
      }
    } catch (e) {
      throw Exception('Error parsing GLTF JSON: $e');
    }
    
    return vertices;
  }

  /// Extract vertex positions from accessor
  List<Vector3> _extractVertices(
    int accessorIndex,
    List<dynamic> accessors,
    List<dynamic> bufferViews,
    Map<int, Uint8List> bufferData,
  ) {
    final vertices = <Vector3>[];
    
    try {
      if (accessorIndex >= accessors.length) return vertices;
      
      final accessor = accessors[accessorIndex] as Map<String, dynamic>;
      final bufferView = accessor['bufferView'] as int?;
      final componentType = accessor['componentType'] as int?;
      final count = accessor['count'] as int?;
      final type = accessor['type'] as String?;
      final byteOffset = accessor['byteOffset'] as int? ?? 0;
      
      if (bufferView == null || componentType == null || count == null || type != 'VEC3') {
        return vertices;
      }
      
      if (bufferView >= bufferViews.length) return vertices;
      
      final bufferViewData = bufferViews[bufferView] as Map<String, dynamic>;
      final buffer = bufferViewData['buffer'] as int?;
      final bufferViewOffset = bufferViewData['byteOffset'] as int? ?? 0;
      
      if (buffer == null || !bufferData.containsKey(buffer)) {
        return vertices;
      }
      
      final data = bufferData[buffer]!;
      final startOffset = bufferViewOffset + byteOffset;
      
      // Component type constants from GLTF spec
      const componentTypeFloat = 5126; // GL_FLOAT
      
      if (componentType == componentTypeFloat) {
        // Float vertices (most common)
        final byteData = ByteData.view(data.buffer, startOffset);
        for (int i = 0; i < count; i++) {
          final x = byteData.getFloat32(i * 12, Endian.little);
          final y = byteData.getFloat32(i * 12 + 4, Endian.little);
          final z = byteData.getFloat32(i * 12 + 8, Endian.little);
          vertices.add(Vector3(x, y, z));
        }
      } else {
        // For other component types, we'd need more complex handling
        debugPrint('⚠️ Unsupported GLTF component type: $componentType');
      }
    } catch (e) {
      debugPrint('⚠️ Error extracting vertices from accessor: $e');
    }
    
    return vertices;
  }

  /// Parse data URI to bytes
  Uint8List _parseDataUri(String dataUri) {
    // Format: data:application/octet-stream;base64,<base64-encoded-data>
    final commaIndex = dataUri.indexOf(',');
    if (commaIndex == -1) {
      throw Exception('Invalid data URI format');
    }
    
    final base64Data = dataUri.substring(commaIndex + 1);
    return base64.decode(base64Data);
  }
}
