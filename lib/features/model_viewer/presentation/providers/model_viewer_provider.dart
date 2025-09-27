import 'package:flutter/foundation.dart';
import '../../domain/entities/model_3d.dart';

class ModelViewerProvider extends ChangeNotifier {
  Model3D? _currentModel;
  bool _isLoading = false;
  String? _error;
  double _currentScale = 1.0;
  bool _isAutoRotating = true;
  String _backgroundColor = '#FFFFFF';

  Model3D? get currentModel => _currentModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get currentScale => _currentScale;
  bool get isAutoRotating => _isAutoRotating;
  String get backgroundColor => _backgroundColor;

  void loadModel(Model3D model) {
    _currentModel = model;
    _currentScale = model.scale;
    _isAutoRotating = model.autoRotate;
    _backgroundColor = model.backgroundColor;
    _error = null;
    notifyListeners();
  }

  void updateScale(double scale) {
    _currentScale = scale;
    notifyListeners();
  }

  void toggleAutoRotate() {
    _isAutoRotating = !_isAutoRotating;
    notifyListeners();
  }

  void updateBackgroundColor(String color) {
    _backgroundColor = color;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void reset() {
    _currentModel = null;
    _isLoading = false;
    _error = null;
    _currentScale = 1.0;
    _isAutoRotating = true;
    _backgroundColor = '#FFFFFF';
    notifyListeners();
  }
}
