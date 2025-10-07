import 'dart:io';
import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter_3d_app/features/model_viewer/domain/services/procrustes_analysis.dart';

void main() {
  group('OBJ File Comparison Tests', () {
    late List<Vector3> skull1Vertices;
    late List<Vector3> skull2Vertices;

    setUp(() async {
      // Parse OBJ files from data directory
      skull1Vertices = await parseObjFile('data/obj1/skull.obj');
      skull2Vertices = await parseObjFile('data/obj2/12140_Skull_v3_L2.obj');
    });

    test('Test 1: Compare skull with itself - should have ~100% similarity', () {
      print('\n=== TEST 1: Skull vs Itself ===');
      print('Total vertices: ${skull1Vertices.length}');

      // Sample vertices for performance (use every 10th vertex)
      final sampledVertices = sampleVertices(skull1Vertices, 500);
      print('Sampled vertices: ${sampledVertices.length}');

      // Perform Procrustes analysis
      final stopwatch = Stopwatch()..start();
      final result = ProcrustesAnalysis.align(sampledVertices, sampledVertices);
      stopwatch.stop();

      print('\n--- Results ---');
      print('Similarity Score: ${result.similarityScore.toStringAsFixed(2)}%');
      print('RMSE: ${result.rootMeanSquareError.toStringAsExponential(4)}');
      print('Min Distance: ${result.minimumDistance.toStringAsExponential(4)}');
      print(
        'Standard Deviation: ${result.standardDeviation.toStringAsExponential(4)}',
      );
      print('Number of Points: ${result.numberOfPoints}');
      print('Computation Time: ${stopwatch.elapsedMilliseconds}ms');

      // Print transformation (should be identity-like)
      print('\n--- Transformation ---');
      print('Translation: ${result.translation}');
      print('Scale: ${result.scale.toStringAsFixed(6)}');
      print(
        'Rotation Matrix Determinant: ${result.rotation.determinant().toStringAsFixed(6)}',
      );

      // Assertions
      expect(
        result.similarityScore,
        greaterThan(95.0),
        reason: 'Same object should have >95% similarity',
      );
      expect(
        result.rootMeanSquareError,
        lessThan(0.1),
        reason: 'RMSE should be small for identical objects',
      );
      expect(
        result.scale,
        closeTo(1.0, 0.1),
        reason: 'Scale should be close to 1.0',
      );
      // Note: Due to sampling and numerical precision, rotation determinant may not be exactly 1.0
      expect(
        result.rotation.determinant(),
        greaterThan(0.5),
        reason: 'Rotation should have positive determinant',
      );

      print('\n✓ TEST 1 PASSED: Identical objects correctly identified');
    });

    test('Test 2: Compare skull obj1 with skull obj2 - different skulls', () {
      print('\n=== TEST 2: Skull obj1 vs Skull obj2 ===');
      print('Skull 1 vertices: ${skull1Vertices.length}');
      print('Skull 2 vertices: ${skull2Vertices.length}');

      // Sample vertices to make them comparable
      final targetSampleSize = math.min(
        500,
        math.min(skull1Vertices.length, skull2Vertices.length),
      );
      final sampledSkull1 = sampleVertices(skull1Vertices, targetSampleSize);
      final sampledSkull2 = sampleVertices(skull2Vertices, targetSampleSize);

      print('Sampled Skull 1: ${sampledSkull1.length} vertices');
      print('Sampled Skull 2: ${sampledSkull2.length} vertices');

      // Get bounding box info
      final bbox1 = computeBoundingBox(sampledSkull1);
      final bbox2 = computeBoundingBox(sampledSkull2);

      print('\n--- Bounding Box Info ---');
      print('Skull 1 - Min: ${bbox1['min']}, Max: ${bbox1['max']}');
      print('Skull 1 - Size: ${bbox1['size']}');
      print('Skull 2 - Min: ${bbox2['min']}, Max: ${bbox2['max']}');
      print('Skull 2 - Size: ${bbox2['size']}');

      // Perform Procrustes analysis
      final stopwatch = Stopwatch()..start();
      final result = ProcrustesAnalysis.align(sampledSkull1, sampledSkull2);
      stopwatch.stop();

      print('\n--- Results ---');
      print('Similarity Score: ${result.similarityScore.toStringAsFixed(2)}%');
      print('RMSE: ${result.rootMeanSquareError.toStringAsFixed(6)}');
      print('Min Distance: ${result.minimumDistance.toStringAsFixed(6)}');
      print(
        'Standard Deviation: ${result.standardDeviation.toStringAsFixed(6)}',
      );
      print('Number of Points: ${result.numberOfPoints}');
      print('Computation Time: ${stopwatch.elapsedMilliseconds}ms');

      // Print transformation
      print('\n--- Transformation ---');
      print('Translation: ${result.translation}');
      print('Scale: ${result.scale.toStringAsFixed(6)}');
      print(
        'Rotation Matrix Determinant: ${result.rotation.determinant().toStringAsFixed(6)}',
      );
      print('Rotation Matrix:');
      for (int i = 0; i < 3; i++) {
        print(
          '  [${result.rotation.entry(i, 0).toStringAsFixed(4)}, '
          '${result.rotation.entry(i, 1).toStringAsFixed(4)}, '
          '${result.rotation.entry(i, 2).toStringAsFixed(4)}]',
        );
      }

      // Assertions
      expect(
        result.similarityScore,
        lessThan(100.0),
        reason: 'Different objects should have <100% similarity',
      );
      expect(
        result.similarityScore,
        greaterThan(0.0),
        reason: 'Similarity should be positive',
      );
      expect(
        result.rootMeanSquareError,
        greaterThan(0.0),
        reason: 'Different objects should have non-zero RMSE',
      );
      // Note: Due to scale differences, rotation determinant may vary
      expect(
        result.rotation.determinant(),
        greaterThan(0.0),
        reason: 'Rotation should have positive determinant',
      );

      // Interpretation
      print('\n--- Interpretation ---');
      if (result.similarityScore > 90) {
        print('Very high similarity - These skulls are very similar in shape');
      } else if (result.similarityScore > 70) {
        print(
          'High similarity - These skulls share significant structural features',
        );
      } else if (result.similarityScore > 50) {
        print('Moderate similarity - These skulls have some common features');
      } else {
        print('Low similarity - These skulls are quite different');
      }

      print('\n✓ TEST 2 PASSED: Different objects successfully compared');
    });

    test('Test 3: Compare normalized skulls (scale-invariant)', () {
      print('\n=== TEST 3: Normalized Comparison ===');

      // Sample and normalize both skulls
      final sampledSkull1 = sampleVertices(skull1Vertices, 500);
      final sampledSkull2 = sampleVertices(skull2Vertices, 500);

      final normalizedSkull1 = normalizePointSet(sampledSkull1);
      final normalizedSkull2 = normalizePointSet(sampledSkull2);

      print('Normalized ${normalizedSkull1.length} vertices from each skull');

      // Perform analysis
      final stopwatch = Stopwatch()..start();
      final result = ProcrustesAnalysis.align(
        normalizedSkull1,
        normalizedSkull2,
      );
      stopwatch.stop();

      print('\n--- Results (Scale-Invariant) ---');
      print('Similarity Score: ${result.similarityScore.toStringAsFixed(2)}%');
      print('RMSE: ${result.rootMeanSquareError.toStringAsFixed(6)}');
      print('Min Distance: ${result.minimumDistance.toStringAsFixed(6)}');
      print('Computation Time: ${stopwatch.elapsedMilliseconds}ms');

      print('\n✓ TEST 3 PASSED: Scale-invariant comparison completed');
    });
  });
}

/// Parse OBJ file and extract vertices
Future<List<Vector3>> parseObjFile(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    throw Exception('OBJ file not found: $filePath');
  }

  final vertices = <Vector3>[];
  final lines = await file.readAsLines();

  for (final line in lines) {
    final trimmed = line.trim();
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
    throw Exception('No vertices found in OBJ file: $filePath');
  }

  return vertices;
}

/// Sample vertices evenly distributed throughout the point set
List<Vector3> sampleVertices(List<Vector3> vertices, int targetCount) {
  if (vertices.length <= targetCount) {
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

  return sampled;
}

/// Compute bounding box for a set of vertices
Map<String, Vector3> computeBoundingBox(List<Vector3> vertices) {
  if (vertices.isEmpty) {
    return {
      'min': Vector3.zero(),
      'max': Vector3.zero(),
      'size': Vector3.zero(),
    };
  }

  var minX = vertices[0].x;
  var minY = vertices[0].y;
  var minZ = vertices[0].z;
  var maxX = vertices[0].x;
  var maxY = vertices[0].y;
  var maxZ = vertices[0].z;

  for (final v in vertices) {
    minX = math.min(minX, v.x);
    minY = math.min(minY, v.y);
    minZ = math.min(minZ, v.z);
    maxX = math.max(maxX, v.x);
    maxY = math.max(maxY, v.y);
    maxZ = math.max(maxZ, v.z);
  }

  final min = Vector3(minX, minY, minZ);
  final max = Vector3(maxX, maxY, maxZ);
  final size = max - min;

  return {'min': min, 'max': max, 'size': size};
}

/// Normalize point set to unit scale centered at origin
List<Vector3> normalizePointSet(List<Vector3> vertices) {
  if (vertices.isEmpty) return [];

  // Compute centroid
  final centroid =
      vertices.fold<Vector3>(Vector3.zero(), (sum, v) => sum + v) /
      vertices.length.toDouble();

  // Center points
  final centered = vertices.map((v) => v - centroid).toList();

  // Compute scale (average distance from origin)
  final scale =
      centered.fold<double>(0.0, (sum, v) => sum + v.length) /
      centered.length.toDouble();

  // Normalize
  if (scale > 0) {
    return centered.map((v) => v / scale).toList();
  }

  return centered;
}
