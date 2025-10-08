# Running GitHub Actions Locally with `act`

This guide shows you how to run your GitHub Actions workflows locally before pushing to GitHub.

---

## 🚀 What is `act`?

`act` runs your GitHub Actions locally using Docker. This lets you:
- ✅ Test workflows before pushing to GitHub
- ✅ Debug CI/CD pipelines faster
- ✅ Save GitHub Actions minutes
- ✅ Work offline

---

## 📦 Installation

### Already Installed! ✅

`act` has been installed via Homebrew:
```bash
brew install act
```

### Verify Installation

```bash
act --version
```

Expected output: `act version 0.2.82` (or similar)

---

## 🐳 Prerequisites

### Docker Required

`act` uses Docker to run actions. Ensure Docker is running:

```bash
# Check if Docker is running
docker ps

# If not installed, install Docker Desktop:
# https://www.docker.com/products/docker-desktop
```

---

## 📋 Available Workflows

Your project has 2 GitHub Actions workflows:

### 1. **deploy.yml** - Deploy Flutter Web to GitHub Pages
```yaml
Triggers:
  - Push to main branch
  - Pull requests to main

Jobs:
  - Install Flutter
  - Run tests
  - Build web app
  - Deploy to GitHub Pages
```

### 2. **build_and_release.yml** - Build and Release All Platforms
```yaml
Triggers:
  - Version tags (v*)
  - Manual workflow dispatch

Jobs:
  - Test
  - Build Web
  - Build Android
  - Build iOS
  - Build Windows
  - Build macOS
  - Build Linux
  - Create Release
```

---

## 🎯 Running Actions Locally

### List Available Workflows

```bash
cd /Users/cyberhonig/FlutterProjects/flutter_3d_compare
act -l
```

This shows all jobs that can be run.

---

### 1. Run Deploy Workflow (Quick Test)

Test the deployment workflow:

```bash
# Run just the build steps (skip actual deployment)
act -j build-and-deploy --container-architecture linux/amd64
```

**What this does:**
- ✅ Installs Flutter
- ✅ Runs `flutter pub get`
- ✅ Runs tests
- ✅ Builds web app
- ❌ Skips GitHub Pages deployment (requires GitHub secrets)

---

### 2. Run Tests Only

Run just the test job from build_and_release.yml:

```bash
act -j test --container-architecture linux/amd64
```

**What this does:**
- ✅ Installs Flutter
- ✅ Runs `flutter pub get`
- ✅ Runs code generation
- ✅ Analyzes code
- ✅ Runs tests
- ✅ Checks formatting

---

### 3. Run Specific Platform Build

Build for a specific platform:

```bash
# Build Android locally
act -j build-android --container-architecture linux/amd64

# Build Web locally
act -j build-web --container-architecture linux/amd64

# Build Linux locally
act -j build-linux --container-architecture linux/amd64
```

---

### 4. Run All Jobs (Full CI/CD)

⚠️ **Warning**: This will take a long time and use significant resources!

```bash
act --container-architecture linux/amd64
```

This runs ALL jobs including iOS, macOS, Windows builds (may fail due to platform requirements).

---

## 🎛️ Useful Options

### Dry Run (See what would run)

```bash
act -n
# or
act --dry-run
```

### Run on Push Event

```bash
act push
```

### Run on Pull Request Event

```bash
act pull_request
```

### Run with Specific Event File

```bash
act -e .github/workflows/deploy.yml
```

### Use Medium-sized Runner

```bash
act -P ubuntu-latest=catthehacker/ubuntu:act-latest
```

### Verbose Output

```bash
act -v
```

### Run with Environment Variables

```bash
act -s FLUTTER_VERSION=3.35.5
```

---

## 🔧 Common Commands for Your Project

### Quick Test Before Push

```bash
# Test that everything compiles and tests pass
act -j test --container-architecture linux/amd64
```

### Test Web Build

```bash
# Test web build (fastest)
act -j build-web --container-architecture linux/amd64
```

### Test Android Build

```bash
# Test Android build
act -j build-android --container-architecture linux/amd64
```

### Test Everything Except macOS/iOS (Linux only)

```bash
# Run test, web, android, linux builds
act -j test -j build-web -j build-android -j build-linux --container-architecture linux/amd64
```

---

## 🛠️ Configuration File

Create `.actrc` in your project root for default settings:

```bash
# .actrc
--container-architecture linux/amd64
-P ubuntu-latest=catthehacker/ubuntu:act-latest
-P macos-latest=-self-hosted
```

Then just run:
```bash
act -j test  # Uses settings from .actrc
```

---

## ⚠️ Limitations

### What Works Locally

✅ **Linux jobs** (test, build-web, build-android, build-linux)  
✅ **Environment setup** (Flutter, dependencies)  
✅ **Code generation** (build_runner)  
✅ **Tests and analysis**  
✅ **Build commands**  

### What Doesn't Work

❌ **macOS/iOS builds** - Requires macOS runner (can't be emulated)  
❌ **Windows builds** - Requires Windows runner (can't be emulated)  
❌ **GitHub secrets** - Not available locally  
❌ **GitHub Pages deployment** - Requires GitHub context  
❌ **Release creation** - Requires GitHub API access  

---

## 📊 Expected Run Times

| Job | Time (Local) | Time (GitHub) |
|-----|--------------|---------------|
| test | ~5-10 min | ~5-7 min |
| build-web | ~8-12 min | ~6-8 min |
| build-android | ~15-20 min | ~10-15 min |
| build-linux | ~15-20 min | ~12-15 min |

*Local times may be slower on first run (downloading Docker images)*

---

## 🐛 Troubleshooting

### Docker Not Running

```bash
Error: Cannot connect to Docker daemon
```

**Solution**: Start Docker Desktop

---

### Out of Disk Space

```bash
Error: No space left on device
```

**Solution**: Clean up Docker
```bash
docker system prune -a
```

---

### Permission Denied

```bash
Error: permission denied while trying to connect to Docker daemon
```

**Solution**: Make sure Docker Desktop is running or add your user to docker group

---

### Platform Mismatch

```bash
Error: exec format error
```

**Solution**: Always use `--container-architecture linux/amd64` flag

---

### Act Hangs or Stalls

```bash
# Cancel with Ctrl+C and try with verbose output
act -j test -v --container-architecture linux/amd64
```

---

## 🎓 Best Practices

### 1. Test Before Push

```bash
# Always run tests locally before pushing
act -j test --container-architecture linux/amd64
```

### 2. Test Web Build (Fastest)

```bash
# Web builds are fastest for quick verification
act -j build-web --container-architecture linux/amd64
```

### 3. Use Dry Run First

```bash
# See what will run without actually running it
act -n
```

### 4. Run Incrementally

Don't run all jobs at once. Test one platform at a time:
```bash
act -j test                    # First
act -j build-web               # Then
act -j build-android           # Finally
```

---

## 📚 Quick Reference

### Essential Commands

```bash
# List all jobs
act -l

# Run tests only
act -j test --container-architecture linux/amd64

# Run web build
act -j build-web --container-architecture linux/amd64

# Dry run (see what would execute)
act -n

# Verbose output
act -v

# Help
act --help
```

---

## 🚀 Recommended Workflow

### Before Every Push:

```bash
# 1. Run tests locally
act -j test --container-architecture linux/amd64

# 2. If tests pass, run web build
act -j build-web --container-architecture linux/amd64

# 3. If everything passes, push to GitHub
git push
```

This saves GitHub Actions minutes and catches issues early!

---

## 📖 Additional Resources

- [act Documentation](https://github.com/nektos/act)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Documentation](https://docs.docker.com/)

---

## ✅ Summary

**Installed**: ✅ `act` version 0.2.82  
**Docker Required**: ✅ Make sure Docker is running  
**Workflows Available**: ✅ 2 workflows (deploy.yml, build_and_release.yml)  
**Recommended**: ✅ Run `act -j test` before every push  

**Ready to test your CI/CD locally!** 🎉

---

## 🎯 Quick Start

```bash
# Navigate to project
cd /Users/cyberhonig/FlutterProjects/flutter_3d_compare

# Make sure Docker is running
docker ps

# Run tests locally
act -j test --container-architecture linux/amd64

# Watch the magic happen! ✨
```

