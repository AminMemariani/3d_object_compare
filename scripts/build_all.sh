#!/bin/bash

# 3D Object Viewer - Build Script for All Platforms
# This script builds the Flutter app for all supported platforms

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to build for a specific platform
build_platform() {
    local platform=$1
    local build_dir="build/${platform}"
    
    print_status "Building for $platform..."
    
    case $platform in
        "web")
            if command_exists flutter; then
                flutter build web --release --web-renderer html
                print_success "Web build completed"
            else
                print_error "Flutter not found"
                return 1
            fi
            ;;
        "android")
            if command_exists flutter; then
                flutter build apk --release
                print_success "Android APK build completed"
            else
                print_error "Flutter not found"
                return 1
            fi
            ;;
        "ios")
            if command_exists flutter; then
                flutter build ios --release --no-codesign
                print_success "iOS build completed (no code signing)"
            else
                print_error "Flutter not found"
                return 1
            fi
            ;;
        "windows")
            if command_exists flutter; then
                flutter build windows --release
                print_success "Windows build completed"
            else
                print_error "Flutter not found"
                return 1
            fi
            ;;
        "macos")
            if command_exists flutter; then
                flutter build macos --release
                print_success "macOS build completed"
            else
                print_error "Flutter not found"
                return 1
            fi
            ;;
        "linux")
            if command_exists flutter; then
                flutter build linux --release
                print_success "Linux build completed"
            else
                print_error "Flutter not found"
                return 1
            fi
            ;;
        *)
            print_error "Unknown platform: $platform"
            return 1
            ;;
    esac
}

# Function to clean build directories
clean_builds() {
    print_status "Cleaning previous builds..."
    flutter clean
    rm -rf build/
    print_success "Build directories cleaned"
}

# Function to get dependencies
get_dependencies() {
    print_status "Getting Flutter dependencies..."
    flutter pub get
    print_success "Dependencies retrieved"
}

# Function to run code generation
run_codegen() {
    print_status "Running code generation..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    print_success "Code generation completed"
}

# Function to analyze code
analyze_code() {
    print_status "Analyzing code..."
    flutter analyze
    print_success "Code analysis completed"
}

# Function to run tests
run_tests() {
    print_status "Running tests..."
    flutter test
    print_success "Tests completed"
}

# Main function
main() {
    print_status "Starting 3D Object Viewer build process..."
    
    # Parse command line arguments
    PLATFORMS=()
    CLEAN=false
    SKIP_TESTS=false
    SKIP_ANALYSIS=false
    SKIP_CODEGEN=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --platform)
                PLATFORMS+=("$2")
                shift 2
                ;;
            --clean)
                CLEAN=true
                shift
                ;;
            --skip-tests)
                SKIP_TESTS=true
                shift
                ;;
            --skip-analysis)
                SKIP_ANALYSIS=true
                shift
                ;;
            --skip-codegen)
                SKIP_CODEGEN=true
                shift
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --platform PLATFORM    Build for specific platform (web, android, ios, windows, macos, linux)"
                echo "  --clean                Clean build directories before building"
                echo "  --skip-tests          Skip running tests"
                echo "  --skip-analysis       Skip code analysis"
                echo "  --skip-codegen        Skip code generation"
                echo "  --help                Show this help message"
                echo ""
                echo "Examples:"
                echo "  $0                                    # Build all platforms"
                echo "  $0 --platform web --platform android  # Build specific platforms"
                echo "  $0 --clean                           # Clean and build all platforms"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # If no platforms specified, build all
    if [ ${#PLATFORMS[@]} -eq 0 ]; then
        PLATFORMS=("web" "android" "ios" "windows" "macos" "linux")
    fi
    
    # Check if Flutter is installed
    if ! command_exists flutter; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Clean if requested
    if [ "$CLEAN" = true ]; then
        clean_builds
    fi
    
    # Get dependencies
    get_dependencies
    
    # Run code generation if not skipped
    if [ "$SKIP_CODEGEN" = false ]; then
        run_codegen
    fi
    
    # Run analysis if not skipped
    if [ "$SKIP_ANALYSIS" = false ]; then
        analyze_code
    fi
    
    # Run tests if not skipped
    if [ "$SKIP_TESTS" = false ]; then
        run_tests
    fi
    
    # Build for each platform
    FAILED_PLATFORMS=()
    for platform in "${PLATFORMS[@]}"; do
        if ! build_platform "$platform"; then
            FAILED_PLATFORMS+=("$platform")
        fi
    done
    
    # Report results
    echo ""
    if [ ${#FAILED_PLATFORMS[@]} -eq 0 ]; then
        print_success "All builds completed successfully!"
        print_status "Build artifacts are available in the build/ directory"
    else
        print_error "Build failed for platforms: ${FAILED_PLATFORMS[*]}"
        exit 1
    fi
}

# Run main function with all arguments
main "$@"
