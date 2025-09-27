import 'package:equatable/equatable.dart';
import 'package:vector_math/vector_math_64.dart';

/// Represents 3D camera controls for navigation
class CameraControls extends Equatable {
  final Vector3 position;
  final Vector3 target;
  final double zoom;
  final double rotationX;
  final double rotationY;
  final double rotationZ;
  final bool isOrbiting;
  final bool isZooming;
  final bool isPanning;

  CameraControls({
    Vector3? position,
    Vector3? target,
    this.zoom = 1.0,
    this.rotationX = 0.0,
    this.rotationY = 0.0,
    this.rotationZ = 0.0,
    this.isOrbiting = false,
    this.isZooming = false,
    this.isPanning = false,
  }) : position = position ?? Vector3(0, 0, 5),
       target = target ?? Vector3(0, 0, 0);

  CameraControls copyWith({
    Vector3? position,
    Vector3? target,
    double? zoom,
    double? rotationX,
    double? rotationY,
    double? rotationZ,
    bool? isOrbiting,
    bool? isZooming,
    bool? isPanning,
  }) {
    return CameraControls(
      position: position ?? this.position,
      target: target ?? this.target,
      zoom: zoom ?? this.zoom,
      rotationX: rotationX ?? this.rotationX,
      rotationY: rotationY ?? this.rotationY,
      rotationZ: rotationZ ?? this.rotationZ,
      isOrbiting: isOrbiting ?? this.isOrbiting,
      isZooming: isZooming ?? this.isZooming,
      isPanning: isPanning ?? this.isPanning,
    );
  }

  /// Resets camera to default position
  CameraControls reset() {
    return CameraControls();
  }

  /// Zooms in by the specified factor
  CameraControls zoomIn(double factor) {
    return copyWith(zoom: (zoom * factor).clamp(0.1, 10.0));
  }

  /// Zooms out by the specified factor
  CameraControls zoomOut(double factor) {
    return copyWith(zoom: (zoom / factor).clamp(0.1, 10.0));
  }

  /// Rotates the camera around the target
  CameraControls orbit(double deltaX, double deltaY) {
    final newRotationX = (rotationX + deltaY).clamp(-89.0, 89.0);
    final newRotationY = (rotationY + deltaX) % 360.0;

    return copyWith(rotationX: newRotationX, rotationY: newRotationY);
  }

  /// Pans the camera
  CameraControls pan(double deltaX, double deltaY) {
    final panSpeed = 0.01;
    final right = Vector3(1, 0, 0);
    final up = Vector3(0, 1, 0);

    final panVector = (right * deltaX + up * deltaY) * panSpeed;

    return copyWith(position: position + panVector, target: target + panVector);
  }

  /// Gets the view matrix for rendering
  Matrix4 getViewMatrix() {
    final rotationMatrix = Matrix4.identity();
    rotationMatrix.rotateX(radians(rotationX));
    rotationMatrix.rotateY(radians(rotationY));
    rotationMatrix.rotateZ(radians(rotationZ));

    final rotatedPosition = rotationMatrix.transform3(Vector3(0, 0, 5 * zoom));
    final finalPosition = target + rotatedPosition;

    return makeViewMatrix(finalPosition, target, Vector3(0, 1, 0));
  }

  /// Gets the projection matrix
  Matrix4 getProjectionMatrix(double aspectRatio) {
    return makePerspectiveMatrix(radians(45.0), aspectRatio, 0.1, 1000.0);
  }

  @override
  List<Object?> get props => [
    position,
    target,
    zoom,
    rotationX,
    rotationY,
    rotationZ,
    isOrbiting,
    isZooming,
    isPanning,
  ];
}

/// Gesture types for 3D navigation
enum GestureType { orbit, zoom, pan, none }

/// Gesture data for 3D navigation
class GestureData extends Equatable {
  final GestureType type;
  final double deltaX;
  final double deltaY;
  final double scale;
  final DateTime timestamp;

  const GestureData({
    required this.type,
    this.deltaX = 0.0,
    this.deltaY = 0.0,
    this.scale = 1.0,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [type, deltaX, deltaY, scale, timestamp];
}
