# 🚀 Quick Start Guide

## Run the App

```bash
# Recommended: Web (best for hosted GLB files)
flutter run -d chrome

# Desktop: All analysis features work, limited rendering
flutter run -d macos

# Mobile: Full rendering + all features
flutter run -d iphone   # or android
```

## Load & Compare Objects

1. **Click "Object A"** → Select a 3D file (GLB recommended)
2. **Click "Object B"** → Select another 3D file
3. **Automatically navigates** to comparison view

## Use Comparison Features

### Quick Actions:
- **Auto Align** → Instant alignment
- **Reset** → Return to defaults
- **Run Procrustes Analysis** → Statistical alignment

### What You'll See:
- **Alignment Score Gauge** → Real-time score (0-100%)
- **Progress Bar** → During analysis
- **Results Card** → Detailed metrics after analysis

## Platform Notes

| Platform | 3D Rendering | Comparison Features |
|----------|--------------|---------------------|
| Web | ⚠️ Requires hosted files | ✅ All work |
| iOS/Android | ✅ Full support | ✅ All work |
| macOS | ⚠️ Use web instead | ✅ All work |

## File Format Tips

- **Use GLB/GLTF** for best experience
- **OBJ/STL** work for analysis only
- **Convert OBJ to GLB**: See README.md for tools

## Troubleshooting

**Nothing renders on macOS?**
→ This is expected. Use `flutter run -d chrome`

**File picker doesn't open?**
→ Entitlements are set. Try rebuilding.

**Analysis doesn't run?**
→ Make sure both objects are loaded

---

**For detailed documentation, see IMPLEMENTATION_COMPLETE.md and README.md**

