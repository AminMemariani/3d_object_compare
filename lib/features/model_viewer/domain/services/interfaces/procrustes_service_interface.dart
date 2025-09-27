import 'package:vector_math/vector_math_64.dart';
import '../../entities/object_3d.dart';
import '../../entities/procrustes_result.dart';

/// Interface for Procrustes analysis services
abstract class ProcrustesServiceInterface {
  /// Aligns two 3D objects using Procrustes superimposition
  Future<ProcrustesResult> alignObjects(Object3D objectA, Object3D objectB);

  /// Aligns two sets of 3D points using Procrustes superimposition
  ProcrustesResult alignPoints(List<Vector3> pointsA, List<Vector3> pointsB);

  /// Applies Procrustes transformation to an object
  Object3D applyTransformation(Object3D object, ProcrustesResult result);

  /// Computes similarity metrics between two objects
  ProcrustesMetrics computeSimilarity(Object3D objectA, Object3D objectB);

  /// Generates sample points for a 3D object
  List<Vector3> generateObjectPoints(Object3D object);
}

/// Interface for object loading services
abstract class ObjectLoaderServiceInterface {
  /// Loads a 3D object from file
  Future<Object3D?> loadObjectFromFile(String filePath);

  /// Validates if file format is supported
  bool isSupportedFormat(String fileExtension);

  /// Gets list of supported file extensions
  List<String> getSupportedExtensions();
}

/// Interface for export services
abstract class ExportServiceInterface {
  /// Exports results as JSON
  Future<String> exportAsJson(
    ProcrustesResult result,
    Object3D objectA,
    Object3D objectB,
  );

  /// Exports results as CSV
  Future<String> exportAsCsv(
    ProcrustesResult result,
    Object3D objectA,
    Object3D objectB,
  );

  /// Saves content to file
  Future<String> saveToFile(String content, String filename);

  /// Shares a file
  Future<void> shareFile(String filePath, String subject);
}

/// Interface for cloud sync services (future extension)
abstract class CloudSyncServiceInterface {
  /// Uploads object to cloud
  Future<String> uploadObject(Object3D object);

  /// Downloads object from cloud
  Future<Object3D?> downloadObject(String cloudId);

  /// Syncs analysis results to cloud
  Future<void> syncResults(ProcrustesResult result);

  /// Gets list of cloud objects
  Future<List<Object3D>> getCloudObjects();
}

/// Interface for AI-based auto-alignment services (future extension)
abstract class AIAlignmentServiceInterface {
  /// Performs AI-based auto-alignment
  Future<ProcrustesResult> performAutoAlignment(
    Object3D objectA,
    Object3D objectB,
  );

  /// Gets alignment suggestions
  Future<List<AlignmentSuggestion>> getAlignmentSuggestions(
    Object3D objectA,
    Object3D objectB,
  );

  /// Trains the AI model with new data
  Future<void> trainModel(List<TrainingData> trainingData);
}

/// Interface for multi-object comparison services (future extension)
abstract class MultiObjectComparisonServiceInterface {
  /// Compares multiple objects
  Future<MultiObjectComparisonResult> compareObjects(List<Object3D> objects);

  /// Gets similarity matrix for multiple objects
  Future<SimilarityMatrix> getSimilarityMatrix(List<Object3D> objects);

  /// Finds most similar objects
  Future<List<ObjectSimilarity>> findMostSimilar(
    Object3D referenceObject,
    List<Object3D> candidates,
  );
}

/// Data classes for future extensions
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
