import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vector_math/vector_math_64.dart';
import '../../domain/entities/object_3d.dart';
import '../../domain/entities/procrustes_result.dart';
import '../../domain/services/procrustes.dart';
import '../../domain/services/procrustes_isolate_service.dart';

class ObjectLoaderProvider extends ChangeNotifier {
  Object3D? _objectA;
  Object3D? _objectB;
  bool _isLoading = false;
  String? _error;
  List<ObjectTransform> _transformHistory = [];
  int _historyIndex = -1;
  ProcrustesResult? _procrustesResult;
  bool _isAnalyzing = false;
  double _analysisProgress = 0.0;
  bool _showResultsCard = false;

  // Getters
  Object3D? get objectA => _objectA;
  Object3D? get objectB => _objectB;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasObjectA => _objectA != null;
  bool get hasObjectB => _objectB != null;
  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _transformHistory.length - 1;
  ProcrustesResult? get procrustesResult => _procrustesResult;
  bool get isAnalyzing => _isAnalyzing;
  double get analysisProgress => _analysisProgress;
  bool get showResultsCard => _showResultsCard;

  // Load Object A
  Future<void> loadObjectA() async {
    await _loadObject('A');
  }

  // Load Object B
  Future<void> loadObjectB() async {
    await _loadObject('B');
  }

  Future<void> _loadObject(String objectType) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['obj', 'stl'],
        allowMultiple: false,
        withData: kIsWeb, // Request bytes on web
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // On web, path is null but bytes are available
        // On native, path is available
        final filePath = kIsWeb 
            ? 'web://${file.name}' // Virtual path for web
            : (file.path ?? '');
            
        // Verify we have file data
        if (!kIsWeb && file.path == null) {
          _setError('Unable to access file path');
          return;
        }
        
        if (kIsWeb && file.bytes == null) {
          _setError('Unable to read file data');
          return;
        }
        
        final object = Object3D(
          id: '${objectType.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
          name: file.name,
          filePath: filePath,
          fileExtension: file.extension ?? '',
          color: objectType == 'A'
              ? const Color3D(0, 0.5, 1) // Blue for Object A
              : const Color3D(1, 0.2, 0.8), // Pink for Object B
          opacity: objectType == 'A'
              ? 1.0
              : 0.7, // Object B is semi-transparent
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
        );

        if (objectType == 'A') {
          _objectA = object;
        } else {
          _objectB = object;
          _saveTransformToHistory();
        }

        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to load $objectType object: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Transform Object A
  void updateObjectAPosition(Vector3 position) {
    if (_objectA != null) {
      _objectA = _objectA!.copyWith(
        position: position,
        lastModified: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void updateObjectARotation(Vector3 rotation) {
    if (_objectA != null) {
      _objectA = _objectA!.copyWith(
        rotation: rotation,
        lastModified: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void updateObjectAScale(Vector3 scale) {
    if (_objectA != null) {
      _objectA = _objectA!.copyWith(scale: scale, lastModified: DateTime.now());
      notifyListeners();
    }
  }

  // Transform Object B
  void updateObjectBPosition(Vector3 position) {
    if (_objectB != null) {
      _objectB = _objectB!.copyWith(
        position: position,
        lastModified: DateTime.now(),
      );
      _saveTransformToHistory();
      notifyListeners();
    }
  }

  void updateObjectBRotation(Vector3 rotation) {
    if (_objectB != null) {
      _objectB = _objectB!.copyWith(
        rotation: rotation,
        lastModified: DateTime.now(),
      );
      _saveTransformToHistory();
      notifyListeners();
    }
  }

  void updateObjectBScale(Vector3 scale) {
    if (_objectB != null) {
      _objectB = _objectB!.copyWith(scale: scale, lastModified: DateTime.now());
      _saveTransformToHistory();
      notifyListeners();
    }
  }

  void updateObjectBColor(Color3D color) {
    if (_objectB != null) {
      _objectB = _objectB!.copyWith(color: color, lastModified: DateTime.now());
      notifyListeners();
    }
  }

  void updateObjectBOpacity(double opacity) {
    if (_objectB != null) {
      _objectB = _objectB!.copyWith(
        opacity: opacity,
        lastModified: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Reset Object B to default state
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

  // Undo/Redo functionality
  void undo() {
    if (canUndo) {
      _historyIndex--;
      _applyTransformFromHistory();
    }
  }

  void redo() {
    if (canRedo) {
      _historyIndex++;
      _applyTransformFromHistory();
    }
  }

  void _saveTransformToHistory() {
    if (_objectB != null) {
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
      notifyListeners();
    }
  }

  // Clear objects
  void clearObjectA() {
    _objectA = null;
    notifyListeners();
  }

  void clearObjectB() {
    _objectB = null;
    _transformHistory.clear();
    _historyIndex = -1;
    notifyListeners();
  }

  void clearAll() {
    _objectA = null;
    _objectB = null;
    _transformHistory.clear();
    _historyIndex = -1;
    notifyListeners();
  }

  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Get alignment score (simple distance-based alignment)
  double getAlignmentScore() {
    if (_objectA == null || _objectB == null) return 0.0;

    final distance = _objectA!.position.distanceTo(_objectB!.position);
    final rotationDiff = (_objectA!.rotation - _objectB!.rotation).length;
    final scaleDiff = (_objectA!.scale - _objectB!.scale).length;

    // Normalize to 0-100 score (higher is better)
    final score = 100 - (distance * 10 + rotationDiff * 5 + scaleDiff * 5);
    return score.clamp(0.0, 100.0);
  }

  // Auto-align Object B to Object A
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

  // Perform Procrustes analysis with isolate
  Future<void> performProcrustesAnalysis() async {
    if (_objectA == null || _objectB == null) return;

    _isAnalyzing = true;
    _analysisProgress = 0.0;
    _showResultsCard = false;
    notifyListeners();

    try {
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
    } catch (e) {
      _setError('Procrustes analysis failed: $e');
    } finally {
      _isAnalyzing = false;
      _analysisProgress = 0.0;
      notifyListeners();
    }
  }

  // Get similarity metrics
  ProcrustesMetrics? getSimilarityMetrics() {
    if (_objectA == null || _objectB == null) return null;

    try {
      return Procrustes.computeSimilarity(_objectA!, _objectB!);
    } catch (e) {
      return null;
    }
  }

  // Clear Procrustes results
  void clearProcrustesResults() {
    _procrustesResult = null;
    _showResultsCard = false;
    notifyListeners();
  }

  // Hide results card
  void hideResultsCard() {
    _showResultsCard = false;
    notifyListeners();
  }
}
