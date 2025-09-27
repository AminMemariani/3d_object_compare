@echo off
REM 3D Object Viewer - Build Script for All Platforms (Windows)
REM This script builds the Flutter app for all supported platforms

setlocal enabledelayedexpansion

REM Function to print colored output (simplified for Windows)
:print_status
echo [INFO] %~1
goto :eof

:print_success
echo [SUCCESS] %~1
goto :eof

:print_warning
echo [WARNING] %~1
goto :eof

:print_error
echo [ERROR] %~1
goto :eof

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    call :print_error "Flutter is not installed or not in PATH"
    exit /b 1
)

REM Parse command line arguments
set PLATFORMS=
set CLEAN=false
set SKIP_TESTS=false
set SKIP_ANALYSIS=false
set SKIP_CODEGEN=false

:parse_args
if "%~1"=="" goto :end_parse
if "%~1"=="--platform" (
    set PLATFORMS=!PLATFORMS! %~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--clean" (
    set CLEAN=true
    shift
    goto :parse_args
)
if "%~1"=="--skip-tests" (
    set SKIP_TESTS=true
    shift
    goto :parse_args
)
if "%~1"=="--skip-analysis" (
    set SKIP_ANALYSIS=true
    shift
    goto :parse_args
)
if "%~1"=="--skip-codegen" (
    set SKIP_CODEGEN=true
    shift
    goto :parse_args
)
if "%~1"=="--help" (
    echo Usage: %~0 [OPTIONS]
    echo Options:
    echo   --platform PLATFORM    Build for specific platform ^(web, android, ios, windows, macos, linux^)
    echo   --clean                Clean build directories before building
    echo   --skip-tests          Skip running tests
    echo   --skip-analysis       Skip code analysis
    echo   --skip-codegen        Skip code generation
    echo   --help                Show this help message
    echo.
    echo Examples:
    echo   %~0                                    # Build all platforms
    echo   %~0 --platform web --platform android  # Build specific platforms
    echo   %~0 --clean                           # Clean and build all platforms
    exit /b 0
)
call :print_error "Unknown option: %~1"
exit /b 1
:end_parse

REM If no platforms specified, build all
if "%PLATFORMS%"=="" (
    set PLATFORMS=web android ios windows macos linux
)

call :print_status "Starting 3D Object Viewer build process..."

REM Clean if requested
if "%CLEAN%"=="true" (
    call :print_status "Cleaning previous builds..."
    flutter clean
    if exist build rmdir /s /q build
    call :print_success "Build directories cleaned"
)

REM Get dependencies
call :print_status "Getting Flutter dependencies..."
flutter pub get
if errorlevel 1 (
    call :print_error "Failed to get dependencies"
    exit /b 1
)
call :print_success "Dependencies retrieved"

REM Run code generation if not skipped
if "%SKIP_CODEGEN%"=="false" (
    call :print_status "Running code generation..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    if errorlevel 1 (
        call :print_error "Code generation failed"
        exit /b 1
    )
    call :print_success "Code generation completed"
)

REM Run analysis if not skipped
if "%SKIP_ANALYSIS%"=="false" (
    call :print_status "Analyzing code..."
    flutter analyze
    if errorlevel 1 (
        call :print_warning "Code analysis found issues, but continuing..."
    ) else (
        call :print_success "Code analysis completed"
    )
)

REM Run tests if not skipped
if "%SKIP_TESTS%"=="false" (
    call :print_status "Running tests..."
    flutter test
    if errorlevel 1 (
        call :print_warning "Some tests failed, but continuing..."
    ) else (
        call :print_success "Tests completed"
    )
)

REM Build for each platform
set FAILED_PLATFORMS=
for %%p in (%PLATFORMS%) do (
    call :build_platform %%p
    if errorlevel 1 (
        set FAILED_PLATFORMS=!FAILED_PLATFORMS! %%p
    )
)

REM Report results
echo.
if "%FAILED_PLATFORMS%"=="" (
    call :print_success "All builds completed successfully!"
    call :print_status "Build artifacts are available in the build/ directory"
) else (
    call :print_error "Build failed for platforms: %FAILED_PLATFORMS%"
    exit /b 1
)

exit /b 0

REM Function to build for a specific platform
:build_platform
set platform=%~1
call :print_status "Building for %platform%..."

if "%platform%"=="web" (
    flutter build web --release --web-renderer html
    if errorlevel 1 (
        call :print_error "Web build failed"
        exit /b 1
    )
    call :print_success "Web build completed"
    goto :eof
)

if "%platform%"=="android" (
    flutter build apk --release
    if errorlevel 1 (
        call :print_error "Android APK build failed"
        exit /b 1
    )
    call :print_success "Android APK build completed"
    goto :eof
)

if "%platform%"=="ios" (
    flutter build ios --release --no-codesign
    if errorlevel 1 (
        call :print_error "iOS build failed"
        exit /b 1
    )
    call :print_success "iOS build completed (no code signing)"
    goto :eof
)

if "%platform%"=="windows" (
    flutter build windows --release
    if errorlevel 1 (
        call :print_error "Windows build failed"
        exit /b 1
    )
    call :print_success "Windows build completed"
    goto :eof
)

if "%platform%"=="macos" (
    flutter build macos --release
    if errorlevel 1 (
        call :print_error "macOS build failed"
        exit /b 1
    )
    call :print_success "macOS build completed"
    goto :eof
)

if "%platform%"=="linux" (
    flutter build linux --release
    if errorlevel 1 (
        call :print_error "Linux build failed"
        exit /b 1
    )
    call :print_success "Linux build completed"
    goto :eof
)

call :print_error "Unknown platform: %platform%"
exit /b 1
