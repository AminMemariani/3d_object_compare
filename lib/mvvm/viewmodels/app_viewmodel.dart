import 'package:flutter/material.dart';

/// Simple ViewModel for app-wide state (MVVM pattern)
class AppViewModel extends ChangeNotifier {
  // Theme state
  ThemeMode _themeMode = ThemeMode.system;
  
  // UI state
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Toggle theme mode
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  /// Set theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Show error message
  void showError(String message) {
    _error = message;
    _successMessage = null;
    notifyListeners();
  }

  /// Show success message
  void showSuccess(String message) {
    _successMessage = message;
    _error = null;
    notifyListeners();
  }

  /// Clear messages
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}

