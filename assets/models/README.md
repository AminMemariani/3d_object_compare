# 3D Models Directory

This directory is intended for storing 3D model files that can be used within the Flutter 3D App.

## Supported Formats

- **GLB**: Binary glTF format (recommended)
- **GLTF**: JSON-based glTF format
- **OBJ**: Wavefront OBJ format
- **FBX**: Autodesk FBX format

## Usage

1. Place your 3D model files in this directory
2. Update the model paths in your code to reference these assets
3. Ensure models are optimized for mobile/web performance

## Example

```dart
final model = Model3D(
  id: 'my_model',
  name: 'My 3D Model',
  path: 'assets/models/my_model.glb',
  // ... other properties
);
```

## Tips

- Keep file sizes reasonable for mobile performance
- Use GLB format for best compatibility
- Test models on different platforms before deployment
