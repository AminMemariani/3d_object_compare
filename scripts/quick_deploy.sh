#!/bin/bash

# Quick deployment script for GitHub Pages
# This script will build and deploy the app directly to the gh-pages branch

set -e

echo "🚀 Quick deployment to GitHub Pages..."

# Clean and build
echo "🧹 Cleaning and building..."
flutter clean
flutter pub get
flutter build web --release

# Check if build was successful
if [ ! -d "build/web" ]; then
    echo "❌ Error: Build failed. build/web directory not found."
    exit 1
fi

echo "✅ Build completed successfully!"

# Navigate to build directory
cd build/web

# Initialize git if needed
if [ ! -d ".git" ]; then
    echo "📁 Initializing git repository..."
    git init
    git checkout -b gh-pages
fi

# Add all files
echo "📝 Adding files to git..."
git add .

# Commit changes
echo "💾 Committing changes..."
git commit -m "Deploy Flutter web app to GitHub Pages - $(date)"

# Add remote if not exists
if ! git remote get-url origin > /dev/null 2>&1; then
    echo "🔗 Adding remote origin..."
    git remote add origin https://github.com/AminMemariani/3d_object_compare.git
fi

# Push to gh-pages branch
echo "📤 Pushing to gh-pages branch..."
git push origin gh-pages --force

echo "✅ Deployment completed!"
echo "🌐 Your app should be available at: https://aminmemariani.github.io/3d_object_compare/"
echo ""
echo "📋 Next steps:"
echo "1. Go to your repository Settings → Pages"
echo "2. Set Source to 'Deploy from a branch'"
echo "3. Select 'gh-pages' branch and '/ (root)' folder"
echo "4. Click Save"
echo ""
echo "⏱️ It may take a few minutes for the site to be available."
