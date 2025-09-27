import 'dart:isolate';
import 'package:vector_math/vector_math_64.dart';
import '../entities/object_3d.dart';
import '../entities/procrustes_result.dart';
import 'procrustes_analysis.dart';

/// Service for running Procrustes analysis in isolates for better performance
class ProcrustesIsolateService {
  /// Runs Procrustes analysis in an isolate
  static Future<ProcrustesResult> runAnalysis(
    Object3D objectA,
    Object3D objectB,
    Function(double progress)? onProgress,
  ) async {
    // Create isolate data
    final isolateData = IsolateData(objectA: objectA, objectB: objectB);

    // Create receive port for communication
    final receivePort = ReceivePort();

    try {
      // Spawn isolate
      final isolate = await Isolate.spawn(
        _isolateEntryPoint,
        IsolateMessage(sendPort: receivePort.sendPort, data: isolateData),
      );

      // Listen for results
      final result = await _listenForResults(receivePort, onProgress);

      // Clean up
      isolate.kill();
      receivePort.close();

      return result;
    } catch (e) {
      receivePort.close();
      throw Exception('Isolate analysis failed: $e');
    }
  }

  /// Listens for results from the isolate
  static Future<ProcrustesResult> _listenForResults(
    ReceivePort receivePort,
    Function(double progress)? onProgress,
  ) async {
    await for (final message in receivePort) {
      if (message is IsolateResponse) {
        if (message.type == IsolateResponseType.progress) {
          onProgress?.call(message.progress);
        } else if (message.type == IsolateResponseType.result) {
          return message.result!;
        } else if (message.type == IsolateResponseType.error) {
          throw Exception(message.error);
        }
      }
    }

    throw Exception('No result received from isolate');
  }

  /// Entry point for the isolate
  static void _isolateEntryPoint(IsolateMessage message) async {
    final sendPort = message.sendPort;

    try {
      // Send initial progress
      sendPort.send(IsolateResponse.progress(0.0));

      // Generate points for both objects
      sendPort.send(IsolateResponse.progress(0.2));
      final pointsA = _generateObjectPoints(message.data.objectA);
      final pointsB = _generateObjectPoints(message.data.objectB);

      sendPort.send(IsolateResponse.progress(0.4));

      // Run Procrustes analysis
      sendPort.send(IsolateResponse.progress(0.6));
      final result = ProcrustesAnalysis.align(pointsA, pointsB);

      sendPort.send(IsolateResponse.progress(0.8));

      // Send final result
      sendPort.send(IsolateResponse.progress(1.0));
      sendPort.send(IsolateResponse.result(result));
    } catch (e) {
      sendPort.send(IsolateResponse.error(e.toString()));
    }
  }

  /// Generates sample points for a 3D object (same as in Procrustes class)
  static List<Vector3> _generateObjectPoints(Object3D object) {
    final points = <Vector3>[];

    // Generate a simple geometric shape (cube) as a placeholder
    final vertices = [
      Vector3(-1, -1, -1),
      Vector3(1, -1, -1),
      Vector3(1, 1, -1),
      Vector3(-1, 1, -1),
      Vector3(-1, -1, 1),
      Vector3(1, -1, 1),
      Vector3(1, 1, 1),
      Vector3(-1, 1, 1),
    ];

    // Apply object transformations
    for (final vertex in vertices) {
      // Apply scale
      var transformedVertex = Vector3(
        vertex.x * object.scale.x,
        vertex.y * object.scale.y,
        vertex.z * object.scale.z,
      );

      // Apply rotation (simplified - using Euler angles)
      transformedVertex = _rotateVector(transformedVertex, object.rotation);

      // Apply translation
      transformedVertex += object.position;

      points.add(transformedVertex);
    }

    return points;
  }

  /// Rotates a vector using Euler angles
  static Vector3 _rotateVector(Vector3 vector, Vector3 eulerAngles) {
    // Create rotation matrices for each axis
    final rx = Matrix3.rotationX(eulerAngles.x);
    final ry = Matrix3.rotationY(eulerAngles.y);
    final rz = Matrix3.rotationZ(eulerAngles.z);

    // Combine rotations (order: ZYX)
    final rotation = rz * ry * rx;

    return rotation * vector;
  }
}

/// Data structure for isolate communication
class IsolateData {
  final Object3D objectA;
  final Object3D objectB;

  IsolateData({required this.objectA, required this.objectB});

  Map<String, dynamic> toJson() {
    return {
      'objectA': _objectToJson(objectA),
      'objectB': _objectToJson(objectB),
    };
  }

  static IsolateData fromJson(Map<String, dynamic> json) {
    return IsolateData(
      objectA: _objectFromJson(json['objectA']),
      objectB: _objectFromJson(json['objectB']),
    );
  }

  static Map<String, dynamic> _objectToJson(Object3D object) {
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

  static Object3D _objectFromJson(Map<String, dynamic> json) {
    return Object3D(
      id: json['id'],
      name: json['name'],
      filePath: json['filePath'],
      fileExtension: json['fileExtension'],
      position: Vector3(
        json['position']['x'],
        json['position']['y'],
        json['position']['z'],
      ),
      rotation: Vector3(
        json['rotation']['x'],
        json['rotation']['y'],
        json['rotation']['z'],
      ),
      scale: Vector3(
        json['scale']['x'],
        json['scale']['y'],
        json['scale']['z'],
      ),
      color: Color3D(
        json['color']['red'],
        json['color']['green'],
        json['color']['blue'],
      ),
      opacity: json['opacity'],
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: DateTime.parse(json['lastModified']),
    );
  }
}

/// Message structure for isolate communication
class IsolateMessage {
  final SendPort sendPort;
  final IsolateData data;

  IsolateMessage({required this.sendPort, required this.data});
}

/// Response from isolate
class IsolateResponse {
  final IsolateResponseType type;
  final double progress;
  final ProcrustesResult? result;
  final String? error;

  IsolateResponse._({
    required this.type,
    this.progress = 0.0,
    this.result,
    this.error,
  });

  factory IsolateResponse.progress(double progress) {
    return IsolateResponse._(
      type: IsolateResponseType.progress,
      progress: progress,
    );
  }

  factory IsolateResponse.result(ProcrustesResult result) {
    return IsolateResponse._(type: IsolateResponseType.result, result: result);
  }

  factory IsolateResponse.error(String error) {
    return IsolateResponse._(type: IsolateResponseType.error, error: error);
  }
}

/// Types of isolate responses
enum IsolateResponseType { progress, result, error }
