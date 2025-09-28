@echo off
REM Deploy Flutter Web App to GitHub Pages
REM This script builds the Flutter web app and prepares it for GitHub Pages deployment

echo 🚀 Starting Flutter Web Deployment...

REM Check if we're in the right directory
if not exist "pubspec.yaml" (
    echo ❌ Error: pubspec.yaml not found. Please run this script from the Flutter project root.
    exit /b 1
)

REM Clean previous builds
echo 🧹 Cleaning previous builds...
flutter clean

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Run tests
echo 🧪 Running tests...
flutter test

REM Build web app for production
echo 🔨 Building web app for production...
flutter build web --release

REM Check if build was successful
if not exist "build\web" (
    echo ❌ Error: Build failed. build\web directory not found.
    exit /b 1
)

echo ✅ Build completed successfully!
echo 📁 Web app built in: build\web
echo.
echo 🌐 To deploy to GitHub Pages:
echo 1. Push your changes to the main branch
echo 2. GitHub Actions will automatically build and deploy
echo 3. Your app will be available at: https://aminmemariani.github.io/3d_object_compare
echo.
echo 🔧 For local testing, you can serve the built app with:
echo    cd build\web ^&^& python -m http.server 8000
echo    Then visit: http://localhost:8000

pause
