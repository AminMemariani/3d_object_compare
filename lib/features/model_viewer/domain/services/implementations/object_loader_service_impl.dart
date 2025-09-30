import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:vector_math/vector_math_64.dart';
import '../../entities/object_3d.dart';
import '../interfaces/procrustes_service_interface.dart';

/// Implementation of ObjectLoaderServiceInterface
class ObjectLoaderServiceImpl implements ObjectLoaderServiceInterface {
  static const List<String> _supportedExtensions = [
    'obj',
    'stl',
    'glb',
    'gltf',
  ];

  @override
  Future<Object3D?> loadObjectFromFile(String filePath) async {
    try {
      if (kIsWeb) {
        // Web implementation - file handling is different
        final fileName = filePath.split('/').last;
        final fileExtension = fileName.split('.').last.toLowerCase();

        if (!isSupportedFormat(fileExtension)) {
          throw UnsupportedError('Unsupported file format: $fileExtension');
        }

        // For web, we'll create a mock object since file system access is limited
        return Object3D(
          id: fileName.replaceAll('.', '_'),
          name: fileName,
          filePath: filePath,
          fileExtension: fileExtension,
          position: Vector3.zero(),
          rotation: Vector3.zero(),
          scale: Vector3.all(1.0),
          color: const Color3D(0.5, 0.5, 0.5),
          opacity: 1.0,
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
        );
      } else {
        // Native implementation - for now, use the same mock approach
        // In a real implementation, you would use dart:io here
        final fileName = filePath.split('/').last;
        final fileExtension = fileName.split('.').last.toLowerCase();

        if (!isSupportedFormat(fileExtension)) {
          throw UnsupportedError('Unsupported file format: $fileExtension');
        }

        // In a real implementation, you would parse the 3D file here
        // For now, we create a mock object
        return Object3D(
          id: fileName.replaceAll('.', '_'),
          name: fileName,
          filePath: filePath,
          fileExtension: fileExtension,
          position: Vector3.zero(),
          rotation: Vector3.zero(),
          scale: Vector3.all(1.0),
          color: const Color3D(0.5, 0.5, 0.5),
          opacity: 1.0,
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
        );
      }
    } catch (e) {
      throw Exception('Failed to load object from file: $e');
    }
  }

  @override
  bool isSupportedFormat(String fileExtension) {
    return _supportedExtensions.contains(fileExtension.toLowerCase());
  }

  @override
  List<String> getSupportedExtensions() {
    return List.unmodifiable(_supportedExtensions);
  }
}
