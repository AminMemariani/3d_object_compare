import 'package:equatable/equatable.dart';

class Model3D extends Equatable {
  final String id;
  final String name;
  final String path;
  final String? thumbnailPath;
  final double scale;
  final bool autoRotate;
  final String backgroundColor;
  final DateTime createdAt;

  const Model3D({
    required this.id,
    required this.name,
    required this.path,
    this.thumbnailPath,
    this.scale = 1.0,
    this.autoRotate = true,
    this.backgroundColor = '#FFFFFF',
    required this.createdAt,
  });

  Model3D copyWith({
    String? id,
    String? name,
    String? path,
    String? thumbnailPath,
    double? scale,
    bool? autoRotate,
    String? backgroundColor,
    DateTime? createdAt,
  }) {
    return Model3D(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      scale: scale ?? this.scale,
      autoRotate: autoRotate ?? this.autoRotate,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    path,
    thumbnailPath,
    scale,
    autoRotate,
    backgroundColor,
    createdAt,
  ];
}
