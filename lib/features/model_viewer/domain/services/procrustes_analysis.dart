import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';
import '../entities/procrustes_result.dart';

class ProcrustesAnalysis {
  static const double _epsilon = 1e-10;
  static const int _maxIterations = 100;

  /// Performs Procrustes superimposition to optimally align two sets of 3D points
  ///
  /// [pointsA] - Reference points (target)
  /// [pointsB] - Points to be aligned (source)
  ///
  /// Returns [ProcrustesResult] containing transformation parameters and metrics
  static ProcrustesResult align(List<Vector3> pointsA, List<Vector3> pointsB) {
    if (pointsA.length != pointsB.length) {
      throw ArgumentError('Point sets must have the same number of points');
    }

    if (pointsA.length < 3) {
      throw ArgumentError(
        'At least 3 points are required for Procrustes analysis',
      );
    }

    final n = pointsA.length;

    // Step 1: Center both point sets
    final centeredA = _centerPoints(pointsA);
    final centeredB = _centerPoints(pointsB);

    // Step 2: Compute initial scale factors
    final scaleA = _computeScale(centeredA);
    final scaleB = _computeScale(centeredB);

    // Step 3: Normalize by scale
    final normalizedA = _normalizeByScale(centeredA, scaleA);
    final normalizedB = _normalizeByScale(centeredB, scaleB);

    // Step 4: Compute optimal rotation using SVD
    final rotation = _computeOptimalRotation(normalizedA, normalizedB);

    // Step 5: Compute optimal scale
    final scale = _computeOptimalScale(normalizedA, normalizedB, rotation);

    // Step 6: Compute translation
    final translation = _computeTranslation(pointsA, pointsB, rotation, scale);

    // Step 7: Apply transformation and compute metrics
    final transformedB = _applyTransformation(
      pointsB,
      translation,
      rotation,
      scale,
    );
    final metrics = _computeMetrics(pointsA, transformedB);

    return ProcrustesResult(
      translation: translation,
      rotation: rotation,
      scale: scale,
      similarityScore: metrics.similarityScore,
      minimumDistance: metrics.minimumDistance,
      standardDeviation: metrics.standardDeviation,
      rootMeanSquareError: metrics.rootMeanSquareError,
      numberOfPoints: n,
      computedAt: DateTime.now(),
    );
  }

  /// Centers a set of points by subtracting the centroid
  static List<Vector3> _centerPoints(List<Vector3> points) {
    final centroid = _computeCentroid(points);
    return points.map((point) => point - centroid).toList();
  }

  /// Computes the centroid of a set of points
  static Vector3 _computeCentroid(List<Vector3> points) {
    final sum = points.fold<Vector3>(
      Vector3.zero(),
      (sum, point) => sum + point,
    );
    return sum / points.length.toDouble();
  }

  /// Computes the scale factor for a set of centered points
  static double _computeScale(List<Vector3> centeredPoints) {
    final sumSquared = centeredPoints.fold<double>(
      0.0,
      (sum, point) => sum + point.length2,
    );
    return math.sqrt(sumSquared / centeredPoints.length);
  }

  /// Normalizes points by dividing by the scale factor
  static List<Vector3> _normalizeByScale(List<Vector3> points, double scale) {
    if (scale < _epsilon) return points;
    return points.map((point) => point / scale).toList();
  }

  /// Computes the optimal rotation matrix using Singular Value Decomposition
  static Matrix3 _computeOptimalRotation(
    List<Vector3> pointsA,
    List<Vector3> pointsB,
  ) {
    // Compute the cross-covariance matrix H
    final H = _computeCrossCovarianceMatrix(pointsA, pointsB);

    // Perform SVD: H = U * S * V^T
    final svd = _computeSVD(H);

    // Compute rotation matrix: R = V * U^T
    final rotation = Matrix3.zero();
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        double sum = 0.0;
        for (int k = 0; k < 3; k++) {
          sum += svd.V.entry(i, k) * svd.U.entry(j, k);
        }
        rotation.setEntry(i, j, sum);
      }
    }

    // Ensure proper rotation (det(R) = 1)
    if (rotation.determinant() < 0) {
      // Flip the last column of V
      final V = svd.V.clone();
      final lastColumn = V.getColumn(2);
      final flippedColumn = -lastColumn;
      V.setColumn(2, flippedColumn);
      final flippedRotation = Matrix3.zero();
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          double sum = 0.0;
          for (int k = 0; k < 3; k++) {
            sum += V.entry(i, k) * svd.U.entry(j, k);
          }
          flippedRotation.setEntry(i, j, sum);
        }
      }
      return flippedRotation;
    }

    return rotation;
  }

  /// Computes the cross-covariance matrix H = A^T * B
  static Matrix3 _computeCrossCovarianceMatrix(
    List<Vector3> pointsA,
    List<Vector3> pointsB,
  ) {
    final H = Matrix3.zero();

    for (int i = 0; i < pointsA.length; i++) {
      final a = pointsA[i];
      final b = pointsB[i];

      // Add outer product a * b^T to H
      H.setEntry(0, 0, H.entry(0, 0) + a.x * b.x);
      H.setEntry(0, 1, H.entry(0, 1) + a.x * b.y);
      H.setEntry(0, 2, H.entry(0, 2) + a.x * b.z);
      H.setEntry(1, 0, H.entry(1, 0) + a.y * b.x);
      H.setEntry(1, 1, H.entry(1, 1) + a.y * b.y);
      H.setEntry(1, 2, H.entry(1, 2) + a.y * b.z);
      H.setEntry(2, 0, H.entry(2, 0) + a.z * b.x);
      H.setEntry(2, 1, H.entry(2, 1) + a.z * b.y);
      H.setEntry(2, 2, H.entry(2, 2) + a.z * b.z);
    }

    return H;
  }

  /// Computes the optimal scale factor
  static double _computeOptimalScale(
    List<Vector3> pointsA,
    List<Vector3> pointsB,
    Matrix3 rotation,
  ) {
    double numerator = 0.0;
    double denominator = 0.0;

    for (int i = 0; i < pointsA.length; i++) {
      final rotatedB = rotation * pointsB[i];
      numerator += pointsA[i].dot(rotatedB);
      denominator += pointsB[i].length2;
    }

    return denominator > _epsilon ? numerator / denominator : 1.0;
  }

  /// Computes the optimal translation vector
  static Vector3 _computeTranslation(
    List<Vector3> pointsA,
    List<Vector3> pointsB,
    Matrix3 rotation,
    double scale,
  ) {
    final centroidA = _computeCentroid(pointsA);
    final centroidB = _computeCentroid(pointsB);

    return centroidA - (rotation * centroidB) * scale;
  }

  /// Applies the computed transformation to a set of points
  static List<Vector3> _applyTransformation(
    List<Vector3> points,
    Vector3 translation,
    Matrix3 rotation,
    double scale,
  ) {
    return points.map((point) {
      return translation + (rotation * point) * scale;
    }).toList();
  }

  /// Computes similarity metrics between two sets of points
  static ProcrustesMetrics _computeMetrics(
    List<Vector3> pointsA,
    List<Vector3> pointsB,
  ) {
    final distances = <double>[];
    double sumSquaredDistances = 0.0;
    double minDistance = double.infinity;
    double maxDistance = 0.0;

    for (int i = 0; i < pointsA.length; i++) {
      final distance = (pointsA[i] - pointsB[i]).length;
      distances.add(distance);
      sumSquaredDistances += distance * distance;
      minDistance = math.min(minDistance, distance);
      maxDistance = math.max(maxDistance, distance);
    }

    final meanDistance =
        distances.fold<double>(0.0, (sum, d) => sum + d) / distances.length;
    final rootMeanSquareError = math.sqrt(
      sumSquaredDistances / distances.length,
    );

    // Compute standard deviation
    final variance =
        distances.fold<double>(
          0.0,
          (sum, d) => sum + math.pow(d - meanDistance, 2),
        ) /
        distances.length;
    final standardDeviation = math.sqrt(variance);

    // Compute similarity score (0-100, higher is better)
    final similarityScore = _computeSimilarityScore(
      meanDistance,
      standardDeviation,
      rootMeanSquareError,
    );

    return ProcrustesMetrics(
      similarityScore: similarityScore,
      minimumDistance: minDistance,
      standardDeviation: standardDeviation,
      rootMeanSquareError: rootMeanSquareError,
      meanDistance: meanDistance,
      maxDistance: maxDistance,
      numberOfPoints: pointsA.length,
    );
  }

  /// Computes a similarity score based on alignment quality
  static double _computeSimilarityScore(
    double meanDistance,
    double standardDeviation,
    double rmse,
  ) {
    // Use a more reasonable scoring function
    // For perfect alignment (distance = 0), score should be 100%
    // For small distances, score should be high
    // For large distances, score should be low
    
    // Handle perfect alignment
    if (rmse < 1e-10) return 100.0;
    
    // Use a logarithmic scale for better scoring
    // This gives high scores for small distances and reasonable scores for larger ones
    final logScore =
        -math.log(rmse + 1e-10) / math.ln10; // Convert to log10 scale

    // Normalize to 0-100 scale
    // log10(0.001) ≈ -3, log10(0.1) ≈ -1, log10(1.0) = 0
    final normalizedScore = (logScore + 3) / 3 * 100; // Map [-3, 0] to [0, 100]

    // Clamp to valid range and ensure minimum reasonable score
    final score = normalizedScore.clamp(0.0, 100.0);

    // For very small distances, ensure high scores
    if (rmse < 0.001) return math.max(score, 99.0);
    if (rmse < 0.01) return math.max(score, 95.0);
    if (rmse < 0.1) return math.max(score, 85.0);

    return score;
  }

  /// Simple SVD implementation for 3x3 matrices using power iteration
  static SVDResult _computeSVD(Matrix3 matrix) {
    // Use a more robust approach for 3x3 SVD
    // This is a simplified but more reliable implementation
    
    final U = Matrix3.zero();
    final V = Matrix3.zero();
    final S = Vector3.zero();

    // For 3x3 matrices, we can use a more direct approach
    // Compute H^T * H for eigenvalue decomposition
    final hth = Matrix3.zero();
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        double sum = 0.0;
        for (int k = 0; k < 3; k++) {
          sum += matrix.entry(k, i) * matrix.entry(k, j);
        }
        hth.setEntry(i, j, sum);
      }
    }
    
    // Use power iteration to find the dominant eigenvalue/eigenvector
    var v = Vector3(1.0, 0.0, 0.0);
    for (int iter = 0; iter < _maxIterations; iter++) {
      final newV = hth * v;
      final norm = newV.length;
      if (norm < _epsilon) break;
      v = newV / norm;
    }
    
    // First singular value and vector
    final sigma1 = math.sqrt((hth * v).length);
    S[0] = sigma1;
    V.setColumn(0, v);
    
    if (sigma1 > _epsilon) {
      U.setColumn(0, (matrix * v) / sigma1);
    } else {
      U.setColumn(0, Vector3(1.0, 0.0, 0.0));
    }
    
    // For the remaining singular values, use a simplified approach
    // Create orthogonal vectors
    final v2 = _orthogonalize(Vector3(0.0, 1.0, 0.0), v);
    final v3 = v.cross(v2);
    
    final sigma2 = math.sqrt((hth * v2).length);
    final sigma3 = math.sqrt((hth * v3).length);
    
    S[1] = sigma2;
    S[2] = sigma3;
    
    V.setColumn(1, v2);
    V.setColumn(2, v3);
    
    if (sigma2 > _epsilon) {
      U.setColumn(1, (matrix * v2) / sigma2);
    } else {
      U.setColumn(1, Vector3(0.0, 1.0, 0.0));
    }
    
    if (sigma3 > _epsilon) {
      U.setColumn(2, (matrix * v3) / sigma3);
    } else {
      U.setColumn(2, Vector3(0.0, 0.0, 1.0));
    }
    
    return SVDResult(U: U, S: S, V: V);
  }
  
  /// Helper method to orthogonalize a vector against another
  static Vector3 _orthogonalize(Vector3 v, Vector3 against) {
    final projection = v.dot(against) / against.length2;
    return (v - against * projection)..normalize();
  }

}

/// Result of Singular Value Decomposition
class SVDResult {
  final Matrix3 U;
  final Vector3 S;
  final Matrix3 V;

  const SVDResult({required this.U, required this.S, required this.V});
}
