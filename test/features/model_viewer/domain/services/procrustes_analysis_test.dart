import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter_3d_app/features/model_viewer/domain/services/procrustes_analysis.dart';
import 'package:flutter_3d_app/features/model_viewer/domain/entities/procrustes_result.dart';

void main() {
  group('ProcrustesAnalysis', () {
    late List<Vector3> pointsA;
    late List<Vector3> pointsB;

    setUp(() {
      // Create test point sets
      pointsA = [
        Vector3(0, 0, 0),
        Vector3(1, 0, 0),
        Vector3(0, 1, 0),
        Vector3(0, 0, 1),
        Vector3(1, 1, 1),
      ];

      pointsB = [
        Vector3(2, 0, 0),
        Vector3(3, 0, 0),
        Vector3(2, 1, 0),
        Vector3(2, 0, 1),
        Vector3(3, 1, 1),
      ];
    });

    group('align', () {
      test('should align two identical point sets perfectly', () {
        // Arrange
        final identicalPoints = [
          Vector3(1, 2, 3),
          Vector3(4, 5, 6),
          Vector3(7, 8, 9),
        ];

        // Act
        final result = ProcrustesAnalysis.align(
          identicalPoints,
          identicalPoints,
        );

        // Assert
        expect(result.similarityScore, greaterThan(99.0));
        expect(result.minimumDistance, lessThan(0.001));
        expect(result.standardDeviation, lessThan(0.001));
        expect(result.rootMeanSquareError, lessThan(0.001));
      });

      test('should align translated point sets', () {
        // Arrange
        final translation = Vector3(5, 10, 15);
        final translatedPoints = pointsA.map((p) => p + translation).toList();

        // Act
        final result = ProcrustesAnalysis.align(pointsA, translatedPoints);

        // Assert
        expect(result.similarityScore, greaterThan(95.0));
        expect(result.translation.x, closeTo(-translation.x, 0.1));
        expect(result.translation.y, closeTo(-translation.y, 0.1));
        expect(result.translation.z, closeTo(-translation.z, 0.1));
      });

      test('should align scaled point sets', () {
        // Arrange
        final scale = 2.5;
        final scaledPoints = pointsA.map((p) => p * scale).toList();

        // Act
        final result = ProcrustesAnalysis.align(pointsA, scaledPoints);

        // Assert
        expect(result.similarityScore, greaterThan(95.0));
        expect(result.scale, closeTo(1.0 / scale, 0.1));
      });

      test('should align rotated point sets', () {
        // Arrange
        final rotationMatrix = Matrix3.rotationY(radians(45));
        final rotatedPoints = pointsA.map((p) => rotationMatrix * p).toList();

        // Act
        final result = ProcrustesAnalysis.align(pointsA, rotatedPoints);

        // Assert
        expect(result.similarityScore, greaterThan(90.0));
        expect(result.rotation.determinant(), closeTo(1.0, 0.1));
      });

      test('should handle complex transformations', () {
        // Arrange
        final translation = Vector3(3, 4, 5);
        final scale = 1.5;
        final rotationMatrix = Matrix3.rotationZ(radians(30));

        final transformedPoints = pointsA.map((p) {
          return translation + (rotationMatrix * p) * scale;
        }).toList();

        // Act
        final result = ProcrustesAnalysis.align(pointsA, transformedPoints);

        // Assert
        expect(result.similarityScore, greaterThan(85.0));
        expect(result.scale, closeTo(1.0 / scale, 0.2));
      });

      test('should throw error for mismatched point counts', () {
        // Arrange
        final mismatchedPoints = [Vector3(1, 2, 3)];

        // Act & Assert
        expect(
          () => ProcrustesAnalysis.align(pointsA, mismatchedPoints),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw error for insufficient points', () {
        // Arrange
        final insufficientPoints = [Vector3(1, 2, 3), Vector3(4, 5, 6)];

        // Act & Assert
        expect(
          () =>
              ProcrustesAnalysis.align(insufficientPoints, insufficientPoints),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should handle empty point sets', () {
        // Act & Assert
        expect(
          () => ProcrustesAnalysis.align([], []),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('centroid calculation', () {
      test('should calculate correct centroid', () {
        // Arrange
        final points = [
          Vector3(0, 0, 0),
          Vector3(2, 0, 0),
          Vector3(0, 2, 0),
          Vector3(0, 0, 2),
        ];

        // Act
        final centroid = ProcrustesAnalysis._computeCentroid(points);

        // Assert
        expect(centroid.x, closeTo(0.5, 0.001));
        expect(centroid.y, closeTo(0.5, 0.001));
        expect(centroid.z, closeTo(0.5, 0.001));
      });

      test('should handle single point', () {
        // Arrange
        final points = [Vector3(1, 2, 3)];

        // Act
        final centroid = ProcrustesAnalysis._computeCentroid(points);

        // Assert
        expect(centroid.x, equals(1.0));
        expect(centroid.y, equals(2.0));
        expect(centroid.z, equals(3.0));
      });
    });

    group('scale calculation', () {
      test('should calculate correct scale factor', () {
        // Arrange
        final pointsA = [Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0)];
        final pointsB = [Vector3(0, 0, 0), Vector3(2, 0, 0), Vector3(0, 2, 0)];

        // Act
        final scale = ProcrustesAnalysis._computeScale(pointsA, pointsB);

        // Assert
        expect(scale, closeTo(0.5, 0.1));
      });

      test('should handle zero scale', () {
        // Arrange
        final pointsA = [Vector3(0, 0, 0), Vector3(1, 0, 0)];
        final pointsB = [Vector3(0, 0, 0), Vector3(0, 0, 0)];

        // Act
        final scale = ProcrustesAnalysis._computeScale(pointsA, pointsB);

        // Assert
        expect(scale, equals(1.0));
      });
    });

    group('rotation calculation', () {
      test('should calculate identity rotation for identical points', () {
        // Arrange
        final points = [Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1)];

        // Act
        final rotation = ProcrustesAnalysis._computeOptimalRotation(
          points,
          points,
        );

        // Assert
        expect(rotation.determinant(), closeTo(1.0, 0.1));
        expect(rotation.entry(0, 0), closeTo(1.0, 0.1));
        expect(rotation.entry(1, 1), closeTo(1.0, 0.1));
        expect(rotation.entry(2, 2), closeTo(1.0, 0.1));
      });

      test('should calculate 90-degree rotation', () {
        // Arrange
        final pointsA = [Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1)];
        final pointsB = [Vector3(0, 1, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1)];

        // Act
        final rotation = ProcrustesAnalysis._computeOptimalRotation(
          pointsA,
          pointsB,
        );

        // Assert
        expect(rotation.determinant(), closeTo(1.0, 0.1));
      });
    });

    group('metrics calculation', () {
      test('should calculate correct similarity metrics', () {
        // Arrange
        final pointsA = [Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0)];
        final pointsB = [
          Vector3(0.1, 0.1, 0.1),
          Vector3(1.1, 0.1, 0.1),
          Vector3(0.1, 1.1, 0.1),
        ];

        // Act
        final metrics = ProcrustesAnalysis._computeMetrics(pointsA, pointsB);

        // Assert
        expect(metrics.similarityScore, greaterThan(0.0));
        expect(metrics.similarityScore, lessThan(100.0));
        expect(metrics.minimumDistance, greaterThan(0.0));
        expect(metrics.standardDeviation, greaterThan(0.0));
        expect(metrics.rootMeanSquareError, greaterThan(0.0));
        expect(metrics.numberOfPoints, equals(3));
      });

      test('should handle perfect alignment', () {
        // Arrange
        final points = [Vector3(1, 2, 3), Vector3(4, 5, 6)];

        // Act
        final metrics = ProcrustesAnalysis._computeMetrics(points, points);

        // Assert
        expect(metrics.similarityScore, closeTo(100.0, 0.1));
        expect(metrics.minimumDistance, closeTo(0.0, 0.001));
        expect(metrics.standardDeviation, closeTo(0.0, 0.001));
        expect(metrics.rootMeanSquareError, closeTo(0.0, 0.001));
      });
    });

    group('SVD calculation', () {
      test('should handle identity matrix', () {
        // Arrange
        final identity = Matrix3.identity();

        // Act
        final svd = ProcrustesAnalysis._computeSVD(identity);

        // Assert
        expect(svd.S.x, closeTo(1.0, 0.1));
        expect(svd.S.y, closeTo(1.0, 0.1));
        expect(svd.S.z, closeTo(1.0, 0.1));
      });

      test('should handle zero matrix', () {
        // Arrange
        final zeroMatrix = Matrix3.zero();

        // Act
        final svd = ProcrustesAnalysis._computeSVD(zeroMatrix);

        // Assert
        expect(svd.S.x, closeTo(0.0, 0.1));
        expect(svd.S.y, closeTo(0.0, 0.1));
        expect(svd.S.z, closeTo(0.0, 0.1));
      });
    });

    group('edge cases', () {
      test('should handle collinear points', () {
        // Arrange
        final collinearPoints = [
          Vector3(0, 0, 0),
          Vector3(1, 0, 0),
          Vector3(2, 0, 0),
          Vector3(3, 0, 0),
        ];

        // Act
        final result = ProcrustesAnalysis.align(
          collinearPoints,
          collinearPoints,
        );

        // Assert
        expect(result.similarityScore, greaterThan(95.0));
      });

      test('should handle coplanar points', () {
        // Arrange
        final coplanarPoints = [
          Vector3(0, 0, 0),
          Vector3(1, 0, 0),
          Vector3(0, 1, 0),
          Vector3(1, 1, 0),
        ];

        // Act
        final result = ProcrustesAnalysis.align(coplanarPoints, coplanarPoints);

        // Assert
        expect(result.similarityScore, greaterThan(95.0));
      });

      test('should handle very small coordinates', () {
        // Arrange
        final smallPoints = [
          Vector3(1e-10, 1e-10, 1e-10),
          Vector3(2e-10, 1e-10, 1e-10),
          Vector3(1e-10, 2e-10, 1e-10),
        ];

        // Act
        final result = ProcrustesAnalysis.align(smallPoints, smallPoints);

        // Assert
        expect(result.similarityScore, greaterThan(90.0));
      });

      test('should handle very large coordinates', () {
        // Arrange
        final largePoints = [
          Vector3(1e10, 1e10, 1e10),
          Vector3(2e10, 1e10, 1e10),
          Vector3(1e10, 2e10, 1e10),
        ];

        // Act
        final result = ProcrustesAnalysis.align(largePoints, largePoints);

        // Assert
        expect(result.similarityScore, greaterThan(90.0));
      });
    });

    group('performance', () {
      test('should handle large point sets efficiently', () {
        // Arrange
        final largePointSet = List.generate(1000, (i) {
          return Vector3(i.toDouble(), (i * 2).toDouble(), (i * 3).toDouble());
        });

        // Act
        final stopwatch = Stopwatch()..start();
        final result = ProcrustesAnalysis.align(largePointSet, largePointSet);
        stopwatch.stop();

        // Assert
        expect(result.similarityScore, greaterThan(99.0));
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(5000),
        ); // Should complete within 5 seconds
      });
    });
  });
}
