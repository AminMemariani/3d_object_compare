import 'package:flutter/foundation.dart';
import '../../entities/object_3d.dart';
import '../../entities/procrustes_result.dart';

/// Registry for managing extension services
class ExtensionRegistry {
  static final Map<String, dynamic> _extensions = {};
  static final Map<String, ExtensionMetadata> _metadata = {};

  /// Registers an extension service
  static void registerExtension<T extends Object>(
    String name,
    T service, {
    String? version,
    String? description,
    List<String>? dependencies,
  }) {
    _extensions[name] = service;
    _metadata[name] = ExtensionMetadata(
      name: name,
      version: version ?? '1.0.0',
      description: description ?? 'No description provided',
      dependencies: dependencies ?? [],
      registeredAt: DateTime.now(),
    );

    if (kDebugMode) {
      print('Extension registered: $name (${_metadata[name]?.version})');
    }
  }

  /// Gets an extension service
  static T? getExtension<T extends Object>(String name) {
    final service = _extensions[name];
    if (service is T) {
      return service;
    }
    return null;
  }

  /// Gets all registered extensions
  static Map<String, dynamic> getAllExtensions() {
    return Map.unmodifiable(_extensions);
  }

  /// Gets extension metadata
  static ExtensionMetadata? getExtensionMetadata(String name) {
    return _metadata[name];
  }

  /// Gets all extension metadata
  static Map<String, ExtensionMetadata> getAllMetadata() {
    return Map.unmodifiable(_metadata);
  }

  /// Checks if an extension is registered
  static bool isExtensionRegistered(String name) {
    return _extensions.containsKey(name);
  }

  /// Unregisters an extension
  static void unregisterExtension(String name) {
    _extensions.remove(name);
    _metadata.remove(name);

    if (kDebugMode) {
      print('Extension unregistered: $name');
    }
  }

  /// Clears all extensions
  static void clearAllExtensions() {
    _extensions.clear();
    _metadata.clear();

    if (kDebugMode) {
      print('All extensions cleared');
    }
  }

  /// Validates extension dependencies
  static bool validateDependencies(String extensionName) {
    final metadata = _metadata[extensionName];
    if (metadata == null) return false;

    for (final dependency in metadata.dependencies) {
      if (!_extensions.containsKey(dependency)) {
        if (kDebugMode) {
          print(
            'Missing dependency: $dependency for extension: $extensionName',
          );
        }
        return false;
      }
    }

    return true;
  }

  /// Gets extensions by type
  static List<T> getExtensionsByType<T extends Object>() {
    return _extensions.values.whereType<T>().toList();
  }

  /// Gets extensions that implement a specific interface
  static List<T> getExtensionsImplementing<T extends Object>() {
    return _extensions.values
        .where((service) => service is T)
        .cast<T>()
        .toList();
  }
}

/// Metadata for extension services
class ExtensionMetadata {
  final String name;
  final String version;
  final String description;
  final List<String> dependencies;
  final DateTime registeredAt;

  const ExtensionMetadata({
    required this.name,
    required this.version,
    required this.description,
    required this.dependencies,
    required this.registeredAt,
  });

  @override
  String toString() {
    return 'ExtensionMetadata(name: $name, version: $version, description: $description, dependencies: $dependencies, registeredAt: $registeredAt)';
  }
}

/// Base class for extension services
abstract class ExtensionService {
  /// Gets the extension name
  String get name;

  /// Gets the extension version
  String get version;

  /// Gets the extension description
  String get description;

  /// Gets the required dependencies
  List<String> get dependencies;

  /// Initializes the extension
  Future<void> initialize();

  /// Disposes the extension
  Future<void> dispose();

  /// Checks if the extension is available
  bool get isAvailable;

  /// Gets the extension configuration
  Map<String, dynamic> get configuration;
}

/// Extension for multi-object comparison (future feature)
abstract class MultiObjectComparisonExtension extends ExtensionService {
  @override
  String get name => 'multi_object_comparison';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'Multi-object comparison and analysis';

  @override
  List<String> get dependencies => ['procrustes_service'];

  /// Compares multiple objects
  Future<MultiObjectComparisonResult> compareObjects(List<Object3D> objects);

  /// Gets similarity matrix
  Future<SimilarityMatrix> getSimilarityMatrix(List<Object3D> objects);

  /// Finds most similar objects
  Future<List<ObjectSimilarity>> findMostSimilar(
    Object3D referenceObject,
    List<Object3D> candidates,
  );
}

/// Extension for cloud sync (future feature)
abstract class CloudSyncExtension extends ExtensionService {
  @override
  String get name => 'cloud_sync';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'Cloud synchronization for objects and results';

  @override
  List<String> get dependencies => [];

  /// Uploads object to cloud
  Future<String> uploadObject(Object3D object);

  /// Downloads object from cloud
  Future<Object3D?> downloadObject(String cloudId);

  /// Syncs analysis results
  Future<void> syncResults(ProcrustesResult result);

  /// Gets cloud objects
  Future<List<Object3D>> getCloudObjects();

  /// Gets sync status
  Future<SyncStatus> getSyncStatus();
}

/// Extension for AI-based auto-alignment (future feature)
abstract class AIAlignmentExtension extends ExtensionService {
  @override
  String get name => 'ai_alignment';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'AI-based automatic object alignment';

  @override
  List<String> get dependencies => ['procrustes_service'];

  /// Performs AI-based alignment
  Future<ProcrustesResult> performAutoAlignment(
    Object3D objectA,
    Object3D objectB,
  );

  /// Gets alignment suggestions
  Future<List<AlignmentSuggestion>> getAlignmentSuggestions(
    Object3D objectA,
    Object3D objectB,
  );

  /// Trains the AI model
  Future<void> trainModel(List<TrainingData> trainingData);

  /// Gets model accuracy
  Future<double> getModelAccuracy();
}

/// Data classes for extensions
class MultiObjectComparisonResult {
  final List<Object3D> objects;
  final SimilarityMatrix similarityMatrix;
  final List<ObjectSimilarity> similarities;
  final DateTime computedAt;

  const MultiObjectComparisonResult({
    required this.objects,
    required this.similarityMatrix,
    required this.similarities,
    required this.computedAt,
  });
}

class SimilarityMatrix {
  final List<List<double>> matrix;
  final List<String> objectIds;

  const SimilarityMatrix({required this.matrix, required this.objectIds});
}

class ObjectSimilarity {
  final String objectId;
  final double similarityScore;
  final ProcrustesResult alignmentResult;

  const ObjectSimilarity({
    required this.objectId,
    required this.similarityScore,
    required this.alignmentResult,
  });
}

class SyncStatus {
  final bool isConnected;
  final DateTime lastSync;
  final int pendingUploads;
  final int pendingDownloads;
  final String? error;

  const SyncStatus({
    required this.isConnected,
    required this.lastSync,
    required this.pendingUploads,
    required this.pendingDownloads,
    this.error,
  });
}

class AlignmentSuggestion {
  final String description;
  final double confidence;
  final Map<String, dynamic> parameters;

  const AlignmentSuggestion({
    required this.description,
    required this.confidence,
    required this.parameters,
  });
}

class TrainingData {
  final Object3D objectA;
  final Object3D objectB;
  final ProcrustesResult expectedResult;

  const TrainingData({
    required this.objectA,
    required this.objectB,
    required this.expectedResult,
  });
}
