import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:vector_math/vector_math_64.dart';
import 'model_parser_interface.dart';

/// Service for parsing STL (Stereolithography) file format and extracting vertex data
/// Supports both ASCII and Binary STL formats
class StlParserService implements ModelParserInterface {
  @override
  List<String> get supportedExtensions => ['stl'];

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
          throw Exception('STL file not found: $filePath');
        }
        bytes = await file.readAsBytes();
      } else {
        throw Exception('No file data provided for STL parsing');
      }

      if (bytes.isEmpty) {
        throw Exception('Empty STL file');
      }

      // Detect if it's ASCII or binary STL
      final isAscii = _isAsciiStl(bytes);
      
      List<Vector3> vertices;
      if (isAscii) {
        vertices = _parseAsciiStl(bytes);
      } else {
        vertices = _parseBinaryStl(bytes);
      }

      if (vertices.isEmpty) {
        print('⚠️ No vertices found in STL file: ${fileName ?? filePath ?? "unknown"}');
        return [];
      }

      print('✅ Parsed STL file (${isAscii ? "ASCII" : "Binary"}): ${vertices.length} vertices');
      return vertices;
    } catch (e) {
      print('❌ Error parsing STL file: $e');
      return [];
    }
  }

  /// Check if STL file is in ASCII format
  bool _isAsciiStl(Uint8List bytes) {
    if (bytes.length < 80) return false;
    
    try {
      // Try to decode first part as UTF-8 and check for "solid" keyword
      final header = utf8.decode(bytes.take(80).toList(), allowMalformed: false);
      return header.toLowerCase().trim().startsWith('solid');
    } catch (e) {
      // If UTF-8 decoding fails, it's likely binary
      return false;
    }
  }

  /// Parse ASCII STL format
  List<Vector3> _parseAsciiStl(Uint8List bytes) {
    final vertices = <Vector3>[];
    
    try {
      final content = utf8.decode(bytes);
      final lines = content.split('\n');
      
      for (final line in lines) {
        final trimmed = line.trim().toLowerCase();
        if (trimmed.startsWith('vertex ')) {
          final parts = trimmed.split(RegExp(r'\s+'));
          if (parts.length >= 4) {
            try {
              final x = double.parse(parts[1]);
              final y = double.parse(parts[2]);
              final z = double.parse(parts[3]);
              vertices.add(Vector3(x, y, z));
            } catch (e) {
              // Skip malformed vertex lines
              continue;
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Error parsing ASCII STL: $e');
    }
    
    return vertices;
  }

  /// Parse Binary STL format
  List<Vector3> _parseBinaryStl(Uint8List bytes) {
    final vertices = <Vector3>[];
    
    try {
      // Binary STL format:
      // 80-byte header
      // 4-byte triangle count (little-endian)
      // For each triangle:
      //   - 12 bytes: normal vector (3 floats)
      //   - 36 bytes: vertices (9 floats, 3 per vertex)
      //   - 2 bytes: attribute byte count
      
      if (bytes.length < 84) {
        throw Exception('Invalid binary STL: file too small');
      }
      
      final data = ByteData.view(bytes.buffer);
      
      // Skip 80-byte header and read triangle count
      final triangleCount = data.getUint32(80, Endian.little);
      
      if (triangleCount == 0) {
        return vertices;
      }
      
      // Expected file size: 80 (header) + 4 (count) + triangleCount * 50
      final expectedSize = 84 + triangleCount * 50;
      if (bytes.length < expectedSize) {
        throw Exception('Invalid binary STL: unexpected file size');
      }
      
      int offset = 84; // Start after header and triangle count
      
      for (int i = 0; i < triangleCount; i++) {
        // Skip normal vector (12 bytes)
        offset += 12;
        
        // Read 3 vertices (9 floats, 4 bytes each)
        for (int v = 0; v < 3; v++) {
          final x = data.getFloat32(offset, Endian.little);
          final y = data.getFloat32(offset + 4, Endian.little);
          final z = data.getFloat32(offset + 8, Endian.little);
          
          vertices.add(Vector3(x, y, z));
          offset += 12;
        }
        
        // Skip attribute byte count (2 bytes)
        offset += 2;
      }
    } catch (e) {
      throw Exception('Error parsing binary STL: $e');
    }
    
    return vertices;
  }
}
