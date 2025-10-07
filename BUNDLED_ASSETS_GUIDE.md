# Bundled Assets Guide

## Sample 3D Models Included

Your app now includes sample skull models bundled as assets for demonstration and testing purposes.

### Asset Structure

```
assets/
  └── data/
      ├── obj1/
      │   ├── skull.obj
      │   ├── skull.mtl
      │   ├── skull.3ds
      │   └── skull.max
      └── obj2/
          ├── 12140_Skull_v3_L2.obj
          └── 12140_Skull_v3_L2.mtl
```

### Accessing Bundled Assets in Code

#### 1. Load Asset String Path

```dart
// These paths can be used with AssetBundle or rootBundle
const String skullObj1Path = 'assets/data/obj1/skull.obj';
const String skullObj2Path = 'assets/data/obj2/12140_Skull_v3_L2.obj';
```

#### 2. Read Asset as String

```dart
import 'package:flutter/services.dart';

Future<String> loadObjFile() async {
  return await rootBundle.loadString('assets/data/obj1/skull.obj');
}
```

#### 3. Read Asset as Bytes

```dart
import 'package:flutter/services.dart';

Future<ByteData> loadObjFileBytes() async {
  return await rootBundle.load('assets/data/obj1/skull.obj');
}
```

#### 4. Example: Load and Parse OBJ File

```dart
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';

Future<List<Vector3>> loadBundledSkullVertices(String assetPath) async {
  final objContent = await rootBundle.loadString(assetPath);
  final lines = objContent.split('\n');
  
  final vertices = <Vector3>[];
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('v ')) {
      final parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length >= 4) {
        final x = double.parse(parts[1]);
        final y = double.parse(parts[2]);
        final z = double.parse(parts[3]);
        vertices.add(Vector3(x, y, z));
      }
    }
  }
  
  return vertices;
}

// Usage:
final skull1Vertices = await loadBundledSkullVertices('assets/data/obj1/skull.obj');
final skull2Vertices = await loadBundledSkullVertices('assets/data/obj2/12140_Skull_v3_L2.obj');
```

### Use Cases

#### 1. Demo Mode
Show users how the app works without requiring them to load their own files:

```dart
void loadDemoObjects() async {
  final skull1 = await loadBundledSkullVertices('assets/data/obj1/skull.obj');
  final skull2 = await loadBundledSkullVertices('assets/data/obj2/12140_Skull_v3_L2.obj');
  
  // Perform comparison
  final result = ProcrustesAnalysis.align(skull1, skull2);
  print('Similarity: ${result.similarityScore}%');
}
```

#### 2. Tutorial/Onboarding
Use bundled assets in your tutorial:

```dart
class TutorialPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Load bundled example for tutorial
        final exampleData = await rootBundle.loadString('assets/data/obj1/skull.obj');
        // Show in viewer...
      },
      child: Text('Try Example'),
    );
  }
}
```

#### 3. Unit Tests
Use bundled assets in your tests:

```dart
test('Compare bundled skulls', () async {
  final skull1 = await loadBundledSkullVertices('assets/data/obj1/skull.obj');
  final skull2 = await loadBundledSkullVertices('assets/data/obj2/12140_Skull_v3_L2.obj');
  
  final result = ProcrustesAnalysis.align(skull1, skull2);
  
  expect(result.similarityScore, greaterThan(80.0));
});
```

### Asset Information

**Skull 1 (obj1/skull.obj)**
- Vertices: 6,122
- Format: Wavefront OBJ with MTL
- Additional: Includes 3DS and MAX formats

**Skull 2 (obj2/12140_Skull_v3_L2.obj)**
- Vertices: 40,062
- Format: Wavefront OBJ with MTL
- Higher resolution model

### Build Size Impact

These assets will increase your app's download size:
- obj1/: ~1.5 MB
- obj2/: ~8 MB
- **Total**: ~9.5 MB

### Removing Bundled Assets

If you don't want to bundle these assets in production:

1. Remove from `pubspec.yaml`:
```yaml
assets:
  - assets/models/
  # Remove these lines:
  # - assets/data/obj1/
  # - assets/data/obj2/
```

2. Run `flutter pub get`

3. Keep the assets in the project for development/testing (Git will track them)

### Platform Notes

✅ **iOS**: Assets are bundled in the app bundle  
✅ **Android**: Assets are bundled in the APK/AAB  
✅ **Web**: Assets are served with the web app  
✅ **Desktop**: Assets are bundled with the application  

All platforms can access these assets using the same `rootBundle` API.

---

**Pro Tip**: You can add more sample models by placing them in `assets/data/` and adding the paths to `pubspec.yaml`!

