#!/bin/bash

# Create DMG for 3D Object Comparison Tool v1.0.0
# This script creates a professional DMG installer for macOS

set -e

APP_NAME="3D Object Comparison Tool"
APP_VERSION="1.0.0"
DMG_NAME="3D_Object_Comparison_Tool_v${APP_VERSION}.dmg"
APP_PATH="build/macos/Build/Products/Release/flutter_3d_app.app"
DMG_TEMP_DIR="dmg_temp"
DMG_MOUNT_POINT="/tmp/dmg_mount"

echo "🚀 Creating DMG for ${APP_NAME} v${APP_VERSION}..."

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: App not found at $APP_PATH"
    echo "Please run 'flutter build macos --release' first"
    exit 1
fi

# Clean up any existing DMG
rm -f "$DMG_NAME"

# Create temporary directory for DMG contents
rm -rf "$DMG_TEMP_DIR"
mkdir -p "$DMG_TEMP_DIR"

# Copy app to temp directory
echo "📦 Copying app to temporary directory..."
cp -R "$APP_PATH" "$DMG_TEMP_DIR/"

# Create Applications symlink
echo "🔗 Creating Applications symlink..."
ln -s /Applications "$DMG_TEMP_DIR/Applications"

# Create README file
echo "📝 Creating README..."
cat > "$DMG_TEMP_DIR/README.txt" << EOF
3D Object Comparison Tool v${APP_VERSION}
========================================

Installation:
1. Drag the "flutter_3d_app.app" to the Applications folder
2. Launch the app from Applications or Spotlight

System Requirements:
- macOS 10.14 or later
- Intel or Apple Silicon Mac

Features:
- Native 3D rendering for OBJ, STL, GLTF, and GLB files
- Scientific Procrustes analysis with statistical metrics
- Interactive 3D point cloud visualization
- Comprehensive export functionality

For support and documentation, visit:
https://github.com/AminMemariani/3d_object_compare

© 2025 - Licensed under GPL v3.0
EOF

# Create a background image (simple text-based)
echo "🎨 Creating background image..."
# We'll create a simple text file as background info
cat > "$DMG_TEMP_DIR/Installation Instructions.txt" << EOF
🍎 3D Object Comparison Tool v${APP_VERSION}
===========================================

📥 INSTALLATION:
1. Drag "flutter_3d_app.app" to the Applications folder
2. Launch from Applications or use Spotlight search

✨ FEATURES:
• Native 3D rendering for all major formats
• Scientific Procrustes analysis
• Interactive point cloud visualization
• Professional export capabilities

🔧 SYSTEM REQUIREMENTS:
• macOS 10.14 or later
• Intel or Apple Silicon Mac

📚 DOCUMENTATION:
https://github.com/AminMemariani/3d_object_compare

🎯 RECOMMENDED FOR:
• Scientific research
• 3D model analysis
• Academic projects
• Professional applications

© 2025 - GPL v3.0 License
EOF

# Create the DMG
echo "💿 Creating DMG file..."
hdiutil create -volname "${APP_NAME} v${APP_VERSION}" \
    -srcfolder "$DMG_TEMP_DIR" \
    -ov \
    -format UDZO \
    "$DMG_NAME"

# Clean up
echo "🧹 Cleaning up..."
rm -rf "$DMG_TEMP_DIR"

# Get file size
DMG_SIZE=$(du -h "$DMG_NAME" | cut -f1)

echo "✅ DMG created successfully!"
echo "📁 File: $DMG_NAME"
echo "📊 Size: $DMG_SIZE"
echo "🎉 Ready for distribution!"

# Optional: Open DMG to verify
echo "🔍 Opening DMG for verification..."
open "$DMG_NAME"
