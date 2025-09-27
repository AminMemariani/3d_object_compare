import 'package:flutter/foundation.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/usecases/get_user_preferences.dart';
import '../../domain/usecases/save_user_preferences.dart';

class UserPreferencesProvider extends ChangeNotifier {
  final GetUserPreferences getUserPreferences;
  final SaveUserPreferences saveUserPreferences;

  UserPreferencesProvider({
    required this.getUserPreferences,
    required this.saveUserPreferences,
  });

  UserPreferences? _preferences;
  bool _isLoading = false;
  String? _error;

  UserPreferences? get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserPreferences(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getUserPreferences(userId);

    result.fold(
      (failure) {
        _error = 'Failed to load user preferences';
        _isLoading = false;
        notifyListeners();
      },
      (preferences) {
        _preferences = preferences;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> updatePreferences(UserPreferences updatedPreferences) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await saveUserPreferences(updatedPreferences);

    result.fold(
      (failure) {
        _error = 'Failed to save user preferences';
        _isLoading = false;
        notifyListeners();
      },
      (_) {
        _preferences = updatedPreferences;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void updateThemeMode(String themeMode) {
    if (_preferences != null) {
      final updated = _preferences!.copyWith(themeMode: themeMode);
      updatePreferences(updated);
    }
  }

  void updateLanguage(String language) {
    if (_preferences != null) {
      final updated = _preferences!.copyWith(language: language);
      updatePreferences(updated);
    }
  }

  void updateModelScale(double scale) {
    if (_preferences != null) {
      final updated = _preferences!.copyWith(modelScale: scale);
      updatePreferences(updated);
    }
  }

  void updateAutoRotate(bool autoRotate) {
    if (_preferences != null) {
      final updated = _preferences!.copyWith(autoRotate: autoRotate);
      updatePreferences(updated);
    }
  }

  void updateBackgroundColor(String color) {
    if (_preferences != null) {
      final updated = _preferences!.copyWith(backgroundColor: color);
      updatePreferences(updated);
    }
  }

  void markFirstLaunchComplete() {
    if (_preferences != null) {
      final updated = _preferences!.copyWith(isFirstLaunch: false);
      updatePreferences(updated);
    }
  }
}
