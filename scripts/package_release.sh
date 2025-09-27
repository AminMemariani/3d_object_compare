#!/bin/bash

# 3D Object Viewer - Release Packaging Script
# This script creates distribution packages for all platforms

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BUILD_DIR="./build/app_releases"
PACKAGE_DIR="./build/packages"
VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)
BUILD_NUMBER=$(grep 'version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f2)

echo -e "${BLUE}🚀 3D Object Viewer Release Packaging v${VERSION}+${BUILD_NUMBER}${NC}"
echo "=================================================="

# Create directories
mkdir -p "$BUILD_DIR"
mkdir -p "$PACKAGE_DIR"

# Function to print status
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to create zip archive
create_zip() {
    local source_dir="$1"
    local zip_name="$2"
    local target_dir="$3"
    
    if [ -d "$source_dir" ]; then
        cd "$source_dir"
        zip -r -9 "../../../${target_dir}/${zip_name}" . >/dev/null
        cd - >/dev/null
        print_status "Created ${zip_name}"
    else
        print_warning "Source directory ${source_dir} not found, skipping ${zip_name}"
    fi
}

# Function to create tar.gz archive
create_tar_gz() {
    local source_dir="$1"
    local tar_name="$2"
    local target_dir="$3"
    
    if [ -d "$source_dir" ]; then
        tar -czf "${target_dir}/${tar_name}" -C "$source_dir" . >/dev/null
        print_status "Created ${tar_name}"
    else
        print_warning "Source directory ${source_dir} not found, skipping ${tar_name}"
    fi
}

# Function to create AppImage (Linux)
create_appimage() {
    local source_dir="$1"
    local app_name="$2"
    local target_dir="$3"
    
    if [ -d "$source_dir" ]; then
        # Create AppDir structure
        local appdir="${target_dir}/${app_name}.AppDir"
        mkdir -p "$appdir"
        
        # Copy application files
        cp -r "${source_dir}"/* "$appdir/"
        
        # Create desktop file
        cat > "$appdir/${app_name}.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=3D Object Viewer
Comment=Professional 3D model comparison tool
Exec=${app_name}
Icon=${app_name}
Terminal=false
Categories=Graphics;3DGraphics;
EOF
        
        # Create AppRun script
        cat > "$appdir/AppRun" << EOF
#!/bin/bash
HERE="\$(dirname "\$(readlink -f "\${0}")")"
export LD_LIBRARY_PATH="\${HERE}/lib:\${LD_LIBRARY_PATH}"
exec "\${HERE}/${app_name}" "\$@"
EOF
        chmod +x "$appdir/AppRun"
        
        # Download and use appimagetool if available
        if command_exists appimagetool; then
            appimagetool "$appdir" "${target_dir}/${app_name}-${VERSION}.AppImage"
            print_status "Created ${app_name}-${VERSION}.AppImage"
        else
            print_warning "appimagetool not found, creating tar.gz instead"
            create_tar_gz "$appdir" "${app_name}-${VERSION}.tar.gz" "$target_dir"
        fi
        
        # Clean up
        rm -rf "$appdir"
    else
        print_warning "Source directory ${source_dir} not found, skipping AppImage creation"
    fi
}

# Function to create macOS DMG
create_dmg() {
    local app_bundle="$1"
    local dmg_name="$2"
    local target_dir="$3"
    
    if [ -d "$app_bundle" ]; then
        if command_exists create-dmg; then
            create-dmg \
                --volname "3D Object Viewer" \
                --volicon "assets/icons/app_icon.icns" \
                --window-pos 200 120 \
                --window-size 800 400 \
                --icon-size 100 \
                --icon "3D Object Viewer.app" 200 190 \
                --hide-extension "3D Object Viewer.app" \
                --app-drop-link 600 185 \
                "${target_dir}/${dmg_name}" \
                "$app_bundle"
            print_status "Created ${dmg_name}"
        else
            print_warning "create-dmg not found, creating zip instead"
            create_zip "$app_bundle" "${dmg_name%.dmg}.zip" "$target_dir"
        fi
    else
        print_warning "App bundle ${app_bundle} not found, skipping DMG creation"
    fi
}

# Function to create Windows installer
create_windows_installer() {
    local source_dir="$1"
    local installer_name="$2"
    local target_dir="$3"
    
    if [ -d "$source_dir" ]; then
        # Create NSIS script
        local nsis_script="${target_dir}/installer.nsi"
        cat > "$nsis_script" << EOF
!define APPNAME "3D Object Viewer"
!define COMPANYNAME "Flutter 3D App"
!define DESCRIPTION "Professional 3D model comparison tool"
!define VERSIONMAJOR 1
!define VERSIONMINOR 0
!define VERSIONBUILD ${BUILD_NUMBER}
!define HELPURL "https://github.com/yourusername/flutter_3d_app"
!define UPDATEURL "https://github.com/yourusername/flutter_3d_app/releases"
!define ABOUTURL "https://github.com/yourusername/flutter_3d_app"
!define INSTALLSIZE 50000

RequestExecutionLevel admin
InstallDir "\$PROGRAMFILES\\\${APPNAME}"
Name "\${APPNAME}"
outFile "${installer_name}"
Icon "assets/icons/app_icon.ico"

page directory
page instfiles

section "install"
    setOutPath \$INSTDIR
    file /r "${source_dir}/*"
    writeUninstaller "\$INSTDIR\\uninstall.exe"
    createDirectory "\$SMPROGRAMS\\\${APPNAME}"
    createShortCut "\$SMPROGRAMS\\\${APPNAME}\\\${APPNAME}.lnk" "\$INSTDIR\\flutter_3d_app.exe"
    createShortCut "\$DESKTOP\\\${APPNAME}.lnk" "\$INSTDIR\\flutter_3d_app.exe"
sectionEnd

section "uninstall"
    delete "\$INSTDIR\\uninstall.exe"
    delete "\$SMPROGRAMS\\\${APPNAME}\\\${APPNAME}.lnk"
    delete "\$DESKTOP\\\${APPNAME}.lnk"
    rmDir "\$SMPROGRAMS\\\${APPNAME}"
    rmDir /r "\$INSTDIR"
sectionEnd
EOF
        
        if command_exists makensis; then
            makensis "$nsis_script"
            mv "${target_dir}/${installer_name}" "${target_dir}/"
            print_status "Created ${installer_name}"
        else
            print_warning "NSIS not found, creating zip instead"
            create_zip "$source_dir" "${installer_name%.exe}.zip" "$target_dir"
        fi
        
        rm -f "$nsis_script"
    else
        print_warning "Source directory ${source_dir} not found, skipping installer creation"
    fi
}

# Function to create Debian package
create_deb_package() {
    local source_dir="$1"
    local package_name="$2"
    local target_dir="$3"
    
    if [ -d "$source_dir" ]; then
        # Create package structure
        local package_dir="${target_dir}/${package_name}_${VERSION}_amd64"
        mkdir -p "${package_dir}/usr/bin"
        mkdir -p "${package_dir}/usr/share/applications"
        mkdir -p "${package_dir}/usr/share/icons/hicolor/256x256/apps"
        mkdir -p "${package_dir}/DEBIAN"
        
        # Copy application files
        cp -r "${source_dir}"/* "${package_dir}/usr/bin/"
        
        # Create desktop file
        cat > "${package_dir}/usr/share/applications/3d-object-viewer.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=3D Object Viewer
Comment=Professional 3D model comparison tool
Exec=/usr/bin/flutter_3d_app
Icon=3d-object-viewer
Terminal=false
Categories=Graphics;3DGraphics;
EOF
        
        # Create control file
        cat > "${package_dir}/DEBIAN/control" << EOF
Package: 3d-object-viewer
Version: ${VERSION}
Section: graphics
Priority: optional
Architecture: amd64
Depends: libgtk-3-0, libglib2.0-0
Maintainer: Flutter 3D App <contact@example.com>
Description: Professional 3D model comparison tool
 3D Object Viewer is a professional-grade application for loading,
 viewing, and comparing 3D objects with advanced Procrustes analysis.
EOF
        
        # Create postinst script
        cat > "${package_dir}/DEBIAN/postinst" << EOF
#!/bin/bash
set -e
update-desktop-database
EOF
        chmod +x "${package_dir}/DEBIAN/postinst"
        
        # Create postrm script
        cat > "${package_dir}/DEBIAN/postrm" << EOF
#!/bin/bash
set -e
update-desktop-database
EOF
        chmod +x "${package_dir}/DEBIAN/postrm"
        
        # Build package
        dpkg-deb --build "${package_dir}" "${target_dir}/${package_name}_${VERSION}_amd64.deb"
        print_status "Created ${package_name}_${VERSION}_amd64.deb"
        
        # Clean up
        rm -rf "$package_dir"
    else
        print_warning "Source directory ${source_dir} not found, skipping DEB package creation"
    fi
}

# Function to create RPM package
create_rpm_package() {
    local source_dir="$1"
    local package_name="$2"
    local target_dir="$3"
    
    if [ -d "$source_dir" ]; then
        # Create RPM spec file
        local spec_file="${target_dir}/3d-object-viewer.spec"
        cat > "$spec_file" << EOF
Name:           3d-object-viewer
Version:        ${VERSION}
Release:        1%{?dist}
Summary:        Professional 3D model comparison tool

License:        MIT
URL:            https://github.com/yourusername/flutter_3d_app
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch
Requires:       gtk3 glib2

%description
3D Object Viewer is a professional-grade application for loading,
viewing, and comparing 3D objects with advanced Procrustes analysis.

%prep
%setup -q

%build
# No build step needed for pre-built binaries

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/share/applications
mkdir -p %{buildroot}/usr/share/icons/hicolor/256x256/apps

cp -r * %{buildroot}/usr/bin/

cat > %{buildroot}/usr/share/applications/3d-object-viewer.desktop << 'DESKTOP_EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=3D Object Viewer
Comment=Professional 3D model comparison tool
Exec=/usr/bin/flutter_3d_app
Icon=3d-object-viewer
Terminal=false
Categories=Graphics;3DGraphics;
DESKTOP_EOF

%files
/usr/bin/*
/usr/share/applications/3d-object-viewer.desktop

%changelog
* $(date '+%a %b %d %Y') Flutter 3D App <contact@example.com> - ${VERSION}-1
- Initial release
EOF
        
        # Create source tarball
        tar -czf "${target_dir}/${package_name}-${VERSION}.tar.gz" -C "$source_dir" .
        
        # Build RPM
        if command_exists rpmbuild; then
            rpmbuild -ba "$spec_file" --define "_topdir ${target_dir}/rpmbuild"
            find "${target_dir}/rpmbuild" -name "*.rpm" -exec cp {} "${target_dir}/" \;
            print_status "Created RPM package"
        else
            print_warning "rpmbuild not found, skipping RPM package creation"
        fi
        
        # Clean up
        rm -f "$spec_file"
        rm -f "${target_dir}/${package_name}-${VERSION}.tar.gz"
        rm -rf "${target_dir}/rpmbuild"
    else
        print_warning "Source directory ${source_dir} not found, skipping RPM package creation"
    fi
}

# Main packaging logic
echo "📦 Creating distribution packages..."

# Web package
echo "🌐 Packaging Web version..."
create_zip "build/web" "3d-object-viewer-web-${VERSION}.zip" "$PACKAGE_DIR"

# Android packages
echo "📱 Packaging Android versions..."
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    cp "build/app/outputs/flutter-apk/app-release.apk" "${PACKAGE_DIR}/3d-object-viewer-android-${VERSION}.apk"
    print_status "Created Android APK"
fi

if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    cp "build/app/outputs/bundle/release/app-release.aab" "${PACKAGE_DIR}/3d-object-viewer-android-${VERSION}.aab"
    print_status "Created Android App Bundle"
fi

# iOS package
echo "🍎 Packaging iOS version..."
if [ -f "build/ios/ipa/flutter_3d_app.ipa" ]; then
    cp "build/ios/ipa/flutter_3d_app.ipa" "${PACKAGE_DIR}/3d-object-viewer-ios-${VERSION}.ipa"
    print_status "Created iOS IPA"
fi

# Windows package
echo "🪟 Packaging Windows version..."
if [ -d "build/windows/x64/runner/Release" ]; then
    create_windows_installer "build/windows/x64/runner/Release" "3d-object-viewer-windows-${VERSION}-setup.exe" "$PACKAGE_DIR"
    create_zip "build/windows/x64/runner/Release" "3d-object-viewer-windows-${VERSION}.zip" "$PACKAGE_DIR"
fi

# macOS package
echo "🍎 Packaging macOS version..."
if [ -d "build/macos/Build/Products/Release/3D Object Viewer.app" ]; then
    create_dmg "build/macos/Build/Products/Release/3D Object Viewer.app" "3d-object-viewer-macos-${VERSION}.dmg" "$PACKAGE_DIR"
    create_zip "build/macos/Build/Products/Release/3D Object Viewer.app" "3d-object-viewer-macos-${VERSION}.zip" "$PACKAGE_DIR"
fi

# Linux packages
echo "🐧 Packaging Linux versions..."
if [ -d "build/linux/x64/release/bundle" ]; then
    # Create AppImage
    create_appimage "build/linux/x64/release/bundle" "3d-object-viewer" "$PACKAGE_DIR"
    
    # Create DEB package
    create_deb_package "build/linux/x64/release/bundle" "3d-object-viewer" "$PACKAGE_DIR"
    
    # Create RPM package
    create_rpm_package "build/linux/x64/release/bundle" "3d-object-viewer" "$PACKAGE_DIR"
    
    # Create generic tar.gz
    create_tar_gz "build/linux/x64/release/bundle" "3d-object-viewer-linux-${VERSION}.tar.gz" "$PACKAGE_DIR"
fi

# Create release notes
echo "📝 Creating release notes..."
cat > "${PACKAGE_DIR}/RELEASE_NOTES.md" << EOF
# 3D Object Viewer v${VERSION} Release Notes

## 🚀 New Features
- Interactive 3D navigation with gesture controls
- Procrustes superimposition analysis
- Advanced similarity metrics and reporting
- Cross-platform support (Web, Desktop, Mobile)
- Tutorial system for new users
- Export results as JSON/CSV

## 📱 Platform Support
- **Web**: Progressive Web App with offline support
- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 12.0+
- **Windows**: Windows 10+
- **macOS**: macOS 10.14+
- **Linux**: Ubuntu 18.04+ (GTK 3.0)

## 🔧 Installation Instructions

### Web
1. Extract the web package
2. Upload contents to your web server
3. Access via web browser

### Android
1. **APK**: Enable "Install from unknown sources" and install
2. **App Bundle**: Upload to Google Play Store

### iOS
1. Install via TestFlight or App Store
2. Requires iOS 12.0 or later

### Windows
1. **Installer**: Run the .exe installer
2. **Portable**: Extract the .zip file and run flutter_3d_app.exe

### macOS
1. **DMG**: Mount and drag to Applications folder
2. **ZIP**: Extract and run the .app bundle

### Linux
1. **AppImage**: Make executable and run
2. **DEB**: Install with \`sudo dpkg -i package.deb\`
3. **RPM**: Install with \`sudo rpm -i package.rpm\`
4. **Tarball**: Extract and run the executable

## 🐛 Bug Fixes
- Fixed 3D rendering issues on some devices
- Improved gesture recognition
- Enhanced error handling
- Better memory management

## 🔒 Security
- Updated dependencies
- Improved file validation
- Enhanced permission handling

## 📊 Performance
- Optimized 3D rendering
- Faster file loading
- Reduced memory usage
- Improved UI responsiveness

## 🆘 Support
- GitHub Issues: https://github.com/yourusername/flutter_3d_app/issues
- Documentation: https://github.com/yourusername/flutter_3d_app/wiki
- Email: contact@example.com

---
Generated on $(date)
EOF

# Create checksums
echo "🔐 Creating checksums..."
cd "$PACKAGE_DIR"
sha256sum * > checksums.txt
cd - >/dev/null
print_status "Created checksums.txt"

# Create package index
echo "📋 Creating package index..."
cat > "${PACKAGE_DIR}/PACKAGES.txt" << EOF
3D Object Viewer v${VERSION} Distribution Packages
==================================================

Generated: $(date)
Version: ${VERSION}
Build: ${BUILD_NUMBER}

Available Packages:
EOF

for file in "${PACKAGE_DIR}"/*; do
    if [ -f "$file" ] && [ "$(basename "$file")" != "PACKAGES.txt" ] && [ "$(basename "$file")" != "checksums.txt" ] && [ "$(basename "$file")" != "RELEASE_NOTES.md" ]; then
        size=$(du -h "$file" | cut -f1)
        echo "- $(basename "$file") (${size})" >> "${PACKAGE_DIR}/PACKAGES.txt"
    fi
done

# Summary
echo ""
echo "=================================================="
echo -e "${GREEN}🎉 Release packaging completed successfully!${NC}"
echo ""
echo "📁 Packages created in: $PACKAGE_DIR"
echo "📊 Total packages: $(ls -1 "$PACKAGE_DIR" | wc -l)"
echo "💾 Total size: $(du -sh "$PACKAGE_DIR" | cut -f1)"
echo ""
echo "📋 Package list:"
ls -la "$PACKAGE_DIR"
echo ""
echo "🔐 Checksums: $PACKAGE_DIR/checksums.txt"
echo "📝 Release notes: $PACKAGE_DIR/RELEASE_NOTES.md"
echo "📋 Package index: $PACKAGE_DIR/PACKAGES.txt"
echo ""
echo -e "${BLUE}🚀 Ready for distribution!${NC}"
