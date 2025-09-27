@echo off
setlocal enabledelayedexpansion

REM 3D Object Viewer - Release Packaging Script (Windows)
REM This script creates distribution packages for all platforms

echo 🚀 3D Object Viewer Release Packaging
echo ==================================================

REM Configuration
set "BUILD_DIR=.\build\app_releases"
set "PACKAGE_DIR=.\build\packages"

REM Get version from pubspec.yaml
for /f "tokens=2" %%a in ('findstr /r "version:" pubspec.yaml') do set "VERSION=%%a"
for /f "tokens=1 delims=+" %%a in ("%VERSION%") do set "VERSION=%%a"
for /f "tokens=2 delims=+" %%a in ("%VERSION%") do set "BUILD_NUMBER=%%a"

echo Version: %VERSION%+%BUILD_NUMBER%
echo.

REM Create directories
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
if not exist "%PACKAGE_DIR%" mkdir "%PACKAGE_DIR%"

REM Function to create zip archive
:create_zip
set "source_dir=%~1"
set "zip_name=%~2"
set "target_dir=%~3"

if exist "%source_dir%" (
    cd "%source_dir%"
    "C:\Program Files\7-Zip\7z.exe" a -tzip -r -mx=9 "..\..\..\%target_dir%\%zip_name%" .
    cd ..\..\..
    echo ✅ Created %zip_name%
) else (
    echo ⚠️  Source directory %source_dir% not found, skipping %zip_name%
)
goto :eof

REM Function to create Windows installer
:create_windows_installer
set "source_dir=%~1"
set "installer_name=%~2"
set "target_dir=%~3"

if exist "%source_dir%" (
    REM Create NSIS script
    set "nsis_script=%target_dir%\installer.nsi"
    (
        echo !define APPNAME "3D Object Viewer"
        echo !define COMPANYNAME "Flutter 3D App"
        echo !define DESCRIPTION "Professional 3D model comparison tool"
        echo !define VERSIONMAJOR 1
        echo !define VERSIONMINOR 0
        echo !define VERSIONBUILD %BUILD_NUMBER%
        echo !define HELPURL "https://github.com/yourusername/flutter_3d_app"
        echo !define UPDATEURL "https://github.com/yourusername/flutter_3d_app/releases"
        echo !define ABOUTURL "https://github.com/yourusername/flutter_3d_app"
        echo !define INSTALLSIZE 50000
        echo.
        echo RequestExecutionLevel admin
        echo InstallDir "\$PROGRAMFILES\\\${APPNAME}"
        echo Name "\${APPNAME}"
        echo outFile "%installer_name%"
        echo Icon "assets\icons\app_icon.ico"
        echo.
        echo page directory
        echo page instfiles
        echo.
        echo section "install"
        echo     setOutPath \$INSTDIR
        echo     file /r "%source_dir%\*"
        echo     writeUninstaller "\$INSTDIR\\uninstall.exe"
        echo     createDirectory "\$SMPROGRAMS\\\${APPNAME}"
        echo     createShortCut "\$SMPROGRAMS\\\${APPNAME}\\\${APPNAME}.lnk" "\$INSTDIR\\flutter_3d_app.exe"
        echo     createShortCut "\$DESKTOP\\\${APPNAME}.lnk" "\$INSTDIR\\flutter_3d_app.exe"
        echo sectionEnd
        echo.
        echo section "uninstall"
        echo     delete "\$INSTDIR\\uninstall.exe"
        echo     delete "\$SMPROGRAMS\\\${APPNAME}\\\${APPNAME}.lnk"
        echo     delete "\$DESKTOP\\\${APPNAME}.lnk"
        echo     rmDir "\$SMPROGRAMS\\\${APPNAME}"
        echo     rmDir /r "\$INSTDIR"
        echo sectionEnd
    ) > "%nsis_script%"
    
    if exist "C:\Program Files (x86)\NSIS\makensis.exe" (
        "C:\Program Files (x86)\NSIS\makensis.exe" "%nsis_script%"
        move "%target_dir%\%installer_name%" "%target_dir%\"
        echo ✅ Created %installer_name%
    ) else (
        echo ⚠️  NSIS not found, creating zip instead
        call :create_zip "%source_dir%" "%installer_name:.exe=.zip%" "%target_dir%"
    )
    
    del "%nsis_script%"
) else (
    echo ⚠️  Source directory %source_dir% not found, skipping installer creation
)
goto :eof

REM Main packaging logic
echo 📦 Creating distribution packages...

REM Web package
echo 🌐 Packaging Web version...
call :create_zip "build\web" "3d-object-viewer-web-%VERSION%.zip" "%PACKAGE_DIR%"

REM Android packages
echo 📱 Packaging Android versions...
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "%PACKAGE_DIR%\3d-object-viewer-android-%VERSION%.apk"
    echo ✅ Created Android APK
)

if exist "build\app\outputs\bundle\release\app-release.aab" (
    copy "build\app\outputs\bundle\release\app-release.aab" "%PACKAGE_DIR%\3d-object-viewer-android-%VERSION%.aab"
    echo ✅ Created Android App Bundle
)

REM iOS package
echo 🍎 Packaging iOS version...
if exist "build\ios\ipa\flutter_3d_app.ipa" (
    copy "build\ios\ipa\flutter_3d_app.ipa" "%PACKAGE_DIR%\3d-object-viewer-ios-%VERSION%.ipa"
    echo ✅ Created iOS IPA
)

REM Windows package
echo 🪟 Packaging Windows version...
if exist "build\windows\x64\runner\Release" (
    call :create_windows_installer "build\windows\x64\runner\Release" "3d-object-viewer-windows-%VERSION%-setup.exe" "%PACKAGE_DIR%"
    call :create_zip "build\windows\x64\runner\Release" "3d-object-viewer-windows-%VERSION%.zip" "%PACKAGE_DIR%"
)

REM macOS package
echo 🍎 Packaging macOS version...
if exist "build\macos\Build\Products\Release\3D Object Viewer.app" (
    call :create_zip "build\macos\Build\Products\Release\3D Object Viewer.app" "3d-object-viewer-macos-%VERSION%.zip" "%PACKAGE_DIR%"
)

REM Linux package
echo 🐧 Packaging Linux version...
if exist "build\linux\x64\release\bundle" (
    call :create_zip "build\linux\x64\release\bundle" "3d-object-viewer-linux-%VERSION%.zip" "%PACKAGE_DIR%"
)

REM Create release notes
echo 📝 Creating release notes...
(
    echo # 3D Object Viewer v%VERSION% Release Notes
    echo.
    echo ## 🚀 New Features
    echo - Interactive 3D navigation with gesture controls
    echo - Procrustes superimposition analysis
    echo - Advanced similarity metrics and reporting
    echo - Cross-platform support ^(Web, Desktop, Mobile^)
    echo - Tutorial system for new users
    echo - Export results as JSON/CSV
    echo.
    echo ## 📱 Platform Support
    echo - **Web**: Progressive Web App with offline support
    echo - **Android**: API level 21+ ^(Android 5.0+^)
    echo - **iOS**: iOS 12.0+
    echo - **Windows**: Windows 10+
    echo - **macOS**: macOS 10.14+
    echo - **Linux**: Ubuntu 18.04+ ^(GTK 3.0^)
    echo.
    echo ## 🔧 Installation Instructions
    echo.
    echo ### Web
    echo 1. Extract the web package
    echo 2. Upload contents to your web server
    echo 3. Access via web browser
    echo.
    echo ### Android
    echo 1. **APK**: Enable "Install from unknown sources" and install
    echo 2. **App Bundle**: Upload to Google Play Store
    echo.
    echo ### iOS
    echo 1. Install via TestFlight or App Store
    echo 2. Requires iOS 12.0 or later
    echo.
    echo ### Windows
    echo 1. **Installer**: Run the .exe installer
    echo 2. **Portable**: Extract the .zip file and run flutter_3d_app.exe
    echo.
    echo ### macOS
    echo 1. **DMG**: Mount and drag to Applications folder
    echo 2. **ZIP**: Extract and run the .app bundle
    echo.
    echo ### Linux
    echo 1. **AppImage**: Make executable and run
    echo 2. **DEB**: Install with `sudo dpkg -i package.deb`
    echo 3. **RPM**: Install with `sudo rpm -i package.rpm`
    echo 4. **Tarball**: Extract and run the executable
    echo.
    echo ## 🐛 Bug Fixes
    echo - Fixed 3D rendering issues on some devices
    echo - Improved gesture recognition
    echo - Enhanced error handling
    echo - Better memory management
    echo.
    echo ## 🔒 Security
    echo - Updated dependencies
    echo - Improved file validation
    echo - Enhanced permission handling
    echo.
    echo ## 📊 Performance
    echo - Optimized 3D rendering
    echo - Faster file loading
    echo - Reduced memory usage
    echo - Improved UI responsiveness
    echo.
    echo ## 🆘 Support
    echo - GitHub Issues: https://github.com/yourusername/flutter_3d_app/issues
    echo - Documentation: https://github.com/yourusername/flutter_3d_app/wiki
    echo - Email: contact@example.com
    echo.
    echo ---
    echo Generated on %date% %time%
) > "%PACKAGE_DIR%\RELEASE_NOTES.md"

REM Create checksums
echo 🔐 Creating checksums...
cd "%PACKAGE_DIR%"
certutil -hashfile * SHA256 > checksums.txt
cd ..\..
echo ✅ Created checksums.txt

REM Create package index
echo 📋 Creating package index...
(
    echo 3D Object Viewer v%VERSION% Distribution Packages
    echo ==================================================
    echo.
    echo Generated: %date% %time%
    echo Version: %VERSION%
    echo Build: %BUILD_NUMBER%
    echo.
    echo Available Packages:
) > "%PACKAGE_DIR%\PACKAGES.txt"

for %%f in ("%PACKAGE_DIR%\*") do (
    if not "%%~nxf"=="PACKAGES.txt" if not "%%~nxf"=="checksums.txt" if not "%%~nxf"=="RELEASE_NOTES.md" (
        echo - %%~nxf >> "%PACKAGE_DIR%\PACKAGES.txt"
    )
)

REM Summary
echo.
echo ==================================================
echo 🎉 Release packaging completed successfully!
echo.
echo 📁 Packages created in: %PACKAGE_DIR%
echo.
echo 📋 Package list:
dir "%PACKAGE_DIR%"
echo.
echo 🔐 Checksums: %PACKAGE_DIR%\checksums.txt
echo 📝 Release notes: %PACKAGE_DIR%\RELEASE_NOTES.md
echo 📋 Package index: %PACKAGE_DIR%\PACKAGES.txt
echo.
echo 🚀 Ready for distribution!

endlocal
