# 🍎 macOS DMG Installation Guide

## 📦 3D Object Comparison Tool v1.0.0

### 📁 DMG File Details
- **File**: `3D_Object_Comparison_Tool_v1.0.0.dmg`
- **Size**: 23 MB
- **Format**: Universal Disk Image (UDZO)
- **Compatibility**: macOS 10.14+ (Intel & Apple Silicon)

---

## 🚀 Installation Instructions

### Step 1: Download the DMG
Download the DMG file from the GitHub release:
- Go to: https://github.com/AminMemariani/3d_object_compare/releases/tag/v1.0.0
- Download: `3D_Object_Comparison_Tool_v1.0.0.dmg`

### Step 2: Mount the DMG
1. **Double-click** the DMG file to mount it
2. The DMG will open in Finder showing:
   - `flutter_3d_app.app` (the application)
   - `Applications` folder (symlink)
   - Installation instructions

### Step 3: Install the Application
**Option A: Drag & Drop (Recommended)**
1. Drag `flutter_3d_app.app` to the `Applications` folder
2. The app will be copied to your Applications directory

**Option B: Manual Copy**
1. Open the Applications folder in Finder
2. Copy `flutter_3d_app.app` from the DMG to Applications

### Step 4: Launch the Application
1. Open **Applications** folder in Finder
2. Find `flutter_3d_app.app`
3. Double-click to launch

**Alternative**: Use Spotlight search:
1. Press `Cmd + Space`
2. Type "3D Object Comparison" or "flutter_3d_app"
3. Press Enter to launch

---

## 🔧 System Requirements

### Minimum Requirements
- **macOS**: 10.14 (Mojave) or later
- **Architecture**: Intel x64 or Apple Silicon (M1/M2/M3)
- **RAM**: 4 GB minimum, 8 GB recommended
- **Storage**: 100 MB free space
- **Graphics**: Any graphics card with OpenGL support

### Recommended Configuration
- **macOS**: 12.0 (Monterey) or later
- **RAM**: 8 GB or more
- **Storage**: 500 MB free space
- **Graphics**: Dedicated graphics card for large 3D models

---

## 🎯 First Launch

### Initial Setup
1. **Launch the app** from Applications
2. **Grant permissions** if prompted:
   - File access (for loading 3D models)
   - Network access (for web features)
3. **Tutorial**: Follow the interactive tutorial for best experience

### Quick Start
1. **Load Object A**: Click "Load Object A" and select a 3D file
2. **Load Object B**: Click "Load Object B" and select another 3D file
3. **Compare**: Click "Compare" to start the analysis
4. **Export**: Use the export feature to save results

---

## 📁 Supported File Formats

### Fully Supported Formats
- **OBJ** - Wavefront format (recommended for analysis)
- **STL** - Stereolithography format
- **GLTF** - GL Transmission Format (JSON)
- **GLB** - GL Transmission Format (Binary)

### File Size Recommendations
- **Small models**: < 1 MB (fastest performance)
- **Medium models**: 1-10 MB (good performance)
- **Large models**: 10-50 MB (acceptable performance)
- **Very large models**: > 50 MB (may require patience)

---

## 🛠️ Troubleshooting

### Common Issues

**"App can't be opened because it is from an unidentified developer"**
1. Right-click the app → "Open"
2. Click "Open" in the dialog
3. Or go to System Preferences → Security & Privacy → Allow

**App crashes on launch**
1. Check system requirements
2. Restart your Mac
3. Try running from Terminal: `open /Applications/flutter_3d_app.app`

**3D models not loading**
1. Verify file format is supported
2. Check file isn't corrupted
3. Try with a smaller model first

**Poor performance with large models**
1. Close other applications
2. Use smaller model files
3. Enable "Vertex Sampling" in settings

### Getting Help
- **GitHub Issues**: https://github.com/AminMemariani/3d_object_compare/issues
- **Documentation**: https://github.com/AminMemariani/3d_object_compare#readme
- **Live Demo**: https://aminmemariani.github.io/3d_object_compare

---

## 🔄 Updates

### Checking for Updates
- Visit the GitHub releases page
- Download the latest DMG
- Replace the old app with the new version

### Uninstalling
1. Delete `flutter_3d_app.app` from Applications
2. Remove any saved preferences in:
   - `~/Library/Preferences/`
   - `~/Library/Application Support/`

---

## 📋 Features Overview

### 🎨 3D Visualization
- **Native rendering** with CustomPainter
- **Interactive controls** (mouse drag, scroll zoom)
- **Perspective projection** with depth visualization
- **Point cloud rendering** for all formats

### 🔬 Scientific Analysis
- **Procrustes analysis** for statistical alignment
- **Scientific metrics**: Min distance, std deviation, RMSE
- **Transformation matrix** display
- **High-precision calculations**

### 📊 Export & Reporting
- **TXT export** with complete analysis logs
- **CSV export** for data analysis
- **Comprehensive logging** of all operations
- **Share functionality** for easy collaboration

### 🎯 User Experience
- **Clean interface** optimized for scientific work
- **Smart workflow** with guided steps
- **Cross-platform compatibility**
- **Professional documentation**

---

## 📄 License & Credits

### License
This software is licensed under the **GPL v3.0 License**.
See the LICENSE file for full details.

### Credits
- **Flutter Team** - Cross-platform framework
- **Vector Math Library** - 3D calculations
- **Research Community** - Procrustes methodology
- **Open Source Contributors** - Various libraries

---

## 🎉 Enjoy Your 3D Object Comparison Tool!

This professional-grade application is designed for researchers, scientists, and professionals who need accurate 3D object analysis. With its native macOS rendering and scientific precision, it's the perfect tool for your research and analysis needs.

**Happy analyzing!** 🔬✨
