# Quick Commands for GitHub Actions Testing

## 🚀 Most Common Commands

### 1. Run Tests (Recommended before every push)
```bash
act -j test
```

### 2. Test Web Build (Fastest build to verify)
```bash
act -j build-web
```

### 3. Test Full Deploy Workflow
```bash
act -j build-and-deploy
```

### 4. Dry Run (See what would run)
```bash
act -n
```

## 📋 Platform-Specific Builds

```bash
# Android
act -j build-android

# Linux
act -j build-linux

# Note: iOS, macOS, Windows require their respective runners
# and won't work with Docker on Linux containers
```

## 🔍 Debugging

```bash
# Verbose output
act -j test -v

# Super verbose
act -j test -v -v

# See exact commands
act -j test --dryrun
```

## ⚡ Quick Test Before Push

```bash
# Run this before every push to save GitHub Actions minutes
act -j test && echo "✅ Tests passed! Safe to push."
```

## 🎯 Recommended Workflow

```bash
# 1. Test locally first
act -j test

# 2. If tests pass, push
git push

# 3. GitHub Actions will handle the rest!
```

---

**Note**: All commands automatically use settings from `.actrc` file.

