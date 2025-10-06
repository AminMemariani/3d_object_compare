import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:vector_math/vector_math_64.dart' as vm;
import '../../domain/entities/object_3d.dart';

/// Advanced 3D Viewer with interactive controls for rotation, scale, and position
class Advanced3DViewer extends StatefulWidget {
  final Object3D object;
  final Uint8List? modelBytes;
  final Color backgroundColor;
  final bool showControls;
  final Function(vm.Vector3 position)? onPositionChanged;
  final Function(vm.Vector3 rotation)? onRotationChanged;
  final Function(vm.Vector3 scale)? onScaleChanged;

  const Advanced3DViewer({
    super.key,
    required this.object,
    this.modelBytes,
    this.backgroundColor = Colors.grey,
    this.showControls = true,
    this.onPositionChanged,
    this.onRotationChanged,
    this.onScaleChanged,
  });

  @override
  State<Advanced3DViewer> createState() => _Advanced3DViewerState();
}

class _Advanced3DViewerState extends State<Advanced3DViewer> {
  late vm.Vector3 _position;
  late vm.Vector3 _rotation;
  late vm.Vector3 _scale;
  
  bool _showTransformPanel = false;

  @override
  void initState() {
    super.initState();
    _position = widget.object.position.clone();
    _rotation = widget.object.rotation.clone();
    _scale = widget.object.scale.clone();
    
    if (kIsWeb && widget.modelBytes != null) {
      _convertToDataUrl();
    }
  }

  void _convertToDataUrl() {
    // For web, we need to convert OBJ bytes to a data URL
    // In a real implementation, you'd convert OBJ to GLB here
    // For now, we'll show a placeholder that explains the limitation
  }

  void _updatePosition(vm.Vector3 newPosition) {
    setState(() {
      _position = newPosition;
    });
    widget.onPositionChanged?.call(newPosition);
  }

  void _updateRotation(vm.Vector3 newRotation) {
    setState(() {
      _rotation = newRotation;
    });
    widget.onRotationChanged?.call(newRotation);
  }

  void _updateScale(vm.Vector3 newScale) {
    setState(() {
      _scale = newScale;
    });
    widget.onScaleChanged?.call(newScale);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 3D Viewer Area
        _build3DView(),
        
        // Control Panel
        if (widget.showControls) _buildControlPanel(),
        
        // Transform Panel (Floating)
        if (_showTransformPanel) _buildTransformPanel(),
      ],
    );
  }

  Widget _build3DView() {
    // For now, show an enhanced placeholder with transform visualization
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.backgroundColor.withOpacity(0.3),
            widget.backgroundColor.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 3D Icon with transform visualization
            Transform(
              transform: Matrix4.identity()
                ..translate(_position.x * 50, _position.y * 50, 0.0)
                ..rotateX(_rotation.x)
                ..rotateY(_rotation.y)
                ..rotateZ(_rotation.z)
                ..scale(_scale.x, _scale.y, _scale.z),
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.view_in_ar_rounded,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    widget.object.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTransformInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransformInfo() {
    return Column(
      children: [
        _buildInfoRow('Position', 
          'X: ${_position.x.toStringAsFixed(2)}, '
          'Y: ${_position.y.toStringAsFixed(2)}, '
          'Z: ${_position.z.toStringAsFixed(2)}'),
        const SizedBox(height: 4),
        _buildInfoRow('Rotation', 
          'X: ${(_rotation.x * 180 / 3.14159).toStringAsFixed(1)}°, '
          'Y: ${(_rotation.y * 180 / 3.14159).toStringAsFixed(1)}°, '
          'Z: ${(_rotation.z * 180 / 3.14159).toStringAsFixed(1)}°'),
        const SizedBox(height: 4),
        _buildInfoRow('Scale', 
          'X: ${_scale.x.toStringAsFixed(2)}, '
          'Y: ${_scale.y.toStringAsFixed(2)}, '
          'Z: ${_scale.z.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          // Transform Toggle Button
          FloatingActionButton(
            mini: true,
            heroTag: 'transform_${widget.object.id}',
            onPressed: () {
              setState(() {
                _showTransformPanel = !_showTransformPanel;
              });
            },
            child: Icon(_showTransformPanel ? Icons.close : Icons.tune),
          ),
          const SizedBox(height: 8),
          // Reset Button
          FloatingActionButton(
            mini: true,
            heroTag: 'reset_${widget.object.id}',
            onPressed: _resetTransform,
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildTransformPanel() {
    return Positioned(
      right: 80,
      top: 16,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transform Controls',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Position Controls
            _buildTransformSection(
              'Position',
              Icons.open_with,
              [
                _buildSlider('X', _position.x, -5.0, 5.0, (v) {
                  _updatePosition(vm.Vector3(v, _position.y, _position.z));
                }),
                _buildSlider('Y', _position.y, -5.0, 5.0, (v) {
                  _updatePosition(vm.Vector3(_position.x, v, _position.z));
                }),
                _buildSlider('Z', _position.z, -5.0, 5.0, (v) {
                  _updatePosition(vm.Vector3(_position.x, _position.y, v));
                }),
              ],
            ),
            
            const Divider(height: 24),
            
            // Rotation Controls
            _buildTransformSection(
              'Rotation',
              Icons.rotate_right,
              [
                _buildSlider('X', _rotation.x * 180 / 3.14159, -180, 180, (v) {
                  _updateRotation(vm.Vector3(v * 3.14159 / 180, _rotation.y, _rotation.z));
                }, suffix: '°'),
                _buildSlider('Y', _rotation.y * 180 / 3.14159, -180, 180, (v) {
                  _updateRotation(vm.Vector3(_rotation.x, v * 3.14159 / 180, _rotation.z));
                }, suffix: '°'),
                _buildSlider('Z', _rotation.z * 180 / 3.14159, -180, 180, (v) {
                  _updateRotation(vm.Vector3(_rotation.x, _rotation.y, v * 3.14159 / 180));
                }, suffix: '°'),
              ],
            ),
            
            const Divider(height: 24),
            
            // Scale Controls
            _buildTransformSection(
              'Scale',
              Icons.photo_size_select_small,
              [
                _buildSlider('X', _scale.x, 0.1, 3.0, (v) {
                  _updateScale(vm.Vector3(v, _scale.y, _scale.z));
                }),
                _buildSlider('Y', _scale.y, 0.1, 3.0, (v) {
                  _updateScale(vm.Vector3(_scale.x, v, _scale.z));
                }),
                _buildSlider('Z', _scale.z, 0.1, 3.0, (v) {
                  _updateScale(vm.Vector3(_scale.x, _scale.y, v));
                }),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    final uniform = (_scale.x + _scale.y + _scale.z) / 3;
                    _updateScale(vm.Vector3.all(uniform));
                  },
                  icon: const Icon(Icons.lock, size: 16),
                  label: const Text('Uniform Scale'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 36),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransformSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged, {
    String suffix = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Text(
              '${value.toStringAsFixed(2)}$suffix',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _resetTransform() {
    setState(() {
      _position = vm.Vector3.zero();
      _rotation = vm.Vector3.zero();
      _scale = vm.Vector3.all(1.0);
    });
    widget.onPositionChanged?.call(_position);
    widget.onRotationChanged?.call(_rotation);
    widget.onScaleChanged?.call(_scale);
  }
}

