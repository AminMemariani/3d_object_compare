import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_3d_app/features/model_viewer/domain/services/extensions/extension_registry.dart';
import 'package:flutter_3d_app/features/model_viewer/domain/services/interfaces/procrustes_service_interface.dart';
import 'package:flutter_3d_app/test/features/model_viewer/domain/services/mocks/mock_procrustes_service.dart';

void main() {
  group('ExtensionRegistry', () {
    setUp(() {
      ExtensionRegistry.clearAllExtensions();
    });

    tearDown(() {
      ExtensionRegistry.clearAllExtensions();
    });

    group('extension registration', () {
      test('should register extension with metadata', () {
        // Arrange
        final service = MockProcrustesService();
        const name = 'test_extension';
        const version = '1.0.0';
        const description = 'Test extension';

        // Act
        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          name,
          service,
          version: version,
          description: description,
        );

        // Assert
        expect(ExtensionRegistry.isExtensionRegistered(name), isTrue);
        final metadata = ExtensionRegistry.getExtensionMetadata(name);
        expect(metadata, isNotNull);
        expect(metadata!.name, equals(name));
        expect(metadata.version, equals(version));
        expect(metadata.description, equals(description));
      });

      test('should register extension with dependencies', () {
        // Arrange
        final service = MockProcrustesService();
        const name = 'dependent_extension';
        const dependencies = ['procrustes_service', 'export_service'];

        // Act
        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          name,
          service,
          dependencies: dependencies,
        );

        // Assert
        final metadata = ExtensionRegistry.getExtensionMetadata(name);
        expect(metadata, isNotNull);
        expect(metadata!.dependencies, equals(dependencies));
      });

      test('should register multiple extensions', () {
        // Arrange
        final service1 = MockProcrustesService();
        final service2 = MockProcrustesService();

        // Act
        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          'extension1',
          service1,
        );
        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          'extension2',
          service2,
        );

        // Assert
        expect(ExtensionRegistry.isExtensionRegistered('extension1'), isTrue);
        expect(ExtensionRegistry.isExtensionRegistered('extension2'), isTrue);
        expect(ExtensionRegistry.getAllExtensions().length, equals(2));
      });
    });

    group('extension retrieval', () {
      test('should get registered extension', () {
        // Arrange
        final service = MockProcrustesService();
        const name = 'test_extension';

        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          name,
          service,
        );

        // Act
        final retrievedService =
            ExtensionRegistry.getExtension<ProcrustesServiceInterface>(name);

        // Assert
        expect(retrievedService, isNotNull);
        expect(retrievedService, equals(service));
      });

      test('should return null for unregistered extension', () {
        // Act
        final service =
            ExtensionRegistry.getExtension<ProcrustesServiceInterface>(
              'nonexistent',
            );

        // Assert
        expect(service, isNull);
      });

      test('should get extensions by type', () {
        // Arrange
        final service1 = MockProcrustesService();
        final service2 = MockProcrustesService();

        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          'service1',
          service1,
        );
        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          'service2',
          service2,
        );

        // Act
        final services =
            ExtensionRegistry.getExtensionsByType<ProcrustesServiceInterface>();

        // Assert
        expect(services.length, equals(2));
        expect(services, contains(service1));
        expect(services, contains(service2));
      });

      test('should get extensions implementing interface', () {
        // Arrange
        final service1 = MockProcrustesService();
        final service2 = MockProcrustesService();

        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          'service1',
          service1,
        );
        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          'service2',
          service2,
        );

        // Act
        final services =
            ExtensionRegistry.getExtensionsImplementing<
              ProcrustesServiceInterface
            >();

        // Assert
        expect(services.length, equals(2));
        expect(services, contains(service1));
        expect(services, contains(service2));
      });
    });

    group('extension metadata', () {
      test('should get all metadata', () {
        // Arrange
        final service1 = MockProcrustesService();
        final service2 = MockProcrustesService();

        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          'service1',
          service1,
          version: '1.0.0',
          description: 'Service 1',
        );
        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          'service2',
          service2,
          version: '2.0.0',
          description: 'Service 2',
        );

        // Act
        final allMetadata = ExtensionRegistry.getAllMetadata();

        // Assert
        expect(allMetadata.length, equals(2));
        expect(allMetadata.containsKey('service1'), isTrue);
        expect(allMetadata.containsKey('service2'), isTrue);
        expect(allMetadata['service1']!.version, equals('1.0.0'));
        expect(allMetadata['service2']!.version, equals('2.0.0'));
      });

      test('should return null for nonexistent metadata', () {
        // Act
        final metadata = ExtensionRegistry.getExtensionMetadata('nonexistent');

        // Assert
        expect(metadata, isNull);
      });
    });

    group('dependency validation', () {
      test('should validate dependencies when all are present', () {
        // Arrange
        final dependencyService = MockProcrustesService();
        final dependentService = MockProcrustesService();

        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          'dependency',
          dependencyService,
        );
        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          'dependent',
          dependentService,
          dependencies: ['dependency'],
        );

        // Act
        final isValid = ExtensionRegistry.validateDependencies('dependent');

        // Assert
        expect(isValid, isTrue);
      });

      test('should fail validation when dependencies are missing', () {
        // Arrange
        final dependentService = MockProcrustesService();

        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          'dependent',
          dependentService,
          dependencies: ['missing_dependency'],
        );

        // Act
        final isValid = ExtensionRegistry.validateDependencies('dependent');

        // Assert
        expect(isValid, isFalse);
      });

      test('should return false for nonexistent extension', () {
        // Act
        final isValid = ExtensionRegistry.validateDependencies('nonexistent');

        // Assert
        expect(isValid, isFalse);
      });
    });

    group('extension unregistration', () {
      test('should unregister extension', () {
        // Arrange
        final service = MockProcrustesService();
        const name = 'test_extension';

        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          name,
          service,
        );
        expect(ExtensionRegistry.isExtensionRegistered(name), isTrue);

        // Act
        ExtensionRegistry.unregisterExtension(name);

        // Assert
        expect(ExtensionRegistry.isExtensionRegistered(name), isFalse);
        expect(
          ExtensionRegistry.getExtension<ProcrustesServiceInterface>(name),
          isNull,
        );
        expect(ExtensionRegistry.getExtensionMetadata(name), isNull);
      });

      test('should clear all extensions', () {
        // Arrange
        final service1 = MockProcrustesService();
        final service2 = MockProcrustesService();

        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          'service1',
          service1,
        );
        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          'service2',
          service2,
        );

        expect(ExtensionRegistry.getAllExtensions().length, equals(2));

        // Act
        ExtensionRegistry.clearAllExtensions();

        // Assert
        expect(ExtensionRegistry.getAllExtensions().isEmpty, isTrue);
        expect(ExtensionRegistry.getAllMetadata().isEmpty, isTrue);
      });
    });

    group('edge cases', () {
      test('should handle duplicate registration', () {
        // Arrange
        final service1 = MockProcrustesService();
        final service2 = MockProcrustesService();
        const name = 'duplicate_extension';

        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          name,
          service1,
        );

        // Act
        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          name,
          service2,
        );

        // Assert
        final retrievedService =
            ExtensionRegistry.getExtension<ProcrustesServiceInterface>(name);
        expect(retrievedService, equals(service2));
      });

      test('should handle empty extension name', () {
        // Arrange
        final service = MockProcrustesService();

        // Act & Assert
        expect(
          () => ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
            '',
            service,
          ),
          returnsNormally,
        );
      });

      test('should handle null dependencies', () {
        // Arrange
        final service = MockProcrustesService();

        // Act
        ExtensionRegistry.registerExtension<ProcrustesServiceInterface>(
          'test',
          service,
          dependencies: null,
        );

        // Assert
        final metadata = ExtensionRegistry.getExtensionMetadata('test');
        expect(metadata, isNotNull);
        expect(metadata!.dependencies, isEmpty);
      });
    });
  });

  group('ExtensionMetadata', () {
    test('should create metadata with all properties', () {
      // Arrange
      const name = 'test_extension';
      const version = '1.0.0';
      const description = 'Test extension';
      const dependencies = ['dep1', 'dep2'];
      final registeredAt = DateTime.now();

      // Act
      final metadata = ExtensionMetadata(
        name: name,
        version: version,
        description: description,
        dependencies: dependencies,
        registeredAt: registeredAt,
      );

      // Assert
      expect(metadata.name, equals(name));
      expect(metadata.version, equals(version));
      expect(metadata.description, equals(description));
      expect(metadata.dependencies, equals(dependencies));
      expect(metadata.registeredAt, equals(registeredAt));
    });

    test('should provide string representation', () {
      // Arrange
      const name = 'test_extension';
      const version = '1.0.0';
      const description = 'Test extension';
      const dependencies = ['dep1'];
      final registeredAt = DateTime(2024, 1, 1);

      final metadata = ExtensionMetadata(
        name: name,
        version: version,
        description: description,
        dependencies: dependencies,
        registeredAt: registeredAt,
      );

      // Act
      final stringRepresentation = metadata.toString();

      // Assert
      expect(stringRepresentation, contains(name));
      expect(stringRepresentation, contains(version));
      expect(stringRepresentation, contains(description));
      expect(stringRepresentation, contains('dep1'));
      expect(stringRepresentation, contains('2024-01-01'));
    });
  });
}
