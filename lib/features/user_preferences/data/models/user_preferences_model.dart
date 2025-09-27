import 'package:isar/isar.dart';
import '../../domain/entities/user_preferences.dart';

part 'user_preferences_model.g.dart';

@collection
class UserPreferencesModel {
  Id id = 1; // Fixed ID for web compatibility

  @Index(unique: true)
  late String userId;

  late String themeMode;
  late String language;
  late bool isFirstLaunch;
  late double modelScale;
  late bool autoRotate;
  late String backgroundColor;

  UserPreferencesModel({
    required this.userId,
    this.themeMode = 'system',
    this.language = 'en',
    this.isFirstLaunch = true,
    this.modelScale = 1.0,
    this.autoRotate = true,
    this.backgroundColor = '#FFFFFF',
  });

  factory UserPreferencesModel.fromEntity(UserPreferences entity) {
    return UserPreferencesModel(
      userId: entity.userId,
      themeMode: entity.themeMode,
      language: entity.language,
      isFirstLaunch: entity.isFirstLaunch,
      modelScale: entity.modelScale,
      autoRotate: entity.autoRotate,
      backgroundColor: entity.backgroundColor,
    );
  }

  UserPreferences toEntity() {
    return UserPreferences(
      userId: userId,
      themeMode: themeMode,
      language: language,
      isFirstLaunch: isFirstLaunch,
      modelScale: modelScale,
      autoRotate: autoRotate,
      backgroundColor: backgroundColor,
    );
  }
}
