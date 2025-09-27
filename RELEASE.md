# 3D Object Viewer - Release Guide

This document provides comprehensive instructions for building and releasing the 3D Object Viewer application across all supported platforms.

## 🚀 Quick Start

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

### Build All Platforms

#### Unix/Linux/macOS:
```bash
# Build all platforms
./scripts/build_all.sh

# Build specific platforms
./scripts/build_all.sh --platform web --platform android

# Clean build
./scripts/build_all.sh --clean

# Skip tests and analysis
./scripts/build_all.sh --skip-tests --skip-analysis
```

#### Windows:
```cmd
# Build all platforms
scripts\build_all.bat

# Build specific platforms
scripts\build_all.bat --platform web --platform android

# Clean build
scripts\build_all.bat --clean

# Skip tests and analysis
scripts\build_all.bat --skip-tests --skip-analysis
```

## 📱 Platform-Specific Build Instructions

### Web
```bash
flutter build web --release --web-renderer html
```
- **Output**: `build/web/`
- **Deployment**: Upload contents to web server
- **Features**: Progressive Web App support

### Android
```bash
# APK for direct installation
flutter build apk --release

# App Bundle for Google Play Store
flutter build appbundle --release
```
- **APK Output**: `build/app/outputs/flutter-apk/`
- **Bundle Output**: `build/app/outputs/bundle/`
- **Requirements**: Android API level 21+

### iOS
```bash
# Development build (no code signing)
flutter build ios --release --no-codesign

# App Store build (requires code signing)
flutter build ios --release
```
- **Output**: `build/ios/`
- **Requirements**: iOS 12.0+, Xcode 14+
- **Note**: App Store builds require valid Apple Developer account

### Windows
```bash
flutter build windows --release
```
- **Output**: `build/windows/runner/Release/`
- **Requirements**: Windows 10+, Visual Studio 2022
- **Distribution**: Create installer with NSIS or similar

### macOS
```bash
flutter build macos --release
```
- **Output**: `build/macos/Build/Products/Release/`
- **Requirements**: macOS 10.14+, Xcode 14+
- **Distribution**: Create .dmg with create-dmg

### Linux
```bash
flutter build linux --release
```
- **Output**: `build/linux/x64/release/bundle/`
- **Requirements**: Ubuntu 18.04+, GTK 3.0
- **Distribution**: Create .deb, .rpm, or AppImage

## 🔧 Configuration

### App Configuration

Edit `scripts/release_config.yaml` to customize:
- App metadata (name, version, description)
- Build settings for each platform
- Code signing certificates
- Deployment targets

### Platform-Specific Settings

#### Android (`android/app/build.gradle`)
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

#### iOS (`ios/Runner.xcodeproj`)
- Update bundle identifier
- Configure signing certificates
- Set deployment target

#### Web (`web/index.html`)
- Update meta tags
- Configure PWA settings
- Set up service worker

## 🏗️ Automated Builds

### GitHub Actions

The repository includes automated CI/CD workflows:

1. **Build and Test** (`build_and_test.yml`)
   - Runs on every push
   - Tests code, runs analysis
   - Builds for all platforms

2. **Release** (`build_and_release.yml`)
   - Triggers on version tags (v1.0.0)
   - Creates GitHub releases
   - Deploys web version

### Manual Workflow Trigger

```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0
```

## 📦 Distribution

### Web Deployment

#### GitHub Pages
```bash
# Build and deploy
flutter build web --release
# Upload build/web/ to GitHub Pages
```

#### Firebase Hosting
```bash
npm install -g firebase-tools
firebase login
firebase init hosting
flutter build web --release
firebase deploy
```

#### Netlify/Vercel
```bash
flutter build web --release
# Deploy build/web/ folder
```

### Mobile Distribution

#### Android
1. **Google Play Store**:
   - Upload `app-release.aab` to Play Console
   - Configure store listing
   - Submit for review

2. **Direct Distribution**:
   - Share `app-release.apk` file
   - Users need to enable "Install from unknown sources"

#### iOS
1. **App Store**:
   - Archive in Xcode
   - Upload to App Store Connect
   - Submit for review

2. **TestFlight**:
   - Upload build for beta testing
   - Invite testers

### Desktop Distribution

#### Windows
1. **Microsoft Store**:
   - Package as MSIX
   - Submit to Partner Center

2. **Direct Distribution**:
   - Create installer with NSIS
   - Host on website

#### macOS
1. **Mac App Store**:
   - Archive in Xcode
   - Submit to App Store Connect

2. **Direct Distribution**:
   - Create .dmg installer
   - Notarize for distribution

#### Linux
1. **Package Managers**:
   - Create .deb for Debian/Ubuntu
   - Create .rpm for Red Hat/Fedora
   - Create AppImage for universal distribution

2. **Snap Store**:
   - Package as snap
   - Submit to Snap Store

## 🔐 Code Signing

### Android
```bash
# Generate keystore
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Configure signing in android/app/build.gradle
```

### iOS/macOS
1. Create certificates in Apple Developer Portal
2. Download and install provisioning profiles
3. Configure in Xcode project settings

### Windows
```bash
# Create certificate
New-SelfSignedCertificate -Type CodeSigningCert -Subject "CN=Your Name" \
  -KeyUsage DigitalSignature -FriendlyName "Your Certificate" \
  -CertStoreLocation "Cert:\CurrentUser\My"
```

## 🧪 Testing Releases

### Pre-Release Checklist

- [ ] All tests pass
- [ ] Code analysis clean
- [ ] Performance benchmarks met
- [ ] UI/UX testing completed
- [ ] Platform-specific testing done
- [ ] Security review completed
- [ ] Documentation updated

### Testing Strategy

1. **Unit Tests**: `flutter test`
2. **Integration Tests**: `flutter test integration_test/`
3. **Platform Testing**: Manual testing on each platform
4. **Performance Testing**: Profile builds for performance
5. **Security Testing**: Scan for vulnerabilities

## 📊 Release Notes

### Version 1.0.0

**Features:**
- Load and view 3D objects (.obj, .stl formats)
- Interactive 3D navigation with gesture controls
- Procrustes superimposition analysis
- Detailed similarity metrics and reporting
- Export results as JSON/CSV
- Cross-platform support (Web, Desktop, Mobile)
- Tutorial system for new users
- Advanced 3D visualization tools

**Technical Improvements:**
- Clean architecture with MVVM pattern
- Dependency injection with GetIt
- Local storage with Isar database
- Background processing with isolates
- Material 3 design system
- Responsive UI with animated transitions

## 🆘 Troubleshooting

### Common Issues

1. **Build Failures**:
   - Check Flutter version compatibility
   - Verify platform-specific dependencies
   - Clean build cache: `flutter clean`

2. **Code Signing Issues**:
   - Verify certificates are valid
   - Check provisioning profiles
   - Ensure proper keychain access

3. **Platform-Specific Errors**:
   - Update platform tools
   - Check system requirements
   - Verify environment setup

### Getting Help

- Check Flutter documentation
- Review platform-specific guides
- Search GitHub issues
- Contact development team

## 📈 Future Releases

### Planned Features

- [ ] Cloud synchronization
- [ ] Multi-object comparison
- [ ] AI-based auto-alignment
- [ ] Advanced mesh analysis
- [ ] Collaborative features
- [ ] Plugin system

### Release Schedule

- **Major releases**: Every 6 months
- **Minor releases**: Every 2 months
- **Patch releases**: As needed
- **Hotfixes**: Immediate

---

For more information, visit the [project repository](https://github.com/yourusername/flutter_3d_app).
