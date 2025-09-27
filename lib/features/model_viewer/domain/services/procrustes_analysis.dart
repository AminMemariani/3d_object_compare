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
    // Normalize metrics to 0-1 scale
    final normalizedMean = math.exp(-meanDistance);
    final normalizedStd = math.exp(-standardDeviation);
    final normalizedRmse = math.exp(-rmse);

    // Weighted combination (RMSE is most important)
    final score =
        0.5 * normalizedRmse + 0.3 * normalizedMean + 0.2 * normalizedStd;

    // Convert to percentage
    return (score * 100).clamp(0.0, 100.0);
  }

  /// Simple SVD implementation for 3x3 matrices
  static SVDResult _computeSVD(Matrix3 matrix) {
    // Simplified SVD using eigenvalue decomposition
    // For production use, consider using a more robust SVD library

    // Compute A^T * A for eigenvalue decomposition
    final ata = Matrix3.zero();
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        double sum = 0.0;
        for (int k = 0; k < 3; k++) {
          sum += matrix.entry(k, i) * matrix.entry(k, j);
        }
        ata.setEntry(i, j, sum);
      }
    }

    // Find eigenvalues and eigenvectors (simplified)
    final eigenvalues = _findEigenvalues(ata);
    final eigenvectors = _findEigenvectors(ata, eigenvalues);

    // Sort by eigenvalue magnitude
    final sortedIndices = List.generate(3, (i) => i);
    sortedIndices.sort(
      (a, b) => eigenvalues[b].abs().compareTo(eigenvalues[a].abs()),
    );

    final U = Matrix3.zero();
    final V = Matrix3.zero();
    final S = Vector3.zero();

    for (int i = 0; i < 3; i++) {
      final idx = sortedIndices[i];
      S[i] = math.sqrt(eigenvalues[idx].abs());

      if (S[i] > _epsilon) {
        V.setColumn(i, eigenvectors[idx]);
        U.setColumn(i, (matrix * eigenvectors[idx]) / S[i]);
      }
    }

    return SVDResult(U: U, S: S, V: V);
  }

  /// Find eigenvalues of a 3x3 matrix (simplified)
  static List<double> _findEigenvalues(Matrix3 matrix) {
    // Characteristic polynomial: det(A - λI) = 0
    // For 3x3 matrix: λ³ - tr(A)λ² + (tr(A²) - tr(A)²)/2 λ - det(A) = 0

    final trace = matrix.entry(0, 0) + matrix.entry(1, 1) + matrix.entry(2, 2);
    final det = matrix.determinant();

    // Simplified: assume one eigenvalue is dominant
    final eigenvalues = <double>[];

    // Use power iteration to find dominant eigenvalue
    var vector = Vector3.random();
    vector.normalize();

    for (int i = 0; i < _maxIterations; i++) {
      final newVector = matrix * vector;
      final eigenvalue = newVector.length;
      newVector.normalize();

      if ((newVector - vector).length < _epsilon) {
        eigenvalues.add(eigenvalue);
        break;
      }

      vector = newVector;
    }

    // Add remaining eigenvalues (simplified)
    if (eigenvalues.length < 3) {
      eigenvalues.add(trace / 3.0);
      eigenvalues.add(det / (eigenvalues[0] * eigenvalues[1]));
    }

    return eigenvalues;
  }

  /// Find eigenvectors corresponding to eigenvalues
  static List<Vector3> _findEigenvectors(
    Matrix3 matrix,
    List<double> eigenvalues,
  ) {
    final eigenvectors = <Vector3>[];

    for (final eigenvalue in eigenvalues) {
      // Solve (A - λI)v = 0
      final aMinusLambdaI = matrix.clone();
      aMinusLambdaI.setEntry(0, 0, aMinusLambdaI.entry(0, 0) - eigenvalue);
      aMinusLambdaI.setEntry(1, 1, aMinusLambdaI.entry(1, 1) - eigenvalue);
      aMinusLambdaI.setEntry(2, 2, aMinusLambdaI.entry(2, 2) - eigenvalue);

      // Find null space (simplified)
      final eigenvector = _findNullSpace(aMinusLambdaI);
      eigenvectors.add(eigenvector);
    }

    return eigenvectors;
  }

  /// Find null space of a matrix (simplified)
  static Vector3 _findNullSpace(Matrix3 matrix) {
    // Use cross product of first two rows to find null space
    final row0 = Vector3(
      matrix.entry(0, 0),
      matrix.entry(0, 1),
      matrix.entry(0, 2),
    );
    final row1 = Vector3(
      matrix.entry(1, 0),
      matrix.entry(1, 1),
      matrix.entry(1, 2),
    );

    final nullVector = row0.cross(row1);

    if (nullVector.length < _epsilon) {
      // Fallback to random vector
      return Vector3.random()..normalize();
    }

    return nullVector..normalize();
  }
}

/// Result of Singular Value Decomposition
class SVDResult {
  final Matrix3 U;
  final Vector3 S;
  final Matrix3 V;

  const SVDResult({required this.U, required this.S, required this.V});
}
