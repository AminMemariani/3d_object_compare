import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vector_math/vector_math_64.dart';
import '../models/object_model.dart';

/// Simplified ViewModel for 3D object comparison (MVVM pattern)
class ObjectComparisonViewModel extends ChangeNotifier {
  // Object state
  ObjectModel? _objectA;
  ObjectModel? _objectB;
  
  // File bytes for web
  Uint8List? _objectABytes;
  Uint8List? _objectBBytes;

  // Loading state
  bool _isLoading = false;
  String? _error;

  // Transform history for undo/redo
  List<ObjectTransform> _transformHistory = [];
  int _historyIndex = -1;

  // Getters
  ObjectModel? get objectA => _objectA;
  ObjectModel? get objectB => _objectB;
  Uint8List? get objectABytes => _objectABytes;
  Uint8List? get objectBBytes => _objectBBytes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasObjectA => _objectA != null;
  bool get hasObjectB => _objectB != null;
  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _transformHistory.length - 1;

  /// Load Object A
  Future<void> loadObjectA() async {
    await _loadObject('A');
  }

  /// Load Object B
  Future<void> loadObjectB() async {
    await _loadObject('B');
  }

  Future<void> _loadObject(String objectType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('📁 [START] Opening file picker for Object $objectType...');
      debugPrint('📁 Platform: ${kIsWeb ? "Web" : "Native"}');

      FilePickerResult? result;

      try {
        // Try with more permissive settings first
        result = await FilePicker.platform.pickFiles(
          type: FileType
              .any, // Changed from custom to any for better compatibility
          allowMultiple: false,
          allowCompression: false,
          withData: kIsWeb,
        );
        debugPrint(
          '📁 [PICKER RETURNED] Result: ${result != null ? "NOT NULL" : "NULL"}',
        );
      } catch (pickerError) {
        debugPrint(
          '❌ [PICKER ERROR] Exception during file picking: $pickerError',
        );
        _error = 'File picker error: $pickerError';
        notifyListeners();
        return;
      }

      if (result == null) {
        debugPrint(
          'ℹ️ [NULL RESULT] File picker returned null - likely cancelled or permission denied',
        );
        // Don't set error, just return - this is treated as cancellation
        return;
      }

      debugPrint('📁 [RESULT VALID] Files count: ${result.files.length}');

      if (result.files.isNotEmpty) {
        final file = result.files.single;
        final fileName = file.name;
        final fileExtension = fileName.split('.').last.toLowerCase();

        debugPrint('📁 [FILE INFO] Name: $fileName');
        debugPrint('📁 [FILE INFO] Extension: ${fileExtension.toUpperCase()}');
        debugPrint('📁 [FILE INFO] Path: ${file.path ?? "null"}');
        debugPrint('📁 [FILE INFO] Size: ${file.size} bytes');
        debugPrint('📁 [FILE INFO] Has bytes: ${file.bytes != null}');

        // Validate file extension
        final validExtensions = ['obj', 'stl', 'glb', 'gltf'];
        if (!validExtensions.contains(fileExtension)) {
          _error =
              'Unsupported file type: $fileExtension. Please select OBJ, STL, GLB, or GLTF files.';
          debugPrint(
            '❌ [VALIDATION ERROR] Unsupported file extension: $fileExtension',
          );
          notifyListeners();
          return;
        }

        // Handle file path vs bytes (web vs native)
        final filePath = kIsWeb ? 'web://$fileName' : (file.path ?? '');

        // Validate file data
        if (!kIsWeb && file.path == null) {
          _error = 'Unable to access file path';
          debugPrint(
            '❌ [VALIDATION ERROR] File path is null on native platform',
          );
          notifyListeners();
          return;
        }

        if (kIsWeb && file.bytes == null) {
          _error = 'Unable to read file data';
          debugPrint(
            '❌ [VALIDATION ERROR] File bytes are null on web platform',
          );
          notifyListeners();
          return;
        }

        debugPrint('📁 [VALIDATION PASSED] Creating object model...');

        // Create object model
        final newObject = ObjectModel(
          id: objectType == 'A' ? 'object_a' : 'object_b',
          name: fileName,
          filePath: filePath,
          fileExtension: fileExtension,
          color: objectType == 'A'
              ? const ColorRGB(0, 0.5, 1) // Blue for Object A
              : const ColorRGB(1, 0.2, 0.8), // Pink for Object B
          opacity: objectType == 'A' ? 1.0 : 0.7,
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
        );

        if (objectType == 'A') {
          _objectA = newObject;
          _objectABytes = file.bytes;
          debugPrint('✅ [SUCCESS] Object A loaded: $fileName');
        } else {
          _objectB = newObject;
          _objectBBytes = file.bytes;
          _clearHistory();
          _saveTransformToHistory();
          debugPrint('✅ [SUCCESS] Object B loaded: $fileName');
        }

        notifyListeners();
      } else {
        debugPrint('⚠️ [EMPTY RESULT] Result has no files');
      }
    } catch (e, stackTrace) {
      _error = 'Failed to load $objectType object: $e';
      debugPrint('❌ [FATAL ERROR] Error loading Object $objectType: $e');
      debugPrint('❌ [STACK TRACE] $stackTrace');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('📁 [END] Load operation completed for Object $objectType');
    }
  }

  /// Update Object A Position
  void updateObjectAPosition(Vector3 position) {
    if (_objectA != null) {
      _objectA = _objectA!.copyWith(position: position);
      notifyListeners();
    }
  }

  /// Update Object A Rotation
  void updateObjectARotation(Vector3 rotation) {
    if (_objectA != null) {
      _objectA = _objectA!.copyWith(rotation: rotation);
      notifyListeners();
    }
  }

  /// Update Object A Scale
  void updateObjectAScale(Vector3 scale) {
    if (_objectA != null) {
      _objectA = _objectA!.copyWith(scale: scale);
      notifyListeners();
    }
  }

  /// Update Object B Position
  void updateObjectBPosition(Vector3 position) {
    if (_objectB != null) {
      _objectB = _objectB!.copyWith(position: position);
      _saveTransformToHistory();
      notifyListeners();
    }
  }

  /// Update Object B Rotation
  void updateObjectBRotation(Vector3 rotation) {
    if (_objectB != null) {
      _objectB = _objectB!.copyWith(rotation: rotation);
      _saveTransformToHistory();
      notifyListeners();
    }
  }

  /// Update Object B Scale
  void updateObjectBScale(Vector3 scale) {
    if (_objectB != null) {
      _objectB = _objectB!.copyWith(scale: scale);
      _saveTransformToHistory();
      notifyListeners();
    }
  }

  /// Undo transform
  void undo() {
    if (canUndo) {
      _historyIndex--;
      _applyTransformFromHistory();
    }
  }

  /// Redo transform
  void redo() {
    if (canRedo) {
      _historyIndex++;
      _applyTransformFromHistory();
    }
  }

  void _saveTransformToHistory() {
    if (_objectB != null) {
      _transformHistory = _transformHistory.take(_historyIndex + 1).toList();
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
      );
      notifyListeners();
    }
  }

  void _clearHistory() {
    _transformHistory.clear();
    _historyIndex = -1;
  }

  /// Clear Object A
  void clearObjectA() {
    _objectA = null;
    _objectABytes = null;
    notifyListeners();
  }

  /// Clear Object B
  void clearObjectB() {
    _objectB = null;
    _objectBBytes = null;
    _clearHistory();
    notifyListeners();
  }

  /// Clear all objects
  void clearAll() {
    _objectA = null;
    _objectB = null;
    _objectABytes = null;
    _objectBBytes = null;
    _clearHistory();
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Transform state for undo/redo
class ObjectTransform {
  final Vector3 position;
  final Vector3 rotation;
  final Vector3 scale;

  const ObjectTransform({
    required this.position,
    required this.rotation,
    required this.scale,
  });
}

