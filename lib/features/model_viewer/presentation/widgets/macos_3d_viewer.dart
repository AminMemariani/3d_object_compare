import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../../domain/entities/object_3d.dart';

/// macOS-specific 3D viewer using CustomPainter for native rendering
/// Supports all file formats that have parsed vertices
class MacOS3DViewer extends StatefulWidget {
  final Object3D object;
  final Color backgroundColor;

  const MacOS3DViewer({
    super.key,
    required this.object,
    this.backgroundColor = Colors.grey,
  });

  @override
  State<MacOS3DViewer> createState() => _MacOS3DViewerState();
}

class _MacOS3DViewerState extends State<MacOS3DViewer> {
  double _rotationX = -0.5;
  double _rotationY = 0.5;
  double _zoom = 1.0;
  Offset? _lastPanPosition;
  bool _isLoading = true;
  List<vm.Vector3>? _vertices;

  @override
  void initState() {
    super.initState();
    _loadVertices();
  }

  void _loadVertices() {
    setState(() {
      _isLoading = true;
    });

    // Use vertices from object if available
    if (widget.object.vertices != null && widget.object.vertices!.isNotEmpty) {
      setState(() {
        _vertices = widget.object.vertices;
        _isLoading = false;
      });
    } else {
      // No vertices available - show error
      setState(() {
        _vertices = null;
        _isLoading = false;
      });
    }
  }

  void _handlePanStart(DragStartDetails details) {
    _lastPanPosition = details.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_lastPanPosition != null) {
      final delta = details.localPosition - _lastPanPosition!;
      setState(() {
        _rotationY += delta.dx * 0.01;
        _rotationX += delta.dy * 0.01;
        _rotationX = _rotationX.clamp(-math.pi / 2, math.pi / 2);
      });
      _lastPanPosition = details.localPosition;
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _lastPanPosition = null;
  }

  void _handleScroll(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      setState(() {
        _zoom -= event.scrollDelta.dy * 0.001;
        _zoom = _zoom.clamp(0.1, 5.0);
      });
    }
  }

  @override
  void didUpdateWidget(MacOS3DViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reload vertices if object changed
    if (oldWidget.object != widget.object) {
      _loadVertices();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: widget.backgroundColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Loading 3D model...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                widget.object.name,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_vertices == null || _vertices!.isEmpty) {
      return Container(
        color: widget.backgroundColor,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[300],
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'No Vertex Data Available',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  'This file was loaded but no vertex data was parsed. '
                  'The file may be empty or in an unsupported format.',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: widget.backgroundColor,
      child: Listener(
        onPointerSignal: _handleScroll,
        child: GestureDetector(
          onPanStart: _handlePanStart,
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          child: Stack(
            children: [
              // 3D Renderer
              CustomPaint(
                painter: _Simple3DPainter(
                  vertices: _vertices!,
                  rotationX: _rotationX,
                  rotationY: _rotationY,
                  zoom: _zoom,
                  objectColor: Color.fromRGBO(
                    (widget.object.color.red * 255).toInt(),
                    (widget.object.color.green * 255).toInt(),
                    (widget.object.color.blue * 255).toInt(),
                    widget.object.opacity,
                  ),
                ),
                size: Size.infinite,
              ),

              // Info overlay
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.view_in_ar_rounded,
                        color: Colors.green[300],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'macOS Native Rendering (${_vertices!.length} vertices)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Controls hint
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mouse,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Drag to rotate • Scroll to zoom',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple 3D painter that renders vertices as a point cloud with depth-based sizing
class _Simple3DPainter extends CustomPainter {
  final List<vm.Vector3> vertices;
  final double rotationX;
  final double rotationY;
  final double zoom;
  final Color objectColor;

  _Simple3DPainter({
    required this.vertices,
    required this.rotationX,
    required this.rotationY,
    required this.zoom,
    required this.objectColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Calculate bounding box to normalize the model
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;
    double minZ = double.infinity, maxZ = double.negativeInfinity;

    for (final vertex in vertices) {
      minX = math.min(minX, vertex.x);
      maxX = math.max(maxX, vertex.x);
      minY = math.min(minY, vertex.y);
      maxY = math.max(maxY, vertex.y);
      minZ = math.min(minZ, vertex.z);
      maxZ = math.max(maxZ, vertex.z);
    }

    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;
    final centerZ = (minZ + maxZ) / 2;
    final scale = math.max(maxX - minX, math.max(maxY - minY, maxZ - minZ));
    final normalizedScale = scale > 0 ? 200 / scale : 1.0;

    // Transform and project vertices
    final projectedPoints = <_ProjectedPoint>[];

    for (final vertex in vertices) {
      // Center and normalize the vertex
      var x = (vertex.x - centerX) * normalizedScale;
      var y = (vertex.y - centerY) * normalizedScale;
      var z = (vertex.z - centerZ) * normalizedScale;

      // Apply rotation around X axis
      final cosX = math.cos(rotationX);
      final sinX = math.sin(rotationX);
      final y1 = y * cosX - z * sinX;
      final z1 = y * sinX + z * cosX;
      y = y1;
      z = z1;

      // Apply rotation around Y axis
      final cosY = math.cos(rotationY);
      final sinY = math.sin(rotationY);
      final x1 = x * cosY + z * sinY;
      final z2 = -x * sinY + z * cosY;
      x = x1;
      z = z2;

      // Apply zoom
      x *= zoom;
      y *= zoom;
      z *= zoom;

      // Simple perspective projection
      final perspective = 500 / (500 + z);
      final screenX = center.dx + x * perspective;
      final screenY = center.dy - y * perspective;

      projectedPoints.add(
        _ProjectedPoint(Offset(screenX, screenY), z, perspective),
      );
    }

    // Sort by depth (back to front)
    projectedPoints.sort((a, b) => a.z.compareTo(b.z));

    // Draw points
    for (final point in projectedPoints) {
      // Vary point size based on depth
      final pointSize = (1.5 + point.perspective * 1.5).clamp(1.0, 4.0);

      // Vary alpha based on depth for better 3D effect
      final alpha = (0.3 + point.perspective * 0.7).clamp(0.3, 1.0);

      final paint = Paint()
        ..color = objectColor.withValues(alpha: alpha * objectColor.a)
        ..strokeWidth = pointSize
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(point.offset, pointSize / 2, paint);
    }
  }

  @override
  bool shouldRepaint(_Simple3DPainter oldDelegate) {
    return oldDelegate.rotationX != rotationX ||
        oldDelegate.rotationY != rotationY ||
        oldDelegate.zoom != zoom ||
        oldDelegate.vertices != vertices ||
        oldDelegate.objectColor != objectColor;
  }
}

class _ProjectedPoint {
  final Offset offset;
  final double z;
  final double perspective;

  _ProjectedPoint(this.offset, this.z, this.perspective);
}
