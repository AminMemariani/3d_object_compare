import 'package:flutter/material.dart';
import '../../../../core/mvvm/base_view_model.dart';

/// ViewModel for managing UI state and interactions (MVVM pattern)
class UIViewModel extends BaseViewModel {
  // Theme and appearance
  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'en';

  // UI state
  bool _isControlPanelVisible = false;
  bool _isSettingsPanelVisible = false;
  bool _isResultsPanelVisible = false;

  // Navigation state
  int _currentBottomNavIndex = 0;
  String _currentRoute = '/';

  // Animation states
  bool _animationsEnabled = true;
  Duration _animationDuration = const Duration(milliseconds: 300);

  // Object visibility states
  bool _showObjectA = true;
  bool _showObjectB = true;

  // Getters
  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  bool get isControlPanelVisible => _isControlPanelVisible;
  bool get isSettingsPanelVisible => _isSettingsPanelVisible;
  bool get isResultsPanelVisible => _isResultsPanelVisible;
  int get currentBottomNavIndex => _currentBottomNavIndex;
  String get currentRoute => _currentRoute;
  bool get animationsEnabled => _animationsEnabled;
  Duration get animationDuration => _animationDuration;
  bool get showObjectA => _showObjectA;
  bool get showObjectB => _showObjectB;

  // Theme management
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setLanguage(String language) {
    _language = language;
    notifyListeners();
  }

  void toggleTheme() {
    switch (_themeMode) {
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _themeMode = ThemeMode.system;
        break;
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
        break;
    }
    notifyListeners();
  }

  // Panel visibility management
  void toggleControlPanel() {
    _isControlPanelVisible = !_isControlPanelVisible;
    notifyListeners();
  }

  void setControlPanelVisible(bool visible) {
    _isControlPanelVisible = visible;
    notifyListeners();
  }

  void toggleSettingsPanel() {
    _isSettingsPanelVisible = !_isSettingsPanelVisible;
    notifyListeners();
  }

  void setSettingsPanelVisible(bool visible) {
    _isSettingsPanelVisible = visible;
    notifyListeners();
  }

  void toggleResultsPanel() {
    _isResultsPanelVisible = !_isResultsPanelVisible;
    notifyListeners();
  }

  void setResultsPanelVisible(bool visible) {
    _isResultsPanelVisible = visible;
    notifyListeners();
  }

  // Navigation management
  void setCurrentBottomNavIndex(int index) {
    _currentBottomNavIndex = index;
    notifyListeners();
  }

  void setCurrentRoute(String route) {
    _currentRoute = route;
    notifyListeners();
  }

  Future<void> navigateToRoute(String route) async {
    setLoading(true);
    _currentRoute = route;
    notifyListeners();

    // Simulate navigation delay
    await Future.delayed(const Duration(milliseconds: 100));
    setLoading(false);
  }

  // Animation management
  void setAnimationsEnabled(bool enabled) {
    _animationsEnabled = enabled;
    notifyListeners();
  }

  void setAnimationDuration(Duration duration) {
    _animationDuration = duration;
    notifyListeners();
  }

  // Object visibility management
  void toggleObjectAVisibility() {
    _showObjectA = !_showObjectA;
    notifyListeners();
  }

  void toggleObjectBVisibility() {
    _showObjectB = !_showObjectB;
    notifyListeners();
  }

  void setObjectAVisibility(bool visible) {
    _showObjectA = visible;
    notifyListeners();
  }

  void setObjectBVisibility(bool visible) {
    _showObjectB = visible;
    notifyListeners();
  }

  // Utility methods
  void resetUI() {
    _isControlPanelVisible = false;
    _isSettingsPanelVisible = false;
    _isResultsPanelVisible = false;
    _currentBottomNavIndex = 0;
    _currentRoute = '/';
    _showObjectA = true;
    _showObjectB = true;
    clearError();
    notifyListeners();
  }

  // Animation helpers
  AnimationController createAnimationController(TickerProvider vsync) {
    return AnimationController(duration: _animationDuration, vsync: vsync);
  }

  CurvedAnimation createCurvedAnimation(AnimationController controller) {
    return CurvedAnimation(
      parent: controller,
      curve: _animationsEnabled ? Curves.easeInOut : Curves.linear,
    );
  }

  // Theme helpers
  bool isDarkMode(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }

  Color getAccentColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  Color getOnSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  // Responsive helpers
  bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  double getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) return 32.0;
    if (isTablet(context)) return 24.0;
    return 16.0;
  }

  double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isDesktop(context)) return baseSize * 1.2;
    if (isTablet(context)) return baseSize * 1.1;
    return baseSize;
  }
}
