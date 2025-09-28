#!/bin/bash

# Deploy Flutter Web App to GitHub Pages
# This script builds the Flutter web app and prepares it for GitHub Pages deployment

set -e

echo "🚀 Starting Flutter Web Deployment..."

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found. Please run this script from the Flutter project root."
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run tests
echo "🧪 Running tests..."
flutter test

# Build web app for production
echo "🔨 Building web app for production..."
flutter build web --release

# Check if build was successful
if [ ! -d "build/web" ]; then
    echo "❌ Error: Build failed. build/web directory not found."
    exit 1
fi

echo "✅ Build completed successfully!"
echo "📁 Web app built in: build/web"
echo ""
echo "🌐 To deploy to GitHub Pages:"
echo "1. Push your changes to the main branch"
echo "2. GitHub Actions will automatically build and deploy"
echo "3. Your app will be available at: https://[your-username].github.io/[repository-name]"
echo ""
echo "🔧 For local testing, you can serve the built app with:"
echo "   cd build/web && python3 -m http.server 8000"
echo "   Then visit: http://localhost:8000"
