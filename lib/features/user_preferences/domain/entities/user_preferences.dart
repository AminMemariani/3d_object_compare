import 'package:equatable/equatable.dart';

class UserPreferences extends Equatable {
  final String userId;
  final String themeMode;
  final String language;
  final bool isFirstLaunch;
  final double modelScale;
  final bool autoRotate;
  final String backgroundColor;

  const UserPreferences({
    required this.userId,
    required this.themeMode,
    required this.language,
    required this.isFirstLaunch,
    required this.modelScale,
    required this.autoRotate,
    required this.backgroundColor,
  });

  UserPreferences copyWith({
    String? userId,
    String? themeMode,
    String? language,
    bool? isFirstLaunch,
    double? modelScale,
    bool? autoRotate,
    String? backgroundColor,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      modelScale: modelScale ?? this.modelScale,
      autoRotate: autoRotate ?? this.autoRotate,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  @override
  List<Object> get props => [
    userId,
    themeMode,
    language,
    isFirstLaunch,
    modelScale,
    autoRotate,
    backgroundColor,
  ];
}
