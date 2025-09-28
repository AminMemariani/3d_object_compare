import 'package:get_it/get_it.dart';
import '../../features/model_viewer/domain/services/interfaces/procrustes_service_interface.dart';
import '../../features/model_viewer/domain/services/implementations/procrustes_service_impl.dart';
import '../../features/model_viewer/domain/services/mocks/mock_procrustes_service.dart';
import '../../features/model_viewer/domain/services/implementations/object_loader_service_impl.dart';
import '../../features/model_viewer/domain/services/implementations/export_service_impl.dart';

/// Service locator for dependency injection
class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;

  /// Gets the GetIt instance
  static GetIt get instance => _getIt;

  /// Registers all services
  static Future<void> registerServices() async {
    // Core services
    _registerCoreServices();

    // Domain services
    _registerDomainServices();

    // Future extension services (placeholders)
    _registerExtensionServices();
  }

  /// Registers core services
  static void _registerCoreServices() {
    // Register as singletons for core services
    _getIt.registerLazySingleton<ProcrustesServiceInterface>(
      () => ProcrustesServiceImpl(),
    );
  }

  /// Registers domain services
  static void _registerDomainServices() {
    // Register as factories for domain services
    _getIt.registerFactory<ObjectLoaderServiceInterface>(
      () => ObjectLoaderServiceImpl(),
    );

    _getIt.registerFactory<ExportServiceInterface>(() => ExportServiceImpl());
  }

  /// Registers extension services (future features)
  static void _registerExtensionServices() {
    // Placeholder registrations for future services
    // These will be implemented when the features are added

    // Cloud sync service (future)
    // _getIt.registerLazySingleton<CloudSyncServiceInterface>(
    //   () => CloudSyncServiceImpl(),
    // );

    // AI alignment service (future)
    // _getIt.registerLazySingleton<AIAlignmentServiceInterface>(
    //   () => AIAlignmentServiceImpl(),
    // );

    // Multi-object comparison service (future)
    // _getIt.registerLazySingleton<MultiObjectComparisonServiceInterface>(
    //   () => MultiObjectComparisonServiceImpl(),
    // );
  }

  /// Registers test services (for unit testing)
  static void registerTestServices() {
    // Clear existing registrations
    _getIt.reset();

    // Register mock services for testing
    _getIt.registerLazySingleton<ProcrustesServiceInterface>(
      () => MockProcrustesService(),
    );

    _getIt.registerFactory<ObjectLoaderServiceInterface>(
      () => ObjectLoaderServiceImpl(),
    );

    _getIt.registerFactory<ExportServiceInterface>(() => ExportServiceImpl());

    // Note: UserPreferencesProvider registration removed for now to avoid compilation errors
    // This can be added back when proper mock repositories are created
  }

  /// Registers a service with a specific implementation
  static void registerService<T extends Object>(
    T Function() factory, {
    bool asSingleton = false,
  }) {
    if (asSingleton) {
      _getIt.registerLazySingleton<T>(factory);
    } else {
      _getIt.registerFactory<T>(factory);
    }
  }

  /// Gets a service instance
  static T get<T extends Object>() {
    return _getIt.get<T>();
  }

  /// Checks if a service is registered
  static bool isRegistered<T extends Object>() {
    return _getIt.isRegistered<T>();
  }

  /// Unregisters a service
  static void unregister<T extends Object>() {
    _getIt.unregister<T>();
  }

  /// Resets all registrations
  static void reset() {
    _getIt.reset();
  }
}

/// Extension methods for easier service access
extension ServiceLocatorExtension on GetIt {
  /// Gets a service with null safety
  T? getOrNull<T extends Object>() {
    try {
      return get<T>();
    } catch (e) {
      return null;
    }
  }

  /// Gets a service or throws a descriptive error
  T getRequired<T extends Object>() {
    if (!isRegistered<T>()) {
      throw ServiceNotRegisteredException<T>();
    }
    return get<T>();
  }
}

/// Exception thrown when a required service is not registered
class ServiceNotRegisteredException<T> implements Exception {
  @override
  String toString() {
    return 'Service of type $T is not registered. Make sure to register it before use.';
  }
}

/// Service configuration for different environments
class ServiceConfiguration {
  static const String development = 'development';
  static const String testing = 'testing';
  static const String production = 'production';

  static String _currentEnvironment = development;

  /// Sets the current environment
  static void setEnvironment(String environment) {
    _currentEnvironment = environment;
  }

  /// Gets the current environment
  static String get currentEnvironment => _currentEnvironment;

  /// Checks if running in development mode
  static bool get isDevelopment => _currentEnvironment == development;

  /// Checks if running in testing mode
  static bool get isTesting => _currentEnvironment == testing;

  /// Checks if running in production mode
  static bool get isProduction => _currentEnvironment == production;
}
