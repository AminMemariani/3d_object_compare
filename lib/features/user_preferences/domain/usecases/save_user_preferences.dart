import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_preferences.dart';
import '../repositories/user_preferences_repository.dart';

class SaveUserPreferences {
  final UserPreferencesRepository repository;

  SaveUserPreferences(this.repository);

  Future<Either<Failure, void>> call(UserPreferences preferences) async {
    return await repository.saveUserPreferences(preferences);
  }
}
