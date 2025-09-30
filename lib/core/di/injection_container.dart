import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import '../database/database.dart';
import 'service_locator.dart';
import '../../features/user_preferences/data/datasources/user_preferences_local_data_source.dart';
import '../../features/user_preferences/data/repositories/user_preferences_repository_impl.dart';
import '../../features/user_preferences/domain/repositories/user_preferences_repository.dart';
import '../../features/user_preferences/domain/usecases/get_user_preferences.dart';
import '../../features/user_preferences/domain/usecases/save_user_preferences.dart';
import '../../features/user_preferences/presentation/providers/user_preferences_provider.dart';
import '../../features/model_viewer/presentation/providers/model_viewer_provider.dart';
import '../../features/model_viewer/presentation/providers/object_loader_provider.dart';
import '../../features/model_viewer/presentation/providers/object_provider.dart';
import '../../features/model_viewer/presentation/providers/ui_provider.dart';
import '../../features/model_viewer/presentation/viewmodels/object_view_model.dart';
import '../../features/model_viewer/presentation/viewmodels/ui_view_model.dart';

final sl = GetIt.instance;

Future<void> init() async {
  try {
    // External - Initialize Isar database
    final isar = await Database.instance;
    sl.registerLazySingleton<Isar>(() => isar);

    // Data sources
    sl.registerLazySingleton<UserPreferencesLocalDataSource>(
      () => UserPreferencesLocalDataSourceImpl(isar: sl()),
    );

    // Repository
    sl.registerLazySingleton<UserPreferencesRepository>(
      () => UserPreferencesRepositoryImpl(localDataSource: sl()),
    );

    // Use cases
    sl.registerLazySingleton(() => GetUserPreferences(sl()));
    sl.registerLazySingleton(() => SaveUserPreferences(sl()));

    // Providers
    sl.registerFactory(
      () => UserPreferencesProvider(
        getUserPreferences: sl(),
        saveUserPreferences: sl(),
      ),
    );
  } catch (e) {
    // If database initialization fails (e.g., on web), skip user preferences
    if (kIsWeb) {
      print('Warning: Database initialization failed on web, skipping user preferences: $e');
    } else {
      rethrow;
    }
  }

  // Always register these providers (they don't depend on database)
  sl.registerFactory(() => ModelViewerProvider());
  sl.registerFactory(() => ObjectLoaderProvider());

  // Features - New Provider Architecture
  sl.registerFactory(() => ObjectProvider());
  sl.registerFactory(() => UIProvider());

  // Features - ViewModels (MVVM)
  sl.registerFactory(() => ObjectViewModel());
  sl.registerFactory(() => UIViewModel());

  // Register services using ServiceLocator
  await ServiceLocator.registerServices();
}
