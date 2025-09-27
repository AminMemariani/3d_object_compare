import 'package:isar/isar.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_preferences_model.dart';

abstract class UserPreferencesLocalDataSource {
  Future<UserPreferencesModel?> getUserPreferences(String userId);
  Future<void> saveUserPreferences(UserPreferencesModel preferences);
  Future<void> updateUserPreferences(UserPreferencesModel preferences);
  Future<void> deleteUserPreferences(String userId);
}

class UserPreferencesLocalDataSourceImpl
    implements UserPreferencesLocalDataSource {
  final Isar isar;

  UserPreferencesLocalDataSourceImpl({required this.isar});

  @override
  Future<UserPreferencesModel?> getUserPreferences(String userId) async {
    try {
      return await isar.userPreferencesModels
          .where()
          .userIdEqualTo(userId)
          .findFirst();
    } catch (e) {
      throw CacheException('Failed to get user preferences: $e');
    }
  }

  @override
  Future<void> saveUserPreferences(UserPreferencesModel preferences) async {
    try {
      await isar.writeTxn(() async {
        await isar.userPreferencesModels.put(preferences);
      });
    } catch (e) {
      throw CacheException('Failed to save user preferences: $e');
    }
  }

  @override
  Future<void> updateUserPreferences(UserPreferencesModel preferences) async {
    try {
      await isar.writeTxn(() async {
        await isar.userPreferencesModels.put(preferences);
      });
    } catch (e) {
      throw CacheException('Failed to update user preferences: $e');
    }
  }

  @override
  Future<void> deleteUserPreferences(String userId) async {
    try {
      await isar.writeTxn(() async {
        await isar.userPreferencesModels
            .where()
            .userIdEqualTo(userId)
            .deleteFirst();
      });
    } catch (e) {
      throw CacheException('Failed to delete user preferences: $e');
    }
  }
}
