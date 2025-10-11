import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:vector_math/vector_math_64.dart';
import 'model_parser_interface.dart';

/// Service for parsing GLB (GL Binary Format) file format and extracting vertex data
/// GLB is the binary version of GLTF that contains all data in a single binary file
class GlbParserService implements ModelParserInterface {
  @override
  List<String> get supportedExtensions => ['glb'];

  // GLB constants
  static const int _glbMagic = 0x46546C67; // "glTF" in ASCII
  static const int _chunkTypeJson = 0x4E4F534A; // "JSON" in ASCII
  static const int _chunkTypeBin = 0x004E4942; // "BIN\0" in ASCII

  @override
  Future<List<Vector3>> parseFile({
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      Uint8List bytes;

      if (fileBytes != null) {
        bytes = fileBytes;
      } else if (!kIsWeb && filePath != null) {
        final file = File(filePath);
        if (!await file.exists()) {
          throw Exception('GLB file not found: $filePath');
        }
        bytes = await file.readAsBytes();
      } else {
        throw Exception('No file data provided for GLB parsing');
      }

      if (bytes.isEmpty) {
        throw Exception('Empty GLB file');
      }

      final vertices = _parseGlbBinary(bytes);

      if (vertices.isEmpty) {
        print('⚠️ No vertices found in GLB file: ${fileName ?? filePath ?? "unknown"}');
        return [];
      }

      print('✅ Parsed GLB file: ${vertices.length} vertices');
      return vertices;
    } catch (e) {
      print('❌ Error parsing GLB file: $e');
      return [];
    }
  }

  /// Parse GLB binary format
  List<Vector3> _parseGlbBinary(Uint8List bytes) {
    final vertices = <Vector3>[];
    
    try {
      if (bytes.length < 20) {
        throw Exception('Invalid GLB: file too small for header');
      }
      
      final data = ByteData.view(bytes.buffer);
      
      // Read GLB header
      final magic = data.getUint32(0, Endian.little);
      final version = data.getUint32(4, Endian.little);
      final length = data.getUint32(8, Endian.little);
      
      if (magic != _glbMagic) {
        throw Exception('Invalid GLB: wrong magic number');
      }
      
      if (version != 2) {
        throw Exception('Unsupported GLB version: $version');
      }
      
      if (bytes.length < length) {
        throw Exception('Invalid GLB: file size mismatch');
      }
      
      int offset = 12; // Start after header
      String? jsonContent;
      Uint8List? binaryData;
      
      // Read chunks
      while (offset < length) {
        if (offset + 8 > bytes.length) break;
        
        final chunkLength = data.getUint32(offset, Endian.little);
        final chunkType = data.getUint32(offset + 4, Endian.little);
        offset += 8;
        
        if (offset + chunkLength > bytes.length) {
          throw Exception('Invalid GLB: chunk extends beyond file');
        }
        
        if (chunkType == _chunkTypeJson) {
          // JSON chunk
          final jsonBytes = bytes.sublist(offset, offset + chunkLength);
          jsonContent = utf8.decode(jsonBytes);
        } else if (chunkType == _chunkTypeBin) {
          // Binary chunk
          binaryData = bytes.sublist(offset, offset + chunkLength);
        }
        
        offset += chunkLength;
      }
      
      if (jsonContent == null) {
        throw Exception('No JSON chunk found in GLB file');
      }
      
      // Parse GLTF JSON with embedded binary data
      vertices.addAll(_parseGltfWithBinary(jsonContent, binaryData));
      
    } catch (e) {
      throw Exception('Error parsing GLB binary: $e');
    }
    
    return vertices;
  }

  /// Parse GLTF JSON content with embedded binary data
  List<Vector3> _parseGltfWithBinary(String jsonContent, Uint8List? binaryData) {
    final vertices = <Vector3>[];
    
    try {
      final gltf = json.decode(jsonContent) as Map<String, dynamic>;
      
      // Get accessors, bufferViews, and meshes
      final accessors = gltf['accessors'] as List<dynamic>?;
      final bufferViews = gltf['bufferViews'] as List<dynamic>?;
      final meshes = gltf['meshes'] as List<dynamic>?;
      
      if (meshes == null || accessors == null || bufferViews == null) {
        print('⚠️ GLB missing required structures (meshes, accessors, or bufferViews)');
        return vertices;
      }

      // In GLB, buffer 0 typically refers to the embedded binary data
      final bufferData = <int, Uint8List>{};
      if (binaryData != null) {
        bufferData[0] = binaryData;
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
      throw Exception('Error parsing GLB GLTF content: $e');
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
        if (startOffset + count * 12 > data.length) {
          throw Exception('Buffer overflow when reading vertices');
        }
        
        final byteData = ByteData.view(data.buffer, data.offsetInBytes + startOffset);
        for (int i = 0; i < count; i++) {
          final x = byteData.getFloat32(i * 12, Endian.little);
          final y = byteData.getFloat32(i * 12 + 4, Endian.little);
          final z = byteData.getFloat32(i * 12 + 8, Endian.little);
          vertices.add(Vector3(x, y, z));
        }
      } else {
        // For other component types, we'd need more complex handling
        print('⚠️ Unsupported GLB component type: $componentType');
      }
    } catch (e) {
      print('⚠️ Error extracting vertices from accessor: $e');
    }
    
    return vertices;
  }
}
