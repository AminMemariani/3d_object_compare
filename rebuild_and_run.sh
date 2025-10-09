#!/bin/bash

# Complete rebuild script for flutter_3d_compare

echo "🧹 Step 1: Complete clean..."
flutter clean
rm -rf build/
rm -rf macos/build/

echo "📦 Step 2: Get dependencies..."
flutter pub get

echo "🔨 Step 3: Build macOS app..."
flutter build macos --debug

echo "🚀 Step 4: Run the app..."
echo ""
echo "========================================"
echo "WATCH THE CONSOLE OUTPUT BELOW"
echo "When app opens, click 'Object A' button"
echo "Look for lines starting with 📁"
echo "========================================"
echo ""

flutter run -d macos -v

