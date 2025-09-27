import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import '../datasources/user_preferences_local_data_source.dart';
import '../models/user_preferences_model.dart';

class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  final UserPreferencesLocalDataSource localDataSource;

  UserPreferencesRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, UserPreferences>> getUserPreferences(
    String userId,
  ) async {
    try {
      final model = await localDataSource.getUserPreferences(userId);
      if (model != null) {
        return Right(model.toEntity());
      } else {
        // Return default preferences if none exist
        final defaultPreferences = UserPreferences(
          userId: userId,
          themeMode: 'system',
          language: 'en',
          isFirstLaunch: true,
          modelScale: 1.0,
          autoRotate: true,
          backgroundColor: '#FFFFFF',
        );
        return Right(defaultPreferences);
      }
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveUserPreferences(
    UserPreferences preferences,
  ) async {
    try {
      final model = UserPreferencesModel.fromEntity(preferences);
      await localDataSource.saveUserPreferences(model);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateUserPreferences(
    UserPreferences preferences,
  ) async {
    try {
      final model = UserPreferencesModel.fromEntity(preferences);
      await localDataSource.updateUserPreferences(model);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserPreferences(String userId) async {
    try {
      await localDataSource.deleteUserPreferences(userId);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
