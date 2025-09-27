# 3D Object Viewer

A professional-grade Flutter application for loading, viewing, and comparing 3D objects with advanced Procrustes analysis. Built with clean architecture principles and supporting all major platforms.

## Features

### Core Functionality
- **3D Object Loading**: Support for .obj and .stl file formats
- **Interactive 3D Navigation**: Gesture-based camera controls (orbit, zoom, pan)
- **Procrustes Analysis**: Advanced statistical alignment and comparison of 3D objects
- **Similarity Metrics**: Detailed analysis with RMSE, standard deviation, and similarity scores
- **Export Results**: JSON and CSV export capabilities
- **Superimposed Viewing**: Overlay multiple objects with adjustable opacity

### User Experience
- **Tutorial System**: Interactive onboarding for new users
- **Animated Transitions**: Smooth page transitions and UI animations
- **Material 3 Design**: Modern, responsive user interface
- **Dark/Light Themes**: Automatic theme switching
- **Cross-platform**: Native support for Web, Desktop, and Mobile

### Technical Features
- **Clean Architecture**: MVVM pattern with dependency injection
- **State Management**: Provider pattern with reactive updates
- **Local Storage**: Isar database for preferences and data persistence
- **Background Processing**: Isolate-based Procrustes analysis
- **Extension System**: Plugin architecture for future enhancements

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

## Dependencies

### Core Dependencies
- `provider`: State management
- `isar`: Local database for user preferences
- `equatable`: Value equality for entities
- `dartz`: Functional programming utilities
- `get_it`: Dependency injection

### 3D Rendering
- `model_viewer_plus`: 3D model viewing with AR support
- `flutter_gl`: OpenGL rendering
- `ar_flutter_plugin`: Augmented reality functionality

### Utilities
- `path_provider`: File system access
- `shared_preferences`: Simple key-value storage

## Getting Started

### Prerequisites
- Flutter SDK 3.32.6 or later
- Dart SDK 3.8.1 or later
- Platform-specific development tools:
  - **Web**: No additional requirements
  - **Android**: Android Studio, Android SDK
  - **iOS**: Xcode, macOS
  - **Windows**: Visual Studio with C++ tools
  - **macOS**: Xcode
  - **Linux**: CMake, Ninja, GTK development libraries

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

1. **Load 3D Objects**: Tap "Load Object A" and "Load Object B" to select .obj or .stl files
2. **Navigate to Viewer**: Tap "View Objects" to open the 3D viewer
3. **Transform Objects**: Use the control panel to align Object B with Object A
4. **Run Analysis**: Tap "Compare" to perform Procrustes analysis
5. **Export Results**: Save analysis results as JSON or CSV files

### Platform-Specific Setup

#### Android
- Minimum SDK version: 21 (Android 5.0)
- Target SDK version: 34
- Permissions: Camera, Storage access

#### iOS
- Minimum iOS version: 12.0
- ARKit support for AR features
- Permissions: Camera, Photo Library access

#### Web
- Modern web browser with WebGL support
- HTTPS required for AR features
- Progressive Web App (PWA) support

#### Desktop (Windows, macOS, Linux)
- Windows 10 or later
- macOS 10.14 or later
- Ubuntu 18.04+ or equivalent Linux distribution

## Usage

### Basic Workflow
1. **Load Objects**: Use "Load Object A" and "Load Object B" buttons to select 3D files
2. **Navigate**: Tap "View Objects" to open the interactive 3D viewer
3. **Transform**: Use the control panel to move, rotate, and scale Object B
4. **Align**: Position Object B to match Object A as closely as possible
5. **Analyze**: Tap "Compare" to run Procrustes analysis
6. **Review**: Examine detailed similarity metrics and visualizations
7. **Export**: Save results as JSON or CSV for further analysis

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
- 3D object loading (.obj, .stl formats)
- Interactive 3D navigation with gesture controls
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

---

**3D Object Viewer** - Professional 3D model comparison tool with advanced Procrustes analysis.