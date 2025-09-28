import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter_3d_app/features/model_viewer/domain/services/procrustes_analysis.dart';

void main() {
  group('ProcrustesAnalysis - Simple Tests', () {
    test('should align two identical point sets perfectly', () {
      // Arrange
      final identicalPoints = [
        Vector3(1, 2, 3),
        Vector3(4, 5, 6),
        Vector3(7, 8, 9),
      ];

      // Act
      final result = ProcrustesAnalysis.align(identicalPoints, identicalPoints);

      // Assert
      expect(result.similarityScore, greaterThan(99.0));
      expect(result.minimumDistance, lessThan(0.001));
      expect(result.standardDeviation, lessThan(0.001));
      expect(result.rootMeanSquareError, lessThan(0.001));
    });

    test('should align translated point sets', () {
      // Arrange
      final pointsA = [
        Vector3(0, 0, 0),
        Vector3(1, 0, 0),
        Vector3(0, 1, 0),
        Vector3(0, 0, 1),
      ];
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

    test('should throw error for mismatched point counts', () {
      // Arrange
      final pointsA = [Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0)];
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
        () => ProcrustesAnalysis.align(insufficientPoints, insufficientPoints),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
