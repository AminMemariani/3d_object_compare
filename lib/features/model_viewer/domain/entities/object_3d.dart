import 'package:equatable/equatable.dart';
import 'package:vector_math/vector_math_64.dart';

class Object3D extends Equatable {
  final String id;
  final String name;
  final String filePath;
  final String fileExtension;
  final Vector3 position;
  final Vector3 rotation;
  final Vector3 scale;
  final Color3D color;
  final double opacity;
  final DateTime createdAt;
  final DateTime lastModified;

  Object3D({
    required this.id,
    required this.name,
    required this.filePath,
    required this.fileExtension,
    Vector3? position,
    Vector3? rotation,
    Vector3? scale,
    this.color = const Color3D(1, 0, 0),
    this.opacity = 1.0,
    required this.createdAt,
    required this.lastModified,
  }) : position = position ?? Vector3.zero(),
       rotation = rotation ?? Vector3.zero(),
       scale = scale ?? Vector3.all(1.0);

  Object3D copyWith({
    String? id,
    String? name,
    String? filePath,
    String? fileExtension,
    Vector3? position,
    Vector3? rotation,
    Vector3? scale,
    Color3D? color,
    double? opacity,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return Object3D(
      id: id ?? this.id,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      fileExtension: fileExtension ?? this.fileExtension,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  List<Object> get props => [
    id,
    name,
    filePath,
    fileExtension,
    position,
    rotation,
    scale,
    color,
    opacity,
    createdAt,
    lastModified,
  ];
}

class Color3D extends Equatable {
  final double red;
  final double green;
  final double blue;

  const Color3D(this.red, this.green, this.blue);

  Color3D copyWith({double? red, double? green, double? blue}) {
    return Color3D(red ?? this.red, green ?? this.green, blue ?? this.blue);
  }

  @override
  List<Object> get props => [red, green, blue];
}

class ObjectTransform extends Equatable {
  final Vector3 position;
  final Vector3 rotation;
  final Vector3 scale;

  ObjectTransform({Vector3? position, Vector3? rotation, Vector3? scale})
    : position = position ?? Vector3.zero(),
      rotation = rotation ?? Vector3.zero(),
      scale = scale ?? Vector3.all(1.0);

  ObjectTransform copyWith({
    Vector3? position,
    Vector3? rotation,
    Vector3? scale,
  }) {
    return ObjectTransform(
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
    );
  }

  @override
  List<Object> get props => [position, rotation, scale];
}
