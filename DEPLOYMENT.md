# 3D Object Viewer - Deployment Guide

This guide provides comprehensive instructions for deploying the 3D Object Viewer application across all supported platforms and distribution channels.

## 🚀 Quick Deployment

### Automated Deployment (Recommended)

```bash
# Build and package all platforms
./scripts/build_all.sh

# Create distribution packages
./scripts/package_release.sh

# Deploy to GitHub Releases (if configured)
git tag v1.0.0
git push origin v1.0.0
```

### Manual Deployment

Follow the platform-specific sections below for detailed deployment instructions.

## 🌐 Web Deployment

### GitHub Pages

1. **Build the web version**:
   ```bash
   flutter build web --release --base-href /flutter_3d_app/
   ```

2. **Deploy to GitHub Pages**:
   ```bash
   # Copy build/web/ contents to gh-pages branch
   git subtree push --prefix build/web origin gh-pages
   ```

3. **Configure GitHub Pages**:
   - Go to repository Settings → Pages
   - Set source to "Deploy from a branch"
   - Select `gh-pages` branch
   - Access at: `https://yourusername.github.io/flutter_3d_app/`

### Firebase Hosting

1. **Install Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   ```

2. **Initialize Firebase project**:
   ```bash
   firebase login
   firebase init hosting
   ```

3. **Configure firebase.json**:
   ```json
   {
     "hosting": {
       "public": "build/web",
       "ignore": [
         "firebase.json",
         "**/.*",
         "**/node_modules/**"
       ],
       "rewrites": [
         {
           "source": "**",
           "destination": "/index.html"
         }
       ]
     }
   }
   ```

4. **Deploy**:
   ```bash
   flutter build web --release
   firebase deploy
   ```

### Netlify

1. **Build the project**:
   ```bash
   flutter build web --release
   ```

2. **Deploy options**:
   - **Drag & Drop**: Upload `build/web/` folder to Netlify
   - **Git Integration**: Connect repository and set build command
   - **CLI**: `npm install -g netlify-cli && netlify deploy --dir=build/web`

3. **Configure redirects** (netlify.toml):
   ```toml
   [[redirects]]
     from = "/*"
     to = "/index.html"
     status = 200
   ```

### Vercel

1. **Install Vercel CLI**:
   ```bash
   npm install -g vercel
   ```

2. **Deploy**:
   ```bash
   flutter build web --release
   cd build/web
   vercel --prod
   ```

3. **Configure vercel.json**:
   ```json
   {
     "rewrites": [
       {
         "source": "/(.*)",
         "destination": "/index.html"
       }
     ]
   }
   ```

## 📱 Mobile Deployment

### Android

#### Google Play Store

1. **Build App Bundle**:
   ```bash
   flutter build appbundle --release
   ```

2. **Upload to Play Console**:
   - Go to [Google Play Console](https://play.google.com/console)
   - Create new app or select existing
   - Upload `build/app/outputs/bundle/release/app-release.aab`
   - Configure store listing, content rating, pricing
   - Submit for review

3. **Release Management**:
   - **Internal Testing**: Test with limited users
   - **Closed Testing**: Beta testing with larger group
   - **Open Testing**: Public beta
   - **Production**: Public release

#### Direct Distribution (APK)

1. **Build APK**:
   ```bash
   flutter build apk --release
   ```

2. **Distribution methods**:
   - **Website**: Host APK for direct download
   - **Email**: Send APK file directly
   - **File sharing**: Use services like Dropbox, Google Drive
   - **Alternative stores**: Amazon Appstore, F-Droid

3. **Security considerations**:
   - Sign APK with release keystore
   - Provide clear installation instructions
   - Warn about "Unknown sources" requirement

### iOS

#### App Store

1. **Build for App Store**:
   ```bash
   flutter build ios --release
   ```

2. **Archive in Xcode**:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select "Any iOS Device" as target
   - Product → Archive
   - Upload to App Store Connect

3. **App Store Connect**:
   - Create app record
   - Upload build
   - Configure app information
   - Submit for review

#### TestFlight (Beta Testing)

1. **Upload to TestFlight**:
   - Archive in Xcode
   - Upload to App Store Connect
   - Configure TestFlight settings
   - Add internal/external testers

2. **Beta Testing Process**:
   - Internal testing: Up to 100 internal testers
   - External testing: Up to 10,000 external testers
   - Feedback collection and iteration

## 🖥️ Desktop Deployment

### Windows

#### Microsoft Store

1. **Prepare for Store**:
   ```bash
   flutter build windows --release
   ```

2. **Create MSIX Package**:
   - Use [MSIX Packaging Tool](https://docs.microsoft.com/en-us/windows/msix/packaging-tool/tool-overview)
   - Configure package manifest
   - Sign with certificate

3. **Partner Center**:
   - Upload MSIX package
   - Configure store listing
   - Submit for certification

#### Direct Distribution

1. **Create Installer**:
   ```bash
   # Use the packaging script
   ./scripts/package_release.sh
   ```

2. **Distribution methods**:
   - **Website**: Host installer for download
   - **GitHub Releases**: Attach to release
   - **Software repositories**: Submit to download sites

### macOS

#### Mac App Store

1. **Build for App Store**:
   ```bash
   flutter build macos --release
   ```

2. **Archive in Xcode**:
   - Open `macos/Runner.xcworkspace`
   - Archive the project
   - Upload to App Store Connect

3. **App Store Connect**:
   - Create app record
   - Configure app information
   - Submit for review

#### Direct Distribution

1. **Create DMG**:
   ```bash
   # Use the packaging script
   ./scripts/package_release.sh
   ```

2. **Notarization** (Required for macOS 10.15+):
   ```bash
   # Submit for notarization
   xcrun notarytool submit app.dmg --apple-id "your@email.com" --password "app-password" --team-id "TEAM_ID"
   
   # Staple notarization
   xcrun stapler staple app.dmg
   ```

### Linux

#### Package Managers

1. **Debian/Ubuntu (.deb)**:
   ```bash
   # Use the packaging script
   ./scripts/package_release.sh
   ```

2. **Red Hat/Fedora (.rpm)**:
   ```bash
   # Use the packaging script
   ./scripts/package_release.sh
   ```

3. **Snap Store**:
   ```bash
   # Create snap package
   snapcraft
   snapcraft upload app.snap
   ```

#### Direct Distribution

1. **AppImage**:
   ```bash
   # Use the packaging script
   ./scripts/package_release.sh
   ```

2. **Distribution methods**:
   - **GitHub Releases**: Attach to release
   - **Website**: Host for download
   - **Software repositories**: Submit to repositories

## 🔄 Continuous Deployment

### GitHub Actions

The repository includes automated deployment workflows:

1. **Build and Test** (`build_and_test.yml`):
   - Runs on every push
   - Tests code and builds for all platforms
   - Uploads artifacts

2. **Release** (`build_and_release.yml`):
   - Triggers on version tags
   - Creates GitHub releases
   - Deploys web version

### Configuration

1. **Secrets** (Repository Settings → Secrets):
   ```
   FIREBASE_TOKEN=your_firebase_token
   NETLIFY_TOKEN=your_netlify_token
   VERCEL_TOKEN=your_vercel_token
   ```

2. **Environment Variables**:
   ```yaml
   env:
     FLUTTER_VERSION: '3.x'
     BUILD_MODE: 'release'
   ```

### Manual Trigger

```bash
# Create and push version tag
git tag v1.0.0
git push origin v1.0.0

# Or trigger manually in GitHub Actions
```

## 📊 Release Management

### Version Strategy

- **Semantic Versioning**: `MAJOR.MINOR.PATCH`
- **Major**: Breaking changes
- **Minor**: New features, backward compatible
- **Patch**: Bug fixes

### Release Process

1. **Pre-release**:
   - Update version in `pubspec.yaml`
   - Update changelog
   - Test on all platforms
   - Create release branch

2. **Release**:
   - Tag version
   - Push to trigger CI/CD
   - Monitor deployment status
   - Verify all platforms

3. **Post-release**:
   - Monitor user feedback
   - Track download metrics
   - Plan next release

### Rollback Strategy

1. **Web**: Revert to previous deployment
2. **Mobile**: Release hotfix or rollback
3. **Desktop**: Update installer or release patch

## 🔒 Security Considerations

### Code Signing

1. **Android**:
   - Use release keystore
   - Keep keystore secure
   - Document signing process

2. **iOS/macOS**:
   - Use Apple Developer certificates
   - Configure provisioning profiles
   - Enable App Store Connect API

3. **Windows**:
   - Use Authenticode certificate
   - Configure signing in build process

### Security Best Practices

1. **Dependencies**:
   - Keep dependencies updated
   - Use `flutter pub audit`
   - Monitor security advisories

2. **Permissions**:
   - Request minimal permissions
   - Document permission usage
   - Handle permission denials

3. **Data Protection**:
   - Encrypt sensitive data
   - Use secure storage
   - Implement proper authentication

## 📈 Analytics and Monitoring

### Web Analytics

1. **Google Analytics**:
   ```html
   <!-- Add to web/index.html -->
   <script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
   ```

2. **Firebase Analytics**:
   ```dart
   // Add to main.dart
   FirebaseAnalytics.instance.logEvent(name: 'app_started');
   ```

### Error Tracking

1. **Sentry**:
   ```dart
   // Add to main.dart
   await Sentry.init((options) {
     options.dsn = 'YOUR_SENTRY_DSN';
   });
   ```

2. **Firebase Crashlytics**:
   ```dart
   // Add to main.dart
   FirebaseCrashlytics.instance.recordError(error, stackTrace);
   ```

### Performance Monitoring

1. **Firebase Performance**:
   ```dart
   // Add to main.dart
   FirebasePerformance.instance.isCollectionEnabled = true;
   ```

2. **Custom Metrics**:
   ```dart
   // Track custom metrics
   FirebaseAnalytics.instance.logEvent(
     name: '3d_object_loaded',
     parameters: {'file_size': fileSize, 'load_time': loadTime},
   );
   ```

## 🆘 Troubleshooting

### Common Issues

1. **Build Failures**:
   - Check Flutter version
   - Verify platform dependencies
   - Clean build cache

2. **Deployment Failures**:
   - Check CI/CD logs
   - Verify secrets and tokens
   - Test deployment locally

3. **Platform-Specific Issues**:
   - Check platform requirements
   - Verify certificates and signing
   - Review platform guidelines

### Support Channels

- **GitHub Issues**: Technical issues and bug reports
- **Discord/Slack**: Community support
- **Email**: Direct support for critical issues
- **Documentation**: Self-service help

---

For more information, visit the [project repository](https://github.com/yourusername/flutter_3d_app).
