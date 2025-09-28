import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_3d_app/core/di/service_locator.dart';
import 'package:flutter_3d_app/features/model_viewer/domain/services/interfaces/procrustes_service_interface.dart';
import 'package:flutter_3d_app/features/model_viewer/domain/services/implementations/procrustes_service_impl.dart';

void main() {
  group('ServiceLocator - Simple Tests', () {
    setUp(() {
      ServiceLocator.reset();
    });

    tearDown(() {
      ServiceLocator.reset();
    });

    test('should register service as factory', () {
      // Act
      ServiceLocator.registerService<ProcrustesServiceInterface>(
        () => ProcrustesServiceImpl(),
      );

      // Assert
      expect(ServiceLocator.isRegistered<ProcrustesServiceInterface>(), isTrue);
    });

    test('should register service as singleton', () {
      // Act
      ServiceLocator.registerService<ProcrustesServiceInterface>(
        () => ProcrustesServiceImpl(),
        asSingleton: true,
      );

      // Assert
      expect(ServiceLocator.isRegistered<ProcrustesServiceInterface>(), isTrue);

      // Verify it's a singleton
      final instance1 = ServiceLocator.get<ProcrustesServiceInterface>();
      final instance2 = ServiceLocator.get<ProcrustesServiceInterface>();
      expect(identical(instance1, instance2), isTrue);
    });

    test('should get registered service', () {
      // Arrange
      ServiceLocator.registerService<ProcrustesServiceInterface>(
        () => ProcrustesServiceImpl(),
      );

      // Act
      final service = ServiceLocator.get<ProcrustesServiceInterface>();

      // Assert
      expect(service, isA<ProcrustesServiceInterface>());
      expect(service, isA<ProcrustesServiceImpl>());
    });

    test('should throw exception for unregistered service', () {
      // Act & Assert
      expect(
        () => ServiceLocator.get<ProcrustesServiceInterface>(),
        throwsA(isA<StateError>()),
      );
    });

    test('should unregister service', () {
      // Arrange
      ServiceLocator.registerService<ProcrustesServiceInterface>(
        () => ProcrustesServiceImpl(),
      );
      expect(ServiceLocator.isRegistered<ProcrustesServiceInterface>(), isTrue);

      // Act
      ServiceLocator.unregister<ProcrustesServiceInterface>();

      // Assert
      expect(
        ServiceLocator.isRegistered<ProcrustesServiceInterface>(),
        isFalse,
      );
    });

    test('should reset all registrations', () {
      // Arrange
      ServiceLocator.registerService<ProcrustesServiceInterface>(
        () => ProcrustesServiceImpl(),
      );

      // Act
      ServiceLocator.reset();

      // Assert - Check that the service is unregistered
      expect(
        ServiceLocator.isRegistered<ProcrustesServiceInterface>(),
        isFalse,
      );
    });
  });

  group('ServiceConfiguration', () {
    setUp(() {
      ServiceConfiguration.setEnvironment(ServiceConfiguration.development);
    });

    test('should set and get environment', () {
      // Act
      ServiceConfiguration.setEnvironment(ServiceConfiguration.production);

      // Assert
      expect(
        ServiceConfiguration.currentEnvironment,
        equals(ServiceConfiguration.production),
      );
    });

    test('should detect development environment', () {
      // Arrange
      ServiceConfiguration.setEnvironment(ServiceConfiguration.development);

      // Assert
      expect(ServiceConfiguration.isDevelopment, isTrue);
      expect(ServiceConfiguration.isTesting, isFalse);
      expect(ServiceConfiguration.isProduction, isFalse);
    });

    test('should detect testing environment', () {
      // Arrange
      ServiceConfiguration.setEnvironment(ServiceConfiguration.testing);

      // Assert
      expect(ServiceConfiguration.isDevelopment, isFalse);
      expect(ServiceConfiguration.isTesting, isTrue);
      expect(ServiceConfiguration.isProduction, isFalse);
    });

    test('should detect production environment', () {
      // Arrange
      ServiceConfiguration.setEnvironment(ServiceConfiguration.production);

      // Assert
      expect(ServiceConfiguration.isDevelopment, isFalse);
      expect(ServiceConfiguration.isTesting, isFalse);
      expect(ServiceConfiguration.isProduction, isTrue);
    });
  });
}
