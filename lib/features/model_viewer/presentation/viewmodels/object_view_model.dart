import 'package:file_picker/file_picker.dart';
import 'package:vector_math/vector_math_64.dart';
import '../../../../core/mvvm/base_view_model.dart';
import '../../domain/entities/object_3d.dart';
import '../../domain/entities/procrustes_result.dart';
import '../../domain/services/procrustes.dart';
import '../../domain/services/procrustes_isolate_service.dart';

/// ViewModel for managing 3D objects and transformations (MVVM pattern)
class ObjectViewModel extends BaseViewModel with AsyncOperationMixin {
  // Object state
  Object3D? _objectA;
  Object3D? _objectB;

  // Transformation history for undo/redo
  List<ObjectTransform> _transformHistory = [];
  int _historyIndex = -1;

  // Procrustes analysis state
  ProcrustesResult? _procrustesResult;
  double _analysisProgress = 0.0;
  bool _showResultsCard = false;

  // Getters
  Object3D? get objectA => _objectA;
  Object3D? get objectB => _objectB;
  bool get hasObjectA => _objectA != null;
  bool get hasObjectB => _objectB != null;
  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _transformHistory.length - 1;
  ProcrustesResult? get procrustesResult => _procrustesResult;
  double get analysisProgress => _analysisProgress;
  bool get showResultsCard => _showResultsCard;
  bool get isAnalyzing => isOperationRunning('procrustes_analysis');

  // Object loading methods
  Future<void> loadObjectA() async {
    await executeOperation('load_object_a', () => _loadObject('A'));
  }

  Future<void> loadObjectB() async {
    await executeOperation('load_object_b', () => _loadObject('B'));
  }

  Future<void> _loadObject(String objectType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['obj', 'stl'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final fileName = result.files.single.name;
      final fileExtension = fileName.split('.').last;

      final newObject = Object3D(
        id: objectType == 'A' ? 'object_a' : 'object_b',
        name: fileName,
        filePath: filePath,
        fileExtension: fileExtension,
        color: objectType == 'A'
            ? const Color3D(0, 0.5, 1) // Blue for Object A
            : const Color3D(1, 0.2, 0.8), // Pink for Object B
        opacity: objectType == 'A' ? 1.0 : 0.7,
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
      );

      if (objectType == 'A') {
        _objectA = newObject;
      } else {
        _objectB = newObject;
        _clearHistory();
        _saveTransformToHistory();
      }
      notifyListeners();
    }
  }

  // Object transformation methods
  void updateObjectBPosition(Vector3 newPosition) {
    if (_objectB != null) {
      _objectB = _objectB!.copyWith(
        position: newPosition,
        lastModified: DateTime.now(),
      );
      _saveTransformToHistory();
      notifyListeners();
    }
  }

  void updateObjectBRotation(Vector3 newRotation) {
    if (_objectB != null) {
      _objectB = _objectB!.copyWith(
        rotation: newRotation,
        lastModified: DateTime.now(),
      );
      _saveTransformToHistory();
      notifyListeners();
    }
  }

  void updateObjectBScale(Vector3 newScale) {
    if (_objectB != null) {
      _objectB = _objectB!.copyWith(
        scale: newScale,
        lastModified: DateTime.now(),
      );
      _saveTransformToHistory();
      notifyListeners();
    }
  }

  void updateObjectBOpacity(double newOpacity) {
    if (_objectB != null) {
      _objectB = _objectB!.copyWith(
        opacity: newOpacity,
        lastModified: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void updateObjectBColor(Color3D color) {
    if (_objectB != null) {
      _objectB = _objectB!.copyWith(color: color, lastModified: DateTime.now());
      notifyListeners();
    }
  }

  // Object visibility methods
  void toggleObjectAVisibility() {
    if (_objectA != null) {
      _objectA = _objectA!.copyWith(opacity: _objectA!.opacity > 0 ? 0.0 : 1.0);
      notifyListeners();
    }
  }

  void toggleObjectBVisibility() {
    if (_objectB != null) {
      _objectB = _objectB!.copyWith(opacity: _objectB!.opacity > 0 ? 0.0 : 0.7);
      notifyListeners();
    }
  }

  // History management methods
  void _clearHistory() {
    _transformHistory.clear();
    _historyIndex = -1;
  }

  void _saveTransformToHistory() {
    if (_objectB == null) return;

    // Remove any history after current index
    _transformHistory = _transformHistory.take(_historyIndex + 1).toList();

    // Add new transform
    _transformHistory.add(
      ObjectTransform(
        position: _objectB!.position,
        rotation: _objectB!.rotation,
        scale: _objectB!.scale,
      ),
    );

    _historyIndex = _transformHistory.length - 1;
  }

  void undo() {
    if (canUndo) {
      _historyIndex--;
      _applyTransformFromHistory();
      notifyListeners();
    }
  }

  void redo() {
    if (canRedo) {
      _historyIndex++;
      _applyTransformFromHistory();
      notifyListeners();
    }
  }

  void _applyTransformFromHistory() {
    if (_objectB != null &&
        _historyIndex >= 0 &&
        _historyIndex < _transformHistory.length) {
      final transform = _transformHistory[_historyIndex];
      _objectB = _objectB!.copyWith(
        position: transform.position,
        rotation: transform.rotation,
        scale: transform.scale,
        lastModified: DateTime.now(),
      );
    }
  }

  // Reset and alignment methods
  void resetObjectB() {
    if (_objectB != null) {
      _objectB = _objectB!.copyWith(
        position: Vector3.zero(),
        rotation: Vector3.zero(),
        scale: Vector3.all(1.0),
        lastModified: DateTime.now(),
      );
      _saveTransformToHistory();
      notifyListeners();
    }
  }

  void autoAlignObjectB() {
    if (_objectA != null && _objectB != null) {
      _objectB = _objectB!.copyWith(
        position: _objectA!.position,
        rotation: _objectA!.rotation,
        scale: _objectA!.scale,
        lastModified: DateTime.now(),
      );
      _saveTransformToHistory();
      notifyListeners();
    }
  }

  // Procrustes analysis methods
  Future<void> performProcrustesAnalysis() async {
    if (_objectA == null || _objectB == null) return;

    await executeOperation('procrustes_analysis', () async {
      _analysisProgress = 0.0;
      _showResultsCard = false;
      notifyListeners();

      // Perform Procrustes analysis in isolate
      _procrustesResult = await ProcrustesIsolateService.runAnalysis(
        _objectA!,
        _objectB!,
        (progress) {
          _analysisProgress = progress;
          notifyListeners();
        },
      );

      // Apply the optimal transformation to Object B
      if (_procrustesResult != null) {
        _objectB = Procrustes.applyTransformation(
          _objectB!,
          _procrustesResult!,
        );
        _saveTransformToHistory();
        _showResultsCard = true;
      }
    });
  }

  ProcrustesMetrics? getSimilarityMetrics() {
    if (_objectA == null || _objectB == null) return null;

    try {
      return Procrustes.computeSimilarity(_objectA!, _objectB!);
    } catch (e) {
      return null;
    }
  }

  double getAlignmentScore() {
    if (_objectA == null || _objectB == null) return 0.0;

    final distance = _objectA!.position.distanceTo(_objectB!.position);
    final rotationDiff = (_objectA!.rotation - _objectB!.rotation).length;
    final scaleDiff = (_objectA!.scale - _objectB!.scale).length;

    // Normalize to 0-100 score (higher is better)
    final score = 100 - (distance * 10 + rotationDiff * 5 + scaleDiff * 5);
    return score.clamp(0.0, 100.0);
  }

  // Results card management
  void clearProcrustesResults() {
    _procrustesResult = null;
    _showResultsCard = false;
    notifyListeners();
  }

  void hideResultsCard() {
    _showResultsCard = false;
    notifyListeners();
  }

  // Clear all objects
  void clearAllObjects() {
    _objectA = null;
    _objectB = null;
    _procrustesResult = null;
    _showResultsCard = false;
    _clearHistory();
    clearError();
    notifyListeners();
  }
}
