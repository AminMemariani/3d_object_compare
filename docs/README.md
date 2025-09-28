# GitHub Pages Deployment

This directory contains documentation for deploying the Flutter 3D Object Comparison App to GitHub Pages.

## Automatic Deployment

The app is automatically deployed to GitHub Pages using GitHub Actions when you push to the main branch.

### Workflow Steps:
1. **Checkout**: Gets the latest code
2. **Setup Flutter**: Installs Flutter 3.32.6
3. **Install Dependencies**: Runs `flutter pub get`
4. **Run Tests**: Executes the test suite
5. **Build Web App**: Creates production build with `flutter build web --release`
6. **Deploy**: Publishes to GitHub Pages using `peaceiris/actions-gh-pages`

## Manual Deployment

If you need to deploy manually or test locally:

### Using Scripts:
```bash
# Linux/macOS
./scripts/deploy_web.sh

# Windows
scripts\deploy_web.bat
```

### Manual Commands:
```bash
# Clean and build
flutter clean
flutter pub get
flutter test
flutter build web --release

# Test locally
cd build/web
python3 -m http.server 8000
# Visit http://localhost:8000
```

## Configuration

### GitHub Pages Settings:
1. Go to your repository Settings
2. Navigate to Pages section
3. Source: Deploy from a branch
4. Branch: gh-pages
5. Folder: / (root)

### Custom Domain (Optional):
If you have a custom domain, add it to the workflow file:
```yaml
cname: your-domain.com
```

## Troubleshooting

### Common Issues:
1. **Build Fails**: Check Flutter version compatibility
2. **Tests Fail**: Ensure all tests pass before deployment
3. **404 Errors**: Verify base href configuration
4. **Assets Not Loading**: Check file paths and permissions

### Debug Steps:
1. Check GitHub Actions logs
2. Verify build/web directory contents
3. Test locally before pushing
4. Check GitHub Pages settings

## Performance Optimization

The deployment includes several optimizations:
- HTML renderer for better compatibility
- Release build for optimal performance
- Proper caching headers
- Compressed assets

## Security

- Uses GitHub's built-in security features
- No sensitive data in deployment
- HTTPS enforced by GitHub Pages
- Content Security Policy headers included
