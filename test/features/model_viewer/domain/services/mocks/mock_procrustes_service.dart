import 'package:vector_math/vector_math_64.dart';
import 'package:flutter_3d_app/features/model_viewer/domain/entities/object_3d.dart';
import 'package:flutter_3d_app/features/model_viewer/domain/entities/procrustes_result.dart';
import 'package:flutter_3d_app/features/model_viewer/domain/services/interfaces/procrustes_service_interface.dart';

/// Mock implementation of ProcrustesServiceInterface for testing
class MockProcrustesService implements ProcrustesServiceInterface {
  final List<ProcrustesResult> _mockResults = [];
  final List<ProcrustesMetrics> _mockMetrics = [];
  bool _shouldThrowError = false;
  String _errorMessage = 'Mock error';

  /// Sets up mock results for testing
  void setMockResults(List<ProcrustesResult> results) {
    _mockResults.clear();
    _mockResults.addAll(results);
  }

  /// Sets up mock metrics for testing
  void setMockMetrics(List<ProcrustesMetrics> metrics) {
    _mockMetrics.clear();
    _mockMetrics.addAll(metrics);
  }

  /// Configures the mock to throw an error
  void setShouldThrowError(bool shouldThrow, [String? message]) {
    _shouldThrowError = shouldThrow;
    if (message != null) {
      _errorMessage = message;
    }
  }

  @override
  Future<ProcrustesResult> alignObjects(
    Object3D objectA,
    Object3D objectB,
  ) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }

    if (_mockResults.isNotEmpty) {
      return _mockResults.removeAt(0);
    }

    // Default mock result
    return ProcrustesResult(
      translation: Vector3.zero(),
      rotation: Matrix3.identity(),
      scale: 1.0,
      metrics: ProcrustesMetrics(
        similarityScore: 85.0,
        minimumDistance: 0.1,
        standardDeviation: 0.05,
        rootMeanSquareError: 0.15,
        meanDistance: 0.1,
        maxDistance: 0.2,
        numberOfPoints: 8,
      ),
      numberOfPoints: 8,
    );
  }

  @override
  ProcrustesResult alignPoints(List<Vector3> pointsA, List<Vector3> pointsB) {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }

    if (_mockResults.isNotEmpty) {
      return _mockResults.removeAt(0);
    }

    // Default mock result
    return ProcrustesResult(
      translation: Vector3.zero(),
      rotation: Matrix3.identity(),
      scale: 1.0,
      metrics: ProcrustesMetrics(
        similarityScore: 90.0,
        minimumDistance: 0.05,
        standardDeviation: 0.03,
        rootMeanSquareError: 0.08,
        meanDistance: 0.05,
        maxDistance: 0.1,
        numberOfPoints: pointsA.length,
      ),
      numberOfPoints: pointsA.length,
    );
  }

  @override
  Object3D applyTransformation(Object3D object, ProcrustesResult result) {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }

    return object.copyWith(
      position: object.position + result.translation,
      lastModified: DateTime.now(),
    );
  }

  @override
  ProcrustesMetrics computeSimilarity(Object3D objectA, Object3D objectB) {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }

    if (_mockMetrics.isNotEmpty) {
      return _mockMetrics.removeAt(0);
    }

    // Default mock metrics
    return ProcrustesMetrics(
      similarityScore: 80.0,
      minimumDistance: 0.2,
      standardDeviation: 0.1,
      rootMeanSquareError: 0.25,
      meanDistance: 0.2,
      maxDistance: 0.4,
      numberOfPoints: 8,
    );
  }

  @override
  List<Vector3> generateObjectPoints(Object3D object) {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }

    // Generate mock cube points
    return [
      Vector3(-1, -1, -1),
      Vector3(1, -1, -1),
      Vector3(1, 1, -1),
      Vector3(-1, 1, -1),
      Vector3(-1, -1, 1),
      Vector3(1, -1, 1),
      Vector3(1, 1, 1),
      Vector3(-1, 1, 1),
    ];
  }
}

/// Mock implementation of ObjectLoaderServiceInterface for testing
class MockObjectLoaderService {
  final List<Object3D> _mockObjects = [];
  bool _shouldThrowError = false;
  String _errorMessage = 'Mock error';

  /// Sets up mock objects for testing
  void setMockObjects(List<Object3D> objects) {
    _mockObjects.clear();
    _mockObjects.addAll(objects);
  }

  /// Configures the mock to throw an error
  void setShouldThrowError(bool shouldThrow, [String? message]) {
    _shouldThrowError = shouldThrow;
    if (message != null) {
      _errorMessage = message;
    }
  }

  Future<Object3D?> loadObjectFromFile(String filePath) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }

    if (_mockObjects.isNotEmpty) {
      return _mockObjects.removeAt(0);
    }

    // Default mock object
    return Object3D(
      id: 'mock_object',
      name: 'Mock Object',
      filePath: filePath,
      fileExtension: 'obj',
      position: Vector3.zero(),
      rotation: Vector3.zero(),
      scale: Vector3.all(1.0),
      color: const Color3D(0.5, 0.5, 0.5),
      opacity: 1.0,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );
  }

  bool isSupportedFormat(String fileExtension) {
    return ['obj', 'stl', 'glb', 'gltf'].contains(fileExtension.toLowerCase());
  }

  List<String> getSupportedExtensions() {
    return ['obj', 'stl', 'glb', 'gltf'];
  }
}

/// Mock implementation of ExportServiceInterface for testing
class MockExportService {
  bool _shouldThrowError = false;
  String _errorMessage = 'Mock error';

  /// Configures the mock to throw an error
  void setShouldThrowError(bool shouldThrow, [String? message]) {
    _shouldThrowError = shouldThrow;
    if (message != null) {
      _errorMessage = message;
    }
  }

  Future<String> exportAsJson(
    ProcrustesResult result,
    Object3D objectA,
    Object3D objectB,
  ) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }

    return '{"mock": "json", "similarityScore": ${result.similarityScore}}';
  }

  Future<String> exportAsCsv(
    ProcrustesResult result,
    Object3D objectA,
    Object3D objectB,
  ) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }

    return 'Metric,Value\nSimilarity Score,${result.similarityScore}%';
  }

  Future<String> saveToFile(String content, String filename) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }

    return '/mock/path/$filename';
  }

  Future<void> shareFile(String filePath, String subject) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }

    // Mock implementation - do nothing
  }
}
