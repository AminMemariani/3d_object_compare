import 'dart:math' as math;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:vector_math/vector_math_64.dart';
import '../entities/procrustes_result.dart';
import '../entities/object_3d.dart';
import 'procrustes_analysis.dart';

/// Clean API for Procrustes superimposition analysis
class Procrustes {
  /// Aligns two 3D objects using Procrustes superimposition
  ///
  /// [objectA] - Reference object (target)
  /// [objectB] - Object to be aligned (source)
  ///
  /// Returns [ProcrustesResult] containing transformation parameters and metrics
  static ProcrustesResult align(Object3D objectA, Object3D objectB) {
    // Use actual mesh vertices if available, otherwise use placeholder
    final pointsA = objectA.vertices != null && objectA.vertices!.isNotEmpty
        ? objectA.vertices!
        : _generateObjectPoints(objectA);

    final pointsB = objectB.vertices != null && objectB.vertices!.isNotEmpty
        ? objectB.vertices!
        : _generateObjectPoints(objectB);

    debugPrint('🔬 Procrustes Analysis:');
    debugPrint(
      '   Object A: ${pointsA.length} vertices ${objectA.vertices != null ? "(real mesh data)" : "(placeholder cube)"}',
    );
    debugPrint(
      '   Object B: ${pointsB.length} vertices ${objectB.vertices != null ? "(real mesh data)" : "(placeholder cube)"}',
    );

    return ProcrustesAnalysis.align(pointsA, pointsB);
  }

  /// Aligns two sets of 3D points using Procrustes superimposition
  ///
  /// [pointsA] - Reference points (target)
  /// [pointsB] - Points to be aligned (source)
  ///
  /// Returns [ProcrustesResult] containing transformation parameters and metrics
  static ProcrustesResult alignPoints(
    List<Vector3> pointsA,
    List<Vector3> pointsB,
  ) {
    return ProcrustesAnalysis.align(pointsA, pointsB);
  }

  /// Applies Procrustes transformation to an object
  ///
  /// [object] - Object to transform
  /// [result] - Procrustes result containing transformation parameters
  ///
  /// Returns transformed [Object3D]
  static Object3D applyTransformation(
    Object3D object,
    ProcrustesResult result,
  ) {
    // Apply rotation, scale, and translation
    final newPosition =
        result.translation + (result.rotation * object.position) * result.scale;
    final newRotation = _matrixToEuler(result.rotation);
    final newScale = object.scale * result.scale;

    return object.copyWith(
      position: newPosition,
      rotation: newRotation,
      scale: newScale,
      lastModified: DateTime.now(),
    );
  }

  /// Computes similarity metrics between two objects
  ///
  /// [objectA] - First object
  /// [objectB] - Second object
  ///
  /// Returns [ProcrustesMetrics] with similarity scores
  static ProcrustesMetrics computeSimilarity(
    Object3D objectA,
    Object3D objectB,
  ) {
    final result = align(objectA, objectB);
    return ProcrustesMetrics(
      similarityScore: result.similarityScore,
      minimumDistance: result.minimumDistance,
      standardDeviation: result.standardDeviation,
      rootMeanSquareError: result.rootMeanSquareError,
      meanDistance: result.minimumDistance, // Approximation
      maxDistance: result.minimumDistance + result.standardDeviation,
      numberOfPoints: result.numberOfPoints,
    );
  }

  /// Generates placeholder cube points for a 3D object
  ///
  /// This is used as a fallback when actual mesh vertices are not available.
  /// Used for: GLB/GLTF files (can't easily parse), STL files (not yet implemented),
  /// or when file parsing fails.
  ///
  /// WARNING: Comparing placeholder cubes will give misleading similarity scores!
  static List<Vector3> _generateObjectPoints(Object3D object) {
    final points = <Vector3>[];

    debugPrint('⚠️ WARNING: Using placeholder cube vertices for ${object.name}');
    debugPrint('   This will NOT give accurate comparison results!');
    debugPrint('   Use OBJ files for proper analysis.');

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

  /// Converts a rotation matrix to Euler angles
  static Vector3 _matrixToEuler(Matrix3 rotation) {
    // Extract Euler angles from rotation matrix
    final sy = math.sqrt(
      rotation.entry(0, 0) * rotation.entry(0, 0) +
          rotation.entry(1, 0) * rotation.entry(1, 0),
    );

    final singular = sy < 1e-6;

    double x, y, z;

    if (!singular) {
      x = math.atan2(rotation.entry(2, 1), rotation.entry(2, 2));
      y = math.atan2(-rotation.entry(2, 0), sy);
      z = math.atan2(rotation.entry(1, 0), rotation.entry(0, 0));
    } else {
      x = math.atan2(-rotation.entry(1, 2), rotation.entry(1, 1));
      y = math.atan2(-rotation.entry(2, 0), sy);
      z = 0;
    }

    return Vector3(x, y, z);
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
