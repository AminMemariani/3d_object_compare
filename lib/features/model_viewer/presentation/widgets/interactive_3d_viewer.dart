import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import '../../domain/entities/camera_controls.dart';
import '../../domain/entities/object_3d.dart';

/// Interactive 3D viewer with gesture controls
class Interactive3DViewer extends StatefulWidget {
  final Object3D? objectA;
  final Object3D? objectB;
  final CameraControls cameraControls;
  final Function(CameraControls) onCameraChanged;
  final bool showGrid;
  final bool showAxes;
  final Color backgroundColor;

  const Interactive3DViewer({
    super.key,
    this.objectA,
    this.objectB,
    required this.cameraControls,
    required this.onCameraChanged,
    this.showGrid = true,
    this.showAxes = true,
    this.backgroundColor = Colors.black,
  });

  @override
  State<Interactive3DViewer> createState() => _Interactive3DViewerState();
}

class _Interactive3DViewerState extends State<Interactive3DViewer>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _zoomController;
  late AnimationController _panController;

  CameraControls _currentCamera = CameraControls();
  bool _isDragging = false;
  bool _isTwoFingerPanning = false;
  Offset? _lastPanPosition;
  Offset? _lastTwoFingerPosition;
  double _lastScale = 1.0;
  int _activePointers = 0;

  @override
  void initState() {
    super.initState();
    _currentCamera = widget.cameraControls;

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _panController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(Interactive3DViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cameraControls != widget.cameraControls) {
      _animateToCamera(widget.cameraControls);
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _zoomController.dispose();
    _panController.dispose();
    super.dispose();
  }

  void _animateToCamera(CameraControls targetCamera) {
    // For now, just set the camera directly
    // In a full implementation, you would animate between the current and target camera
    _currentCamera = targetCamera;
    widget.onCameraChanged(_currentCamera);
  }

  void _handlePanStart(DragStartDetails details) {
    if (_activePointers == 1) {
      _isDragging = true;
      _lastPanPosition = details.localPosition;
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_activePointers == 1 && _isDragging && _lastPanPosition != null) {
      // Single finger - orbit camera
      final delta = details.localPosition - _lastPanPosition!;
      final sensitivity = 0.5;

      _currentCamera = _currentCamera.orbit(
        delta.dx * sensitivity,
        delta.dy * sensitivity,
      );

      _lastPanPosition = details.localPosition;
      widget.onCameraChanged(_currentCamera);
    } else if (_activePointers == 2 &&
        _isTwoFingerPanning &&
        _lastTwoFingerPosition != null) {
      // Two finger - pan camera
      final delta = details.localPosition - _lastTwoFingerPosition!;
      final sensitivity = 0.3;

      _currentCamera = _currentCamera.pan(
        delta.dx * sensitivity,
        delta.dy * sensitivity,
      );

      _lastTwoFingerPosition = details.localPosition;
      widget.onCameraChanged(_currentCamera);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_activePointers <= 1) {
      _isDragging = false;
      _lastPanPosition = null;
    }
    if (_activePointers <= 2) {
      _isTwoFingerPanning = false;
      _lastTwoFingerPosition = null;
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _lastScale = 1.0;
    _activePointers = details.pointerCount;

    if (details.pointerCount == 2) {
      _isTwoFingerPanning = true;
      _lastTwoFingerPosition = details.focalPoint;
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    _activePointers = details.pointerCount;

    if (details.pointerCount == 2) {
      // Handle zoom
      final scaleDelta = details.scale / _lastScale;
      _lastScale = details.scale;

      if (scaleDelta > 1.0) {
        _currentCamera = _currentCamera.zoomIn(scaleDelta);
      } else {
        _currentCamera = _currentCamera.zoomOut(1.0 / scaleDelta);
      }

      // Handle two-finger pan
      if (_lastTwoFingerPosition != null) {
        final delta = details.focalPoint - _lastTwoFingerPosition!;
        final sensitivity = 0.3;

        _currentCamera = _currentCamera.pan(
          delta.dx * sensitivity,
          delta.dy * sensitivity,
        );

        _lastTwoFingerPosition = details.focalPoint;
      }

      widget.onCameraChanged(_currentCamera);
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _lastScale = 1.0;
    _activePointers = 0;
    _isTwoFingerPanning = false;
    _lastTwoFingerPosition = null;
  }

  void _resetCamera() {
    _currentCamera = CameraControls();
    widget.onCameraChanged(_currentCamera);
  }

  void _fitToView() {
    // Calculate bounding box of objects
    if (widget.objectA != null || widget.objectB != null) {
      final bounds = _calculateBounds();
      final center = bounds.center;
      final size = bounds.size;
      final maxSize = [size.x, size.y, size.z].reduce((a, b) => a > b ? a : b);

      final distance = maxSize * 2.0;
      final newPosition = center + Vector3(0, 0, distance);

      final targetCamera = _currentCamera.copyWith(
        position: newPosition,
        target: center,
        zoom: 1.0,
      );

      _animateToCamera(targetCamera);
    }
  }

  void _toggleAutoRotation() {
    // Toggle auto-rotation (this would need to be implemented in CameraControls)
    // For now, just reset to a nice viewing angle
    final targetCamera = _currentCamera.copyWith(
      rotationX: 0.2,
      rotationY: 0.0,
    );
    _animateToCamera(targetCamera);
  }

  void _setTopView() {
    final targetCamera = _currentCamera.copyWith(
      rotationX: -math.pi / 2,
      rotationY: 0.0,
    );
    _animateToCamera(targetCamera);
  }

  void _setFrontView() {
    final targetCamera = _currentCamera.copyWith(
      rotationX: 0.0,
      rotationY: 0.0,
    );
    _animateToCamera(targetCamera);
  }

  void _setSideView() {
    final targetCamera = _currentCamera.copyWith(
      rotationX: 0.0,
      rotationY: -math.pi / 2,
    );
    _animateToCamera(targetCamera);
  }

  BoundingBox _calculateBounds() {
    final points = <Vector3>[];

    if (widget.objectA != null) {
      points.addAll(_getObjectPoints(widget.objectA!));
    }

    if (widget.objectB != null) {
      points.addAll(_getObjectPoints(widget.objectB!));
    }

    if (points.isEmpty) {
      return BoundingBox(Vector3.zero(), Vector3.zero());
    }

    var min = points.first;
    var max = points.first;

    for (final point in points) {
      min = Vector3(
        math.min(min.x, point.x),
        math.min(min.y, point.y),
        math.min(min.z, point.z),
      );
      max = Vector3(
        math.max(max.x, point.x),
        math.max(max.y, point.y),
        math.max(max.z, point.z),
      );
    }

    return BoundingBox(min, max);
  }

  List<Vector3> _getObjectPoints(Object3D object) {
    // Generate points for the object (simplified cube)
    final points = <Vector3>[];
    final vertices = [
      Vector3(-1, -1, -1),
      Vector3(1, -1, -1),
      Vector3(1, 1, -1),
      Vector3(-1, 1, -1),
      Vector3(-1, -1, 1),
      Vector3(1, -1, 1),
      Vector3(1, 1, 1),
      Vector3(-1, 1, 1),
    ];

    for (final vertex in vertices) {
      var transformed = vertex.clone();
      transformed.scale(object.scale.x); // Use x component for uniform scaling
      transformed += object.position;
      points.add(transformed);
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: Stack(
        children: [
          // 3D View
          GestureDetector(
            onPanStart: _handlePanStart,
            onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            onScaleEnd: _handleScaleEnd,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: _View3DPainter(
                  camera: _currentCamera,
                  objectA: widget.objectA,
                  objectB: widget.objectB,
                  showGrid: widget.showGrid,
                  showAxes: widget.showAxes,
                ),
              ),
            ),
          ),

          // Navigation Controls
          Positioned(top: 16, right: 16, child: _buildNavigationControls()),

          // Gesture Instructions
          Positioned(bottom: 16, left: 16, child: _buildGestureInstructions()),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // View controls
          _buildViewControlButton(
            icon: Icons.refresh,
            tooltip: 'Reset View',
            onPressed: _resetCamera,
          ),
          _buildViewControlButton(
            icon: Icons.fit_screen,
            tooltip: 'Fit to View',
            onPressed: _fitToView,
          ),
          _buildViewControlButton(
            icon: Icons.rotate_right,
            tooltip: 'Auto Rotate',
            onPressed: _toggleAutoRotation,
          ),
          Divider(color: Colors.white24, height: 16),
          // Standard views
          _buildViewControlButton(
            icon: Icons.view_in_ar,
            tooltip: 'Top View',
            onPressed: _setTopView,
          ),
          _buildViewControlButton(
            icon: Icons.view_agenda,
            tooltip: 'Front View',
            onPressed: _setFrontView,
          ),
          _buildViewControlButton(
            icon: Icons.view_sidebar,
            tooltip: 'Side View',
            onPressed: _setSideView,
          ),
          Divider(color: Colors.white24, height: 16),
          // Display options
          _buildViewControlButton(
            icon: widget.showGrid ? Icons.grid_on : Icons.grid_off,
            tooltip: 'Toggle Grid',
            onPressed: () {
              // Toggle grid visibility - would need callback
            },
          ),
          _buildViewControlButton(
            icon: widget.showAxes ? Icons.three_k : Icons.three_k_plus,
            tooltip: 'Toggle Axes',
            onPressed: () {
              // Toggle axes visibility - would need callback
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 20),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }

  Widget _buildGestureInstructions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '3D Navigation',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '• Single finger drag to orbit',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          Text(
            '• Pinch to zoom in/out',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          Text(
            '• Two-finger drag to pan',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the controls on the right for preset views and options.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white60,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for 3D view
class _View3DPainter extends CustomPainter {
  final CameraControls camera;
  final Object3D? objectA;
  final Object3D? objectB;
  final bool showGrid;
  final bool showAxes;

  _View3DPainter({
    required this.camera,
    this.objectA,
    this.objectB,
    required this.showGrid,
    required this.showAxes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    if (showGrid) {
      _drawGrid(canvas, size, center);
    }

    if (showAxes) {
      _drawAxes(canvas, size, center);
    }

    if (objectA != null) {
      _drawObject(canvas, size, center, objectA!, Colors.blue);
    }

    if (objectB != null) {
      _drawObject(canvas, size, center, objectB!, Colors.red);
    }
  }

  void _drawGrid(Canvas canvas, Size size, Offset center) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    const gridSpacing = 50.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawAxes(Canvas canvas, Size size, Offset center) {
    final paint = Paint()..strokeWidth = 2.0;

    // X-axis (red)
    paint.color = Colors.red;
    canvas.drawLine(center, center + const Offset(50, 0), paint);

    // Y-axis (green)
    paint.color = Colors.green;
    canvas.drawLine(center, center + const Offset(0, -50), paint);

    // Z-axis (blue) - represented as diagonal
    paint.color = Colors.blue;
    canvas.drawLine(center, center + const Offset(35, -35), paint);
  }

  void _drawObject(
    Canvas canvas,
    Size size,
    Offset center,
    Object3D object,
    Color color,
  ) {
    final paint = Paint()
      ..color = color.withValues(alpha: object.opacity)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw a simple cube representation
    final cubeSize = 30.0 * object.scale.x;
    final rect = Rect.fromCenter(
      center: center + Offset(object.position.x * 10, -object.position.y * 10),
      width: cubeSize,
      height: cubeSize,
    );

    canvas.drawRect(rect, paint);

    // Draw object name
    final textPainter = TextPainter(
      text: TextSpan(
        text: object.name,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(rect.left, rect.bottom + 5));
  }

  @override
  bool shouldRepaint(covariant _View3DPainter oldDelegate) {
    return oldDelegate.camera != camera ||
        oldDelegate.objectA != objectA ||
        oldDelegate.objectB != objectB ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.showAxes != showAxes;
  }
}

/// Bounding box for 3D objects
class BoundingBox {
  final Vector3 min;
  final Vector3 max;

  BoundingBox(this.min, this.max);

  Vector3 get center => (min + max) * 0.5;
  Vector3 get size => max - min;
}
