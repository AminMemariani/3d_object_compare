import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_preferences.dart';
import '../repositories/user_preferences_repository.dart';

class GetUserPreferences {
  final UserPreferencesRepository repository;

  GetUserPreferences(this.repository);

  Future<Either<Failure, UserPreferences>> call(String userId) async {
    return await repository.getUserPreferences(userId);
  }
}
