import 'package:vector_math/vector_math_64.dart';
import '../../entities/object_3d.dart';
import '../../entities/procrustes_result.dart';
import '../interfaces/procrustes_service_interface.dart';
import '../procrustes.dart';

/// Implementation of ProcrustesServiceInterface
class ProcrustesServiceImpl implements ProcrustesServiceInterface {
  @override
  Future<ProcrustesResult> alignObjects(
    Object3D objectA,
    Object3D objectB,
  ) async {
    return Procrustes.align(objectA, objectB);
  }

  @override
  ProcrustesResult alignPoints(List<Vector3> pointsA, List<Vector3> pointsB) {
    return Procrustes.alignPoints(pointsA, pointsB);
  }

  @override
  Object3D applyTransformation(Object3D object, ProcrustesResult result) {
    return Procrustes.applyTransformation(object, result);
  }

  @override
  ProcrustesMetrics computeSimilarity(Object3D objectA, Object3D objectB) {
    return Procrustes.computeSimilarity(objectA, objectB);
  }

  @override
  List<Vector3> generateObjectPoints(Object3D object) {
    // Generate mock cube points for testing
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
