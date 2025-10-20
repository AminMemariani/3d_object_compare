# 3D Object Comparison Tool

[![CI/CD](https://github.com/AminMemariani/3d_object_compare/workflows/Deploy%20Flutter%20Web%20to%20GitHub%20Pages/badge.svg)](https://github.com/AminMemariani/3d_object_compare/actions)
[![Flutter](https://img.shields.io/badge/Flutter-3.32.6-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-blue.svg)](https://dart.dev/)
[![Tests](https://img.shields.io/badge/Tests-78%2F78%20passing-green.svg)](https://github.com/AminMemariani/3d_object_compare/actions)
[![License](https://img.shields.io/badge/License-GPL%20v3.0-red.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iOS%20%7C%20Android%20%7C%20Web-blue.svg)](https://flutter.dev/)
[![Recommended](https://img.shields.io/badge/🍎%20Recommended-macOS-success.svg)](https://www.apple.com/macos/)
[![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-Live-brightgreen.svg)](https://aminmemariani.github.io/3d_object_compare)

A professional-grade Flutter application designed to help researchers, professionals, and developers in **geology**, **gaming**, and **medical fields** compare and analyze 3D objects with advanced Procrustes analysis. Built with clean architecture principles and supporting all major platforms.

> 🍎 **Recommended Platform: macOS** - For optimal performance and full 3D rendering support with native point cloud visualization

> 📋 **Project Progress**: See [PROJECT_STATUS.md](PROJECT_STATUS.md) for complete TODO list, recent updates, and development roadmap.

## 🎥 How it works (Video)

Watch a short walkthrough of the app in action:

![How the app works](https://github.com/user-attachments/assets/19736b5c-b48e-41ab-9b6a-cb15afe9636e)

## 🎯 Purpose & Applications

### Geology & Earth Sciences
- **Fossil Analysis**: Compare fossil specimens to identify species and evolutionary relationships
- **Rock Formation Studies**: Analyze geological structures and mineral formations
- **Paleontology Research**: Compare bone structures and skeletal remains
- **Geological Mapping**: Overlay and compare terrain models and geological features

### Gaming & Entertainment
- **Character Modeling**: Compare 3D character models for consistency and quality control
- **Asset Validation**: Ensure 3D assets meet design specifications
- **Animation Rigging**: Compare skeletal structures for animation compatibility
- **Level Design**: Analyze and compare 3D environments and architectural elements

### Medical & Healthcare
- **Anatomical Studies**: Compare anatomical structures for research and education
- **Prosthetic Design**: Analyze and compare prosthetic components for optimal fit
- **Surgical Planning**: Compare pre and post-operative 3D scans
- **Medical Imaging**: Analyze CT scans, MRI data, and other 3D medical images
- **Dental Applications**: Compare dental models and orthodontic treatments

## 🔬 Advanced Comparison Features

### Core Functionality
- **3D Object Loading**: Support for GLB/GLTF (full 3D rendering), OBJ/STL (data analysis)
- **Interactive 3D Visualization**: Real-time rendering with camera controls for GLB/GLTF files
- **Procrustes Analysis**: Advanced statistical alignment and comparison using proven mathematical algorithms
- **Similarity Metrics**: Comprehensive analysis with RMSE, standard deviation, and similarity scores
- **Export Results**: JSON and CSV export capabilities for integration with research workflows
- **Superimposed Viewing**: Overlay multiple objects with adjustable opacity for visual comparison

### Comparison Tools
- **Side-by-Side Comparison**: View two 3D objects simultaneously with independent controls
- **Alignment Score Gauge**: Real-time visual feedback on how well objects are aligned (0-100%)
- **Procrustes Analysis**: One-click statistical alignment with progress tracking
- **Auto-Align**: Instantly position Object B to match Object A's transforms
- **Reset Controls**: Return objects to default positions
- **Similarity Metrics Card**: Detailed breakdown of RMSE, standard deviation, and alignment quality
- **Transform History**: Undo/redo capability for all transformations
- **Export Analysis**: Save comparison results as TXT files

### Scientific Analysis Tools
- **Statistical Alignment**: Automatically align objects using Procrustes transformation
- **Quantitative Metrics**: Precise measurements of shape differences and similarities
- **Visual Comparison**: Side-by-side and overlaid viewing modes
- **Data Export**: Export analysis results for further statistical processing

## Architecture

The project follows clean architecture principles with clear separation of concerns:

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants
│   ├── database/           # Database setup
│   ├── di/                 # Dependency injection
│   ├── errors/             # Error handling
│   └── utils/              # Utility functions
├── features/               # Feature modules
│   ├── home/               # Home screen
│   ├── model_viewer/       # 3D model viewing
│   └── user_preferences/   # User settings
└── shared/                 # Shared components
    ├── utils/              # Shared utilities
    └── widgets/            # Reusable widgets
```

Each feature follows the clean architecture pattern:
- **Presentation Layer**: UI components, pages, and providers
- **Domain Layer**: Entities, repositories, and use cases
- **Data Layer**: Data sources, models, and repository implementations
## 🌐 Live Demo

**Try the app online**: [https://aminmemariani.github.io/3d_object_compare](https://aminmemariani.github.io/3d_object_compare)

> **Note**: If you see a 404 error, the deployment is in progress. Please wait 2-3 minutes for GitHub Actions to complete the build and deployment.

The web version is automatically deployed to GitHub Pages and includes all core features for 3D object comparison and analysis.

### Web Deployment
The app is automatically deployed to GitHub Pages using GitHub Actions. To deploy manually:

```bash
# Using the deployment script
./scripts/deploy_web.sh

# Or manually
flutter build web --release
```

For detailed deployment instructions, see [docs/README.md](docs/README.md).

## Getting Started

### 🍎 Quick Start for macOS (Recommended)

**For the best scientific analysis experience:**

```bash
# 1. Clone the repository
git clone https://github.com/AminMemariani/3d_object_compare.git
cd 3d_object_compare

# 2. Install dependencies
flutter pub get

# 3. Run on macOS
flutter run -d macos

# 4. Load your 3D models (OBJ, STL, GLTF, GLB)
# 5. Run Procrustes Analysis
# 6. Export complete results with logs
```


### Prerequisites
- Flutter SDK 3.32.6 or later
- Dart SDK 3.8.1 or later


### Installation

1. Clone the repository:
```bash
git clone https://github.com/AminMemariani/3d_object_compare.git
cd 3d_object_compare
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Isar database code:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

4. Run the application:
```bash
flutter run
```

### Quick Start Guide

1. **Load 3D Objects**: Click "Load Object A" and "Load Object B" to select 3D files
   - **Supported formats**: OBJ, STL, GLB, GLTF
   - **On macOS** 🍎: All formats render natively with interactive 3D point clouds
   - **On iOS/Android**: Full textured rendering with ModelViewer
   - **On Web**: Point cloud rendering (requires hosted files for textures)
2. **Navigate to Comparison View**: Automatically opens after loading both objects
3. **View Scientific Metrics**: Min Distance and Standard Deviation displayed after analysis
4. **Transform Objects**: Use on-screen controls to manually adjust position/rotation/scale
5. **Run Analysis**: Click "Run Procrustes Analysis" for statistical alignment
6. **View Results**: Detailed metrics card with minimum distance, std deviation, RMSE, and transformation matrix
7. **Export Results**: Save complete analysis report with logs as TXT file (includes all processing logs)

> **🍎 Recommended**: For the best scientific analysis experience, **run on macOS** which provides native rendering for all formats without WebView dependencies.

> **💡 Format Tip**: All formats (OBJ, STL, GLTF, GLB) work great on macOS with native rendering. For other platforms, GLB or GLTF provide the best visual experience.

### Use Case Examples

#### For Geologists
```
1. Load fossil specimen A (reference)
2. Load fossil specimen B (comparison)
3. Use Procrustes analysis to determine morphological similarities
4. Export quantitative data for species classification
```

#### For Game Developers
```
1. Load original 3D model A
2. Load optimized version B
3. Compare geometry to ensure visual consistency
4. Validate that optimization maintains shape integrity
```

#### For Medical Professionals
```
1. Load pre-operative scan A
2. Load post-operative scan B
3. Analyze surgical outcomes quantitatively
4. Export data for patient records and research
```

### Platform-Specific Setup


#### iOS
- Minimum iOS version: 12.0
- ARKit support for AR features
- Permissions: Camera, Photo Library access
- Full textured rendering with ModelViewer

#### Android
- Minimum SDK version: 21 (Android 5.0)
- Target SDK version: 34
- Permissions: Camera, Storage access
- Full textured rendering with ModelViewer

#### Web
- Modern web browser with WebGL support
- HTTPS required for AR features
- Progressive Web App (PWA) support
- Requires hosted files (not local)

#### Desktop (Windows, Linux)
- Windows 10 or later
- Ubuntu 18.04+ or equivalent Linux distribution
- Point cloud rendering for vertex data
- Use web version for textured models

## 📊 Usage & Workflows

### Basic Comparison Workflow
1. **Load Objects**: Use "Load Object A" and "Load Object B" buttons to select 3D files
2. **Navigate**: Tap "View Objects" to open the interactive 3D viewer
3. **Transform**: Use the control panel to move, rotate, and scale Object B
4. **Align**: Position Object B to match Object A as closely as possible
5. **Analyze**: Tap "Compare" to run Procrustes analysis
6. **Review**: Examine detailed similarity metrics and visualizations
7. **Export**: Save results as JSON or CSV for further analysis

### Research Workflows

#### Geological Research
- **Specimen Comparison**: Load multiple fossil specimens for taxonomic analysis
- **Morphological Studies**: Compare rock formations and geological structures
- **Evolutionary Analysis**: Track changes in fossil morphology over time
- **Publication Ready**: Export data in formats suitable for scientific papers

#### Medical Research
- **Anatomical Studies**: Compare anatomical structures across populations
- **Treatment Analysis**: Evaluate effectiveness of medical interventions
- **Prosthetic Fitting**: Ensure optimal fit for prosthetic devices
- **Clinical Documentation**: Generate reports for patient records

#### Game Development
- **Quality Assurance**: Validate 3D assets meet design specifications
- **Performance Optimization**: Compare original and optimized models
- **Consistency Checks**: Ensure character models maintain visual consistency
- **Asset Pipeline**: Integrate comparison results into development workflows

### 3D Navigation
- **Single finger drag**: Orbit around the objects
- **Pinch to zoom**: Zoom in/out
- **Two-finger drag**: Pan the view
- **Preset views**: Use top, front, side view buttons
- **Reset**: Return to default camera position

### Settings
1. Navigate to Settings from the home screen
2. Customize theme (Light/Dark/System)
3. Adjust default 3D model settings
4. Configure background colors and grid display
5. Manage tutorial preferences

### Tutorial System
- Interactive onboarding for new users
- Step-by-step guidance through core features
- Skippable tutorial with progress tracking
- Contextual help and tips

## Development

### Code Generation
Run the following command to generate Isar database code:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test files
flutter test test/features/model_viewer/domain/services/procrustes_analysis_test.dart

# Run tests with coverage
flutter test --coverage
```

### Code Analysis
```bash
# Analyze code for issues
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

### Building for Release

#### Build All Platforms
```bash
# Unix/Linux/macOS
./scripts/build_all.sh

# Windows
scripts\build_all.bat
```

#### Build Specific Platforms
```bash
# Web
flutter build web --release

# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Desktop
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

#### Create Distribution Packages
```bash
# Unix/Linux/macOS
./scripts/package_release.sh

# Windows
scripts\package_release.bat
```

## Project Structure Details

### Core Module
- **Database**: Isar database configuration and initialization
- **DI**: Dependency injection setup using GetIt
- **Errors**: Custom failure and exception classes
- **Constants**: Application-wide constants
- **Animations**: Custom page transitions and UI animations

### Features

#### Home Feature
- Main navigation screen with animated transitions
- Feature cards for different app sections
- Tutorial system integration
- Quick access to 3D viewer and settings

#### Model Viewer Feature
- 3D object loading (GLB/GLTF for full rendering, OBJ/STL for analysis)
- Real-time 3D visualization with WebGL (GLB/GLTF files)
- Interactive navigation with gesture controls
- Procrustes analysis and comparison
- Superimposed viewing with opacity controls
- Export functionality (JSON, CSV)
- MVVM architecture with clean separation

#### User Preferences Feature
- Persistent storage of user settings
- Theme management (Light/Dark/System)
- 3D model viewing preferences
- Background color customization
- Tutorial preferences

#### Tutorial Feature
- Interactive onboarding system
- Step-by-step guidance
- Progress tracking and navigation
- Contextual help overlays

## Deployment

### Automated Deployment
The project includes GitHub Actions workflows for automated building and deployment:
- **Build and Test**: Runs on every push
- **Release**: Creates GitHub releases with all platform builds
- **Web Deployment**: Automatically deploys web version

### Manual Deployment
See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions for each platform.

### Release Management
See [RELEASE.md](RELEASE.md) for comprehensive release preparation and distribution guide.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following the existing architecture
4. Add tests for new functionality
5. Ensure all tests pass (`flutter test`)
6. Run code analysis (`flutter analyze`)
7. Commit your changes (`git commit -m 'Add amazing feature'`)
8. Push to the branch (`git push origin feature/amazing-feature`)
9. Open a Pull Request

### Development Guidelines
- Follow the existing clean architecture pattern
- Write comprehensive tests for new features
- Update documentation for API changes
- Ensure cross-platform compatibility
- Follow Flutter/Dart style guidelines

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Support

- **GitHub Issues**: [Report bugs and request features](https://github.com/AminMemariani/3d_object_compare/issues)
- **Documentation**: [Wiki and guides](https://github.com/AminMemariani/3d_object_compare/wiki)
- **Discussions**: [Community discussions](https://github.com/AminMemariani/3d_object_compare/discussions)

## Acknowledgments

- **Flutter Team**: For the excellent cross-platform framework
- **Model Viewer Plus**: For 3D rendering capabilities
- **Isar Team**: For the fast local database solution
- **Provider Team**: For state management
- **Vector Math**: For 3D mathematics and transformations
- **Community**: For feedback, contributions, and support

## 🎓 Educational & Research Applications

### Academic Use Cases
- **Morphological Analysis**: Study shape variations in biological specimens
- **Statistical Shape Analysis**: Apply Procrustes methods for research
- **Comparative Studies**: Analyze differences between populations or species
- **Data Visualization**: Present 3D comparison results in academic papers

### Industry Applications
- **Quality Control**: Validate manufacturing precision in 3D printed objects
- **Reverse Engineering**: Compare original designs with reconstructed models
- **Archaeological Studies**: Analyze artifacts and historical objects
- **Forensic Analysis**: Compare evidence in 3D crime scene reconstruction

## 🔬 Scientific Methodology

### Procrustes Analysis
This tool implements **Generalized Procrustes Analysis (GPA)**, a statistical method for:
- **Shape Alignment**: Removing translation, rotation, and scale differences
- **Quantitative Comparison**: Measuring shape similarities and differences
- **Statistical Validation**: Providing confidence intervals and significance tests
- **Reproducible Results**: Ensuring consistent analysis across different users

### Supported File Formats

#### 📊 File Format Support Overview

| Format | Loading | 3D Rendering | Procrustes Analysis | Data Export |
|--------|---------|--------------|---------------------|-------------|
| **GLB** | ✅ | ✅ Full 3D | ✅ | ✅ |
| **GLTF** | ✅ | ✅ Full 3D | ✅ | ✅ |
| **OBJ** | ✅ | ⚠️ Placeholder | ✅ | ✅ |
| **STL** | ✅ | ⚠️ Placeholder | ✅ | ✅ |

#### 🎨 Real-Time 3D Rendering (GLB/GLTF)
**Fully Supported Formats:**
- **.glb**: GL Transmission Format Binary - Optimized for web and real-time rendering
- **.gltf**: GL Transmission Format JSON - Modern 3D format with full material support

**Platform Support for 3D Rendering:**

| Platform | Native Rendering | Textured Rendering | Recommendation |
|----------|-----------------|-------------------|----------------|
| **macOS Desktop** 🍎 | ✅ Full Support | Point Cloud | **RECOMMENDED** - Best performance |
| **iOS (iPhone, iPad)** | ✅ Full Support | ✅ Full Support | Excellent for mobile |
| **Android** | ✅ Full Support | ✅ Full Support | Excellent for mobile |
| **Web (Chrome, Firefox, Safari)** | ✅ Full Support | ✅ Full Support | Requires hosted files |
| **Windows Desktop** | ⚠️ Point Cloud | ⚠️ Limited | Use web version |
| **Linux Desktop** | ⚠️ Point Cloud | ⚠️ Limited | Use web version |

**Features:**
- ✅ Full 3D visualization with textures and materials
- ✅ Interactive camera controls (orbit, zoom, pan)
- ✅ Auto-rotation and animations
- ✅ WebGL-optimized rendering
- ✅ AR support (iOS/Android)
- ✅ Cross-platform compatibility

**Platform-Specific Notes:**
- **macOS Desktop** 🍎 **(RECOMMENDED)**: Native 3D point cloud rendering using CustomPainter for all formats (OBJ, STL, GLTF, GLB). Features interactive rotation, zoom controls, and excellent performance. No WebView dependency required. Works perfectly with local files.
- **Mobile (iOS/Android)**: Full support with local file loading and WebView-based rendering for textured models.
- **Web Platform**: Requires files to be hosted on a server or use data URLs. Local file system access is restricted for security.
- **Windows/Linux Desktop**: Point cloud rendering available for formats with vertex data. Use web version for textured rendering.

#### 📐 All Formats Fully Supported

**All file formats now support 3D rendering and analysis:**
- **.obj**: Wavefront OBJ format - ✅ Native rendering on macOS, iOS, Android
- **.stl**: Stereolithography format - ✅ Native rendering on macOS, iOS, Android
- **.gltf**: GL Transmission Format - ✅ Native rendering on all platforms
- **.glb**: GL Binary Format - ✅ Native rendering on all platforms

**Features on macOS (Recommended Platform):**
- ✅ **Full 3D point cloud rendering** for all formats
- ✅ Interactive rotation (mouse drag) and zoom (scroll wheel)
- ✅ Perspective-based depth visualization
- ✅ Procrustes analysis with scientific metrics
- ✅ Complete log capture and TXT export
- ✅ Local file loading (no hosting required)
- ✅ Excellent performance with large models

**Features on Other Platforms:**
- **iOS/Android**: Full textured rendering for GLB/GLTF, point cloud for OBJ/STL
- **Web**: Point cloud rendering for all formats, textured rendering requires hosted files
- **Windows/Linux**: Point cloud rendering available

#### 🔄 Converting OBJ/STL to GLB

**Option 1: Online Converters**
- https://products.aspose.app/3d/conversion/obj-to-glb
- https://anyconv.com/obj-to-glb-converter/

**Option 2: Blender (Free)**
```bash
# Install Blender, then:
File → Import → Wavefront (.obj)
File → Export → glTF 2.0 (.glb)
```

**Option 3: Command Line (Node.js)**
```bash
npm install -g obj2gltf
obj2gltf -i model.obj -o model.glb
```

**Option 4: Python**
```bash
pip install trimesh
python -c "import trimesh; trimesh.load('model.obj').export('model.glb')"
```

#### 📦 Sample Models for Testing

**Download Free GLB Models:**
- [Khronos glTF Sample Models](https://github.com/KhronosGroup/glTF-Sample-Models/tree/master/2.0)
- [Sketchfab](https://sketchfab.com/features/gltf) (filter by "Downloadable")
- [Poly Pizza](https://poly.pizza/) (free 3D models in GLB format)

#### 🔮 Future Format Support
Plans to add support for:
- **.ply**: Polygon File Format (point cloud data)
- **.dae**: COLLADA format
- **.fbx**: Autodesk format (gaming/animation)
- **.3ds**: 3D Studio format
- Direct OBJ→GLB runtime conversion

---

**3D Object Comparison Tool** - Professional scientific analysis platform for geology, gaming, and medical applications with advanced Procrustes analysis. **Best experienced on macOS** with native 3D rendering for all file formats.