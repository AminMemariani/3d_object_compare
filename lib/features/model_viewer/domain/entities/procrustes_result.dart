import 'package:equatable/equatable.dart';
import 'package:vector_math/vector_math_64.dart';

class ProcrustesResult extends Equatable {
  final Vector3 translation;
  final Matrix3 rotation;
  final double scale;
  final double similarityScore;
  final double minimumDistance;
  final double standardDeviation;
  final double rootMeanSquareError;
  final int numberOfPoints;
  final DateTime computedAt;

  const ProcrustesResult({
    required this.translation,
    required this.rotation,
    required this.scale,
    required this.similarityScore,
    required this.minimumDistance,
    required this.standardDeviation,
    required this.rootMeanSquareError,
    required this.numberOfPoints,
    required this.computedAt,
  });

  @override
  List<Object> get props => [
    translation,
    rotation,
    scale,
    similarityScore,
    minimumDistance,
    standardDeviation,
    rootMeanSquareError,
    numberOfPoints,
    computedAt,
  ];

  Map<String, dynamic> toJson() {
    return {
      'translation': {
        'x': translation.x,
        'y': translation.y,
        'z': translation.z,
      },
      'rotation': {
        'm00': rotation.entry(0, 0),
        'm01': rotation.entry(0, 1),
        'm02': rotation.entry(0, 2),
        'm10': rotation.entry(1, 0),
        'm11': rotation.entry(1, 1),
        'm12': rotation.entry(1, 2),
        'm20': rotation.entry(2, 0),
        'm21': rotation.entry(2, 1),
        'm22': rotation.entry(2, 2),
      },
      'scale': scale,
      'similarityScore': similarityScore,
      'minimumDistance': minimumDistance,
      'standardDeviation': standardDeviation,
      'rootMeanSquareError': rootMeanSquareError,
      'numberOfPoints': numberOfPoints,
      'computedAt': computedAt.toIso8601String(),
    };
  }

  factory ProcrustesResult.fromJson(Map<String, dynamic> json) {
    final translationJson = json['translation'] as Map<String, dynamic>;
    final rotationJson = json['rotation'] as Map<String, dynamic>;

    return ProcrustesResult(
      translation: Vector3(
        translationJson['x'] as double,
        translationJson['y'] as double,
        translationJson['z'] as double,
      ),
      rotation: Matrix3(
        rotationJson['m00'] as double,
        rotationJson['m01'] as double,
        rotationJson['m02'] as double,
        rotationJson['m10'] as double,
        rotationJson['m11'] as double,
        rotationJson['m12'] as double,
        rotationJson['m20'] as double,
        rotationJson['m21'] as double,
        rotationJson['m22'] as double,
      ),
      scale: json['scale'] as double,
      similarityScore: json['similarityScore'] as double,
      minimumDistance: json['minimumDistance'] as double,
      standardDeviation: json['standardDeviation'] as double,
      rootMeanSquareError: json['rootMeanSquareError'] as double,
      numberOfPoints: json['numberOfPoints'] as int,
      computedAt: DateTime.parse(json['computedAt'] as String),
    );
  }
}

class ProcrustesMetrics extends Equatable {
  final double similarityScore;
  final double minimumDistance;
  final double standardDeviation;
  final double rootMeanSquareError;
  final double meanDistance;
  final double maxDistance;
  final int numberOfPoints;

  const ProcrustesMetrics({
    required this.similarityScore,
    required this.minimumDistance,
    required this.standardDeviation,
    required this.rootMeanSquareError,
    required this.meanDistance,
    required this.maxDistance,
    required this.numberOfPoints,
  });

  @override
  List<Object> get props => [
    similarityScore,
    minimumDistance,
    standardDeviation,
    rootMeanSquareError,
    meanDistance,
    maxDistance,
    numberOfPoints,
  ];

  String get qualityDescription {
    if (similarityScore >= 95) return 'Excellent';
    if (similarityScore >= 85) return 'Very Good';
    if (similarityScore >= 75) return 'Good';
    if (similarityScore >= 60) return 'Fair';
    return 'Poor';
  }

  String get alignmentStatus {
    if (rootMeanSquareError <= 0.1) return 'Excellent Alignment';
    if (rootMeanSquareError <= 0.5) return 'Good Alignment';
    if (rootMeanSquareError <= 1.0) return 'Fair Alignment';
    return 'Poor Alignment';
  }
}
