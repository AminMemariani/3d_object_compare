import 'package:flutter/foundation.dart';

/// Provider for managing tutorial state and flow
class TutorialProvider extends ChangeNotifier {
  bool _isTutorialActive = false;
  int _currentStep = 0;
  bool _hasCompletedTutorial = false;

  bool get isTutorialActive => _isTutorialActive;
  int get currentStep => _currentStep;
  bool get hasCompletedTutorial => _hasCompletedTutorial;

  void startTutorial() {
    _isTutorialActive = true;
    _currentStep = 0;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 7) {
      // 8 steps total (0-7)
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void skipTutorial() {
    _isTutorialActive = false;
    _currentStep = 0;
    notifyListeners();
  }

  void completeTutorial() {
    _isTutorialActive = false;
    _currentStep = 0;
    _hasCompletedTutorial = true;
    notifyListeners();
  }

  void resetTutorial() {
    _isTutorialActive = false;
    _currentStep = 0;
    _hasCompletedTutorial = false;
    notifyListeners();
  }
}
