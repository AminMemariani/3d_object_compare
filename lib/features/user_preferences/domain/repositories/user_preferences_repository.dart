import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_preferences.dart';

abstract class UserPreferencesRepository {
  Future<Either<Failure, UserPreferences>> getUserPreferences(String userId);
  Future<Either<Failure, void>> saveUserPreferences(
    UserPreferences preferences,
  );
  Future<Either<Failure, void>> updateUserPreferences(
    UserPreferences preferences,
  );
  Future<Either<Failure, void>> deleteUserPreferences(String userId);
}
