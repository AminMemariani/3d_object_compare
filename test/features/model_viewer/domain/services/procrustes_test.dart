import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter_3d_app/features/model_viewer/domain/services/procrustes.dart';
import 'package:flutter_3d_app/features/model_viewer/domain/entities/object_3d.dart';
import 'package:flutter_3d_app/features/model_viewer/domain/entities/procrustes_result.dart';

void main() {
  group('Procrustes', () {
    late Object3D objectA;
    late Object3D objectB;

    setUp(() {
      objectA = Object3D(
        id: 'test_object_a',
        name: 'Test Object A',
        filePath: '/test/path/a.obj',
        fileExtension: 'obj',
        position: Vector3(0, 0, 0),
        rotation: Vector3(0, 0, 0),
        scale: Vector3(1, 1, 1),
        color: const Color3D(1, 0, 0),
        opacity: 1.0,
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
      );

      objectB = Object3D(
        id: 'test_object_b',
        name: 'Test Object B',
        filePath: '/test/path/b.obj',
        fileExtension: 'obj',
        position: Vector3(1, 1, 1),
        rotation: Vector3(0, 0, 0),
        scale: Vector3(1, 1, 1),
        color: const Color3D(0, 1, 0),
        opacity: 0.7,
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
      );
    });

    group('align', () {
      test('should align two objects and return valid result', () {
        // Act
        final result = Procrustes.align(objectA, objectB);

        // Assert
        expect(result, isA<ProcrustesResult>());
        expect(result.similarityScore, greaterThan(0.0));
        expect(result.similarityScore, lessThanOrEqualTo(100.0));
        expect(result.numberOfPoints, equals(8)); // Default cube has 8 vertices
        expect(result.translation, isA<Vector3>());
        expect(result.rotation, isA<Matrix3>());
        expect(result.scale, greaterThan(0.0));
      });

      test('should handle identical objects', () {
        // Act
        final result = Procrustes.align(objectA, objectA);

        // Assert
        expect(result.similarityScore, greaterThan(95.0));
        expect(result.minimumDistance, lessThan(0.1));
      });

      test('should handle objects with different scales', () {
        // Arrange
        final scaledObjectB = objectB.copyWith(scale: Vector3(2, 2, 2));

        // Act
        final result = Procrustes.align(objectA, scaledObjectB);

        // Assert
        expect(result, isA<ProcrustesResult>());
        expect(result.similarityScore, greaterThan(0.0));
      });

      test('should handle objects with different rotations', () {
        // Arrange
        final rotatedObjectB = objectB.copyWith(rotation: Vector3(45, 45, 45));

        // Act
        final result = Procrustes.align(objectA, rotatedObjectB);

        // Assert
        expect(result, isA<ProcrustesResult>());
        expect(result.similarityScore, greaterThan(0.0));
      });

      test('should handle objects with different positions', () {
        // Arrange
        final translatedObjectB = objectB.copyWith(
          position: Vector3(10, 10, 10),
        );

        // Act
        final result = Procrustes.align(objectA, translatedObjectB);

        // Assert
        expect(result, isA<ProcrustesResult>());
        expect(result.similarityScore, greaterThan(0.0));
      });
    });

    group('alignPoints', () {
      test('should align two point sets', () {
        // Arrange
        final pointsA = [
          Vector3(0, 0, 0),
          Vector3(1, 0, 0),
          Vector3(0, 1, 0),
          Vector3(0, 0, 1),
        ];
        final pointsB = [
          Vector3(1, 1, 1),
          Vector3(2, 1, 1),
          Vector3(1, 2, 1),
          Vector3(1, 1, 2),
        ];

        // Act
        final result = Procrustes.alignPoints(pointsA, pointsB);

        // Assert
        expect(result, isA<ProcrustesResult>());
        expect(result.similarityScore, greaterThan(0.0));
        expect(result.numberOfPoints, equals(4));
      });

      test('should handle identical point sets', () {
        // Arrange
        final points = [Vector3(1, 2, 3), Vector3(4, 5, 6), Vector3(7, 8, 9)];

        // Act
        final result = Procrustes.alignPoints(points, points);

        // Assert
        expect(result.similarityScore, greaterThan(95.0));
        expect(result.minimumDistance, lessThan(0.1));
      });
    });

    group('applyTransformation', () {
      test('should apply transformation to object', () {
        // Arrange
        final result = ProcrustesResult(
          translation: Vector3(5, 5, 5),
          rotation: Matrix3.identity(),
          scale: 2.0,
          metrics: ProcrustesMetrics(
            similarityScore: 90.0,
            minimumDistance: 0.1,
            standardDeviation: 0.05,
            rootMeanSquareError: 0.15,
            meanDistance: 0.1,
            maxDistance: 0.2,
            numberOfPoints: 8,
          ),
          numberOfPoints: 8,
        );

        // Act
        final transformedObject = Procrustes.applyTransformation(
          objectA,
          result,
        );

        // Assert
        expect(transformedObject, isA<Object3D>());
        expect(transformedObject.id, equals(objectA.id));
        expect(transformedObject.name, equals(objectA.name));
        expect(
          transformedObject.lastModified,
          isNot(equals(objectA.lastModified)),
        );
      });

      test('should preserve object properties', () {
        // Arrange
        final result = ProcrustesResult(
          translation: Vector3.zero(),
          rotation: Matrix3.identity(),
          scale: 1.0,
          metrics: ProcrustesMetrics(
            similarityScore: 100.0,
            minimumDistance: 0.0,
            standardDeviation: 0.0,
            rootMeanSquareError: 0.0,
            meanDistance: 0.0,
            maxDistance: 0.0,
            numberOfPoints: 8,
          ),
          numberOfPoints: 8,
        );

        // Act
        final transformedObject = Procrustes.applyTransformation(
          objectA,
          result,
        );

        // Assert
        expect(transformedObject.id, equals(objectA.id));
        expect(transformedObject.name, equals(objectA.name));
        expect(transformedObject.filePath, equals(objectA.filePath));
        expect(transformedObject.fileExtension, equals(objectA.fileExtension));
        expect(transformedObject.color, equals(objectA.color));
        expect(transformedObject.opacity, equals(objectA.opacity));
      });
    });

    group('computeSimilarity', () {
      test('should compute similarity between two objects', () {
        // Act
        final metrics = Procrustes.computeSimilarity(objectA, objectB);

        // Assert
        expect(metrics, isA<ProcrustesMetrics>());
        expect(metrics.similarityScore, greaterThan(0.0));
        expect(metrics.similarityScore, lessThanOrEqualTo(100.0));
        expect(metrics.numberOfPoints, equals(8));
        expect(metrics.minimumDistance, greaterThanOrEqualTo(0.0));
        expect(metrics.standardDeviation, greaterThanOrEqualTo(0.0));
        expect(metrics.rootMeanSquareError, greaterThanOrEqualTo(0.0));
      });

      test('should return high similarity for identical objects', () {
        // Act
        final metrics = Procrustes.computeSimilarity(objectA, objectA);

        // Assert
        expect(metrics.similarityScore, greaterThan(95.0));
        expect(metrics.minimumDistance, lessThan(0.1));
      });

      test('should return quality description', () {
        // Act
        final metrics = Procrustes.computeSimilarity(objectA, objectB);

        // Assert
        expect(metrics.qualityDescription, isA<String>());
        expect(metrics.qualityDescription, isNotEmpty);
        expect(metrics.alignmentStatus, isA<String>());
        expect(metrics.alignmentStatus, isNotEmpty);
      });
    });

    group('_generateObjectPoints', () {
      test('should generate points for object', () {
        // Act
        final points = Procrustes._generateObjectPoints(objectA);

        // Assert
        expect(points, isA<List<Vector3>>());
        expect(points.length, equals(8)); // Cube has 8 vertices
        expect(points.every((p) => p is Vector3), isTrue);
      });

      test('should apply object transformations', () {
        // Arrange
        final transformedObject = objectA.copyWith(
          position: Vector3(10, 20, 30),
          scale: Vector3(2, 2, 2),
        );

        // Act
        final points = Procrustes._generateObjectPoints(transformedObject);

        // Assert
        expect(points.length, equals(8));
        // Points should be transformed according to object properties
        expect(points.every((p) => p is Vector3), isTrue);
      });
    });

    group('_eulerToMatrix', () {
      test('should convert zero rotation to identity matrix', () {
        // Arrange
        final zeroRotation = Vector3(0, 0, 0);

        // Act
        final matrix = Procrustes._eulerToMatrix(zeroRotation);

        // Assert
        expect(matrix.entry(0, 0), closeTo(1.0, 0.001));
        expect(matrix.entry(1, 1), closeTo(1.0, 0.001));
        expect(matrix.entry(2, 2), closeTo(1.0, 0.001));
        expect(matrix.determinant(), closeTo(1.0, 0.001));
      });

      test('should convert 90-degree rotation', () {
        // Arrange
        final rotation = Vector3(0, 90, 0);

        // Act
        final matrix = Procrustes._eulerToMatrix(rotation);

        // Assert
        expect(matrix.determinant(), closeTo(1.0, 0.001));
      });
    });

    group('_matrixToEuler', () {
      test('should convert identity matrix to zero rotation', () {
        // Arrange
        final identityMatrix = Matrix3.identity();

        // Act
        final euler = Procrustes._matrixToEuler(identityMatrix);

        // Assert
        expect(euler.x, closeTo(0.0, 0.1));
        expect(euler.y, closeTo(0.0, 0.1));
        expect(euler.z, closeTo(0.0, 0.1));
      });

      test('should handle rotation matrix', () {
        // Arrange
        final rotationMatrix = Matrix3.rotationY(radians(45));

        // Act
        final euler = Procrustes._matrixToEuler(rotationMatrix);

        // Assert
        expect(euler, isA<Vector3>());
      });
    });

    group('_rotateVector', () {
      test('should rotate vector by Euler angles', () {
        // Arrange
        final vector = Vector3(1, 0, 0);
        final rotation = Vector3(0, 90, 0);

        // Act
        final rotatedVector = Procrustes._rotateVector(vector, rotation);

        // Assert
        expect(rotatedVector, isA<Vector3>());
        expect(rotatedVector.length, closeTo(vector.length, 0.001));
      });

      test('should preserve vector magnitude', () {
        // Arrange
        final vector = Vector3(3, 4, 5);
        final rotation = Vector3(30, 45, 60);

        // Act
        final rotatedVector = Procrustes._rotateVector(vector, rotation);

        // Assert
        expect(rotatedVector.length, closeTo(vector.length, 0.001));
      });
    });

    group('edge cases', () {
      test('should handle objects with extreme values', () {
        // Arrange
        final extremeObject = Object3D(
          id: 'extreme',
          name: 'Extreme Object',
          filePath: '/test/extreme.obj',
          fileExtension: 'obj',
          position: Vector3(1e6, 1e6, 1e6),
          rotation: Vector3(360, 360, 360),
          scale: Vector3(1e-6, 1e-6, 1e-6),
          color: const Color3D(0, 0, 0),
          opacity: 0.0,
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
        );

        // Act
        final result = Procrustes.align(objectA, extremeObject);

        // Assert
        expect(result, isA<ProcrustesResult>());
        expect(result.similarityScore, greaterThanOrEqualTo(0.0));
      });

      test('should handle objects with negative scales', () {
        // Arrange
        final negativeScaleObject = objectB.copyWith(
          scale: Vector3(-1, -1, -1),
        );

        // Act
        final result = Procrustes.align(objectA, negativeScaleObject);

        // Assert
        expect(result, isA<ProcrustesResult>());
        expect(result.similarityScore, greaterThanOrEqualTo(0.0));
      });
    });

    group('performance', () {
      test('should complete alignment within reasonable time', () {
        // Arrange
        final complexObjectA = objectA.copyWith(
          position: Vector3(100, 200, 300),
          rotation: Vector3(45, 90, 135),
          scale: Vector3(2, 3, 4),
        );
        final complexObjectB = objectB.copyWith(
          position: Vector3(150, 250, 350),
          rotation: Vector3(60, 120, 180),
          scale: Vector3(1.5, 2.5, 3.5),
        );

        // Act
        final stopwatch = Stopwatch()..start();
        final result = Procrustes.align(complexObjectA, complexObjectB);
        stopwatch.stop();

        // Assert
        expect(result, isA<ProcrustesResult>());
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(1000),
        ); // Should complete within 1 second
      });
    });
  });
}
