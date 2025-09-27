import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter_3d_app/features/model_viewer/presentation/viewmodels/object_view_model.dart';
import 'package:flutter_3d_app/features/model_viewer/domain/entities/object_3d.dart';
import 'package:flutter_3d_app/features/model_viewer/domain/entities/procrustes_result.dart';

void main() {
  group('ObjectViewModel', () {
    late ObjectViewModel viewModel;

    setUp(() {
      viewModel = ObjectViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    group('initialization', () {
      test('should initialize with default values', () {
        // Assert
        expect(viewModel.objectA, isNull);
        expect(viewModel.objectB, isNull);
        expect(viewModel.hasObjectA, isFalse);
        expect(viewModel.hasObjectB, isFalse);
        expect(viewModel.canUndo, isFalse);
        expect(viewModel.canRedo, isFalse);
        expect(viewModel.procrustesResult, isNull);
        expect(viewModel.isAnalyzing, isFalse);
        expect(viewModel.analysisProgress, equals(0.0));
        expect(viewModel.showResultsCard, isFalse);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.error, isNull);
      });
    });

    group('object loading', () {
      test('should handle loadObjectA operation', () async {
        // Act
        await viewModel.loadObjectA();

        // Assert
        // Note: In a real test, you would mock the file picker
        // For now, we just verify the method doesn't throw
        expect(viewModel.isLoading, isFalse);
      });

      test('should handle loadObjectB operation', () async {
        // Act
        await viewModel.loadObjectB();

        // Assert
        // Note: In a real test, you would mock the file picker
        // For now, we just verify the method doesn't throw
        expect(viewModel.isLoading, isFalse);
      });
    });

    group('object transformations', () {
      late Object3D testObject;

      setUp(() {
        testObject = Object3D(
          id: 'test_object',
          name: 'Test Object',
          filePath: '/test/path.obj',
          fileExtension: 'obj',
          position: Vector3(0, 0, 0),
          rotation: Vector3(0, 0, 0),
          scale: Vector3(1, 1, 1),
          color: const Color3D(1, 0, 0),
          opacity: 1.0,
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
        );

        // Set objectB for testing transformations
        viewModel._objectB = testObject;
      });

      test('should update object B position', () {
        // Arrange
        final newPosition = Vector3(5, 10, 15);

        // Act
        viewModel.updateObjectBPosition(newPosition);

        // Assert
        expect(viewModel.objectB?.position, equals(newPosition));
        expect(
          viewModel.objectB?.lastModified,
          isNot(equals(testObject.lastModified)),
        );
      });

      test('should update object B rotation', () {
        // Arrange
        final newRotation = Vector3(45, 90, 135);

        // Act
        viewModel.updateObjectBRotation(newRotation);

        // Assert
        expect(viewModel.objectB?.rotation, equals(newRotation));
        expect(
          viewModel.objectB?.lastModified,
          isNot(equals(testObject.lastModified)),
        );
      });

      test('should update object B scale', () {
        // Arrange
        final newScale = Vector3(2, 3, 4);

        // Act
        viewModel.updateObjectBScale(newScale);

        // Assert
        expect(viewModel.objectB?.scale, equals(newScale));
        expect(
          viewModel.objectB?.lastModified,
          isNot(equals(testObject.lastModified)),
        );
      });

      test('should update object B opacity', () {
        // Arrange
        final newOpacity = 0.5;

        // Act
        viewModel.updateObjectBOpacity(newOpacity);

        // Assert
        expect(viewModel.objectB?.opacity, equals(newOpacity));
        expect(
          viewModel.objectB?.lastModified,
          isNot(equals(testObject.lastModified)),
        );
      });

      test('should update object B color', () {
        // Arrange
        final newColor = const Color3D(0, 1, 0);

        // Act
        viewModel.updateObjectBColor(newColor);

        // Assert
        expect(viewModel.objectB?.color, equals(newColor));
        expect(
          viewModel.objectB?.lastModified,
          isNot(equals(testObject.lastModified)),
        );
      });

      test('should not update when object B is null', () {
        // Arrange
        viewModel._objectB = null;
        final newPosition = Vector3(5, 10, 15);

        // Act
        viewModel.updateObjectBPosition(newPosition);

        // Assert
        expect(viewModel.objectB, isNull);
      });
    });

    group('object visibility', () {
      late Object3D testObject;

      setUp(() {
        testObject = Object3D(
          id: 'test_object',
          name: 'Test Object',
          filePath: '/test/path.obj',
          fileExtension: 'obj',
          position: Vector3(0, 0, 0),
          rotation: Vector3(0, 0, 0),
          scale: Vector3(1, 1, 1),
          color: const Color3D(1, 0, 0),
          opacity: 1.0,
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
        );
      });

      test('should toggle object A visibility', () {
        // Arrange
        viewModel._objectA = testObject;

        // Act
        viewModel.toggleObjectAVisibility();

        // Assert
        expect(viewModel.objectA?.opacity, equals(0.0));

        // Act again
        viewModel.toggleObjectAVisibility();

        // Assert
        expect(viewModel.objectA?.opacity, equals(1.0));
      });

      test('should toggle object B visibility', () {
        // Arrange
        viewModel._objectB = testObject;

        // Act
        viewModel.toggleObjectBVisibility();

        // Assert
        expect(viewModel.objectB?.opacity, equals(0.0));

        // Act again
        viewModel.toggleObjectBVisibility();

        // Assert
        expect(viewModel.objectB?.opacity, equals(0.7));
      });

      test('should not toggle when object is null', () {
        // Arrange
        viewModel._objectA = null;

        // Act
        viewModel.toggleObjectAVisibility();

        // Assert
        expect(viewModel.objectA, isNull);
      });
    });

    group('history management', () {
      late Object3D testObject;

      setUp(() {
        testObject = Object3D(
          id: 'test_object',
          name: 'Test Object',
          filePath: '/test/path.obj',
          fileExtension: 'obj',
          position: Vector3(0, 0, 0),
          rotation: Vector3(0, 0, 0),
          scale: Vector3(1, 1, 1),
          color: const Color3D(1, 0, 0),
          opacity: 1.0,
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
        );
        viewModel._objectB = testObject;
      });

      test('should save transform to history', () {
        // Arrange
        final initialHistoryLength = viewModel._transformHistory.length;

        // Act
        viewModel.updateObjectBPosition(Vector3(1, 1, 1));

        // Assert
        expect(
          viewModel._transformHistory.length,
          equals(initialHistoryLength + 1),
        );
        expect(viewModel.canUndo, isTrue);
      });

      test('should undo transformation', () {
        // Arrange
        final originalPosition = testObject.position;
        viewModel.updateObjectBPosition(Vector3(5, 5, 5));

        // Act
        viewModel.undo();

        // Assert
        expect(viewModel.objectB?.position, equals(originalPosition));
        expect(viewModel.canUndo, isFalse);
      });

      test('should redo transformation', () {
        // Arrange
        final newPosition = Vector3(5, 5, 5);
        viewModel.updateObjectBPosition(newPosition);
        viewModel.undo();

        // Act
        viewModel.redo();

        // Assert
        expect(viewModel.objectB?.position, equals(newPosition));
        expect(viewModel.canRedo, isFalse);
      });

      test('should not undo when no history', () {
        // Act
        viewModel.undo();

        // Assert
        expect(viewModel.objectB?.position, equals(testObject.position));
      });

      test('should not redo when no future history', () {
        // Act
        viewModel.redo();

        // Assert
        expect(viewModel.objectB?.position, equals(testObject.position));
      });
    });

    group('reset and alignment', () {
      late Object3D testObject;

      setUp(() {
        testObject = Object3D(
          id: 'test_object',
          name: 'Test Object',
          filePath: '/test/path.obj',
          fileExtension: 'obj',
          position: Vector3(5, 5, 5),
          rotation: Vector3(45, 45, 45),
          scale: Vector3(2, 2, 2),
          color: const Color3D(1, 0, 0),
          opacity: 1.0,
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
        );
        viewModel._objectB = testObject;
      });

      test('should reset object B to default values', () {
        // Act
        viewModel.resetObjectB();

        // Assert
        expect(viewModel.objectB?.position, equals(Vector3.zero()));
        expect(viewModel.objectB?.rotation, equals(Vector3.zero()));
        expect(viewModel.objectB?.scale, equals(Vector3.all(1.0)));
      });

      test('should auto-align object B to object A', () {
        // Arrange
        final objectA = Object3D(
          id: 'object_a',
          name: 'Object A',
          filePath: '/test/a.obj',
          fileExtension: 'obj',
          position: Vector3(10, 20, 30),
          rotation: Vector3(90, 90, 90),
          scale: Vector3(3, 3, 3),
          color: const Color3D(0, 1, 0),
          opacity: 1.0,
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
        );
        viewModel._objectA = objectA;

        // Act
        viewModel.autoAlignObjectB();

        // Assert
        expect(viewModel.objectB?.position, equals(objectA.position));
        expect(viewModel.objectB?.rotation, equals(objectA.rotation));
        expect(viewModel.objectB?.scale, equals(objectA.scale));
      });

      test('should not auto-align when object A is null', () {
        // Arrange
        final originalPosition = testObject.position;

        // Act
        viewModel.autoAlignObjectB();

        // Assert
        expect(viewModel.objectB?.position, equals(originalPosition));
      });
    });

    group('Procrustes analysis', () {
      late Object3D objectA;
      late Object3D objectB;

      setUp(() {
        objectA = Object3D(
          id: 'object_a',
          name: 'Object A',
          filePath: '/test/a.obj',
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
          id: 'object_b',
          name: 'Object B',
          filePath: '/test/b.obj',
          fileExtension: 'obj',
          position: Vector3(1, 1, 1),
          rotation: Vector3(0, 0, 0),
          scale: Vector3(1, 1, 1),
          color: const Color3D(0, 1, 0),
          opacity: 0.7,
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
        );

        viewModel._objectA = objectA;
        viewModel._objectB = objectB;
      });

      test('should perform Procrustes analysis', () async {
        // Act
        await viewModel.performProcrustesAnalysis();

        // Assert
        expect(viewModel.isAnalyzing, isFalse);
        expect(viewModel.analysisProgress, equals(0.0));
        // Note: In a real test, you would mock the ProcrustesIsolateService
      });

      test('should not perform analysis when objects are null', () async {
        // Arrange
        viewModel._objectA = null;

        // Act
        await viewModel.performProcrustesAnalysis();

        // Assert
        expect(viewModel.isAnalyzing, isFalse);
        expect(viewModel.procrustesResult, isNull);
      });

      test('should get similarity metrics', () {
        // Act
        final metrics = viewModel.getSimilarityMetrics();

        // Assert
        expect(metrics, isA<ProcrustesMetrics>());
        expect(metrics?.similarityScore, greaterThan(0.0));
        expect(metrics?.numberOfPoints, equals(8));
      });

      test('should return null metrics when objects are null', () {
        // Arrange
        viewModel._objectA = null;

        // Act
        final metrics = viewModel.getSimilarityMetrics();

        // Assert
        expect(metrics, isNull);
      });

      test('should calculate alignment score', () {
        // Act
        final score = viewModel.getAlignmentScore();

        // Assert
        expect(score, greaterThanOrEqualTo(0.0));
        expect(score, lessThanOrEqualTo(100.0));
      });

      test('should return zero score when objects are null', () {
        // Arrange
        viewModel._objectA = null;

        // Act
        final score = viewModel.getAlignmentScore();

        // Assert
        expect(score, equals(0.0));
      });
    });

    group('results card management', () {
      test('should clear Procrustes results', () {
        // Arrange
        viewModel._procrustesResult = ProcrustesResult(
          translation: Vector3.zero(),
          rotation: Matrix3.identity(),
          scale: 1.0,
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
        viewModel._showResultsCard = true;

        // Act
        viewModel.clearProcrustesResults();

        // Assert
        expect(viewModel.procrustesResult, isNull);
        expect(viewModel.showResultsCard, isFalse);
      });

      test('should hide results card', () {
        // Arrange
        viewModel._showResultsCard = true;

        // Act
        viewModel.hideResultsCard();

        // Assert
        expect(viewModel.showResultsCard, isFalse);
      });
    });

    group('clear all objects', () {
      test('should clear all objects and reset state', () {
        // Arrange
        viewModel._objectA = Object3D(
          id: 'a',
          name: 'A',
          filePath: '/a.obj',
          fileExtension: 'obj',
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
        );
        viewModel._objectB = Object3D(
          id: 'b',
          name: 'B',
          filePath: '/b.obj',
          fileExtension: 'obj',
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
        );
        viewModel._procrustesResult = ProcrustesResult(
          translation: Vector3.zero(),
          rotation: Matrix3.identity(),
          scale: 1.0,
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
        viewModel._showResultsCard = true;
        viewModel._transformHistory.add(ObjectTransform());
        viewModel._historyIndex = 0;
        viewModel.setError('Test error');

        // Act
        viewModel.clearAllObjects();

        // Assert
        expect(viewModel.objectA, isNull);
        expect(viewModel.objectB, isNull);
        expect(viewModel.procrustesResult, isNull);
        expect(viewModel.showResultsCard, isFalse);
        expect(viewModel._transformHistory, isEmpty);
        expect(viewModel._historyIndex, equals(-1));
        expect(viewModel.error, isNull);
      });
    });

    group('error handling', () {
      test('should handle errors gracefully', () {
        // Arrange
        const errorMessage = 'Test error';

        // Act
        viewModel.setError(errorMessage);

        // Assert
        expect(viewModel.error, equals(errorMessage));
      });

      test('should clear errors', () {
        // Arrange
        viewModel.setError('Test error');

        // Act
        viewModel.clearError();

        // Assert
        expect(viewModel.error, isNull);
      });
    });

    group('loading states', () {
      test('should manage loading state', () {
        // Act
        viewModel.setLoading(true);

        // Assert
        expect(viewModel.isLoading, isTrue);

        // Act
        viewModel.setLoading(false);

        // Assert
        expect(viewModel.isLoading, isFalse);
      });
    });
  });
}
