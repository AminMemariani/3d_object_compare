import 'package:vector_math/vector_math_64.dart';

/// Simple model representing a 3D object (MVVM pattern)
class ObjectModel {
  final String id;
  final String name;
  final String filePath;
  final String fileExtension;
  final Vector3 position;
  final Vector3 rotation;
  final Vector3 scale;
  final ColorRGB color;
  final double opacity;
  final DateTime createdAt;
  final DateTime lastModified;

  ObjectModel({
    required this.id,
    required this.name,
    required this.filePath,
    required this.fileExtension,
    Vector3? position,
    Vector3? rotation,
    Vector3? scale,
    ColorRGB? color,
    double? opacity,
    DateTime? createdAt,
    DateTime? lastModified,
  })  : position = position ?? Vector3.zero(),
        rotation = rotation ?? Vector3.zero(),
        scale = scale ?? Vector3(1, 1, 1),
        color = color ?? const ColorRGB(0.5, 0.5, 0.5),
        opacity = opacity ?? 1.0,
        createdAt = createdAt ?? _defaultDateTime,
        lastModified = lastModified ?? _defaultDateTime;

  static final DateTime _defaultDateTime = DateTime.now();

  ObjectModel copyWith({
    String? id,
    String? name,
    String? filePath,
    String? fileExtension,
    Vector3? position,
    Vector3? rotation,
    Vector3? scale,
    ColorRGB? color,
    double? opacity,
    DateTime? lastModified,
  }) {
    return ObjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      fileExtension: fileExtension ?? this.fileExtension,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      createdAt: createdAt,
      lastModified: lastModified ?? DateTime.now(),
    );
  }
}

/// Simple RGB color representation
class ColorRGB {
  final double red;
  final double green;
  final double blue;

  const ColorRGB(this.red, this.green, this.blue);
}

