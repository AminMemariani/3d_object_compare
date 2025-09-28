# Subdomain Setup: object-compare.aminmemariani.github.io

This guide explains how to set up your Flutter 3D Object Comparison App on the subdomain `object-compare.aminmemariani.github.io`.

## 🎯 Configuration Summary

Your app is configured to deploy to: **https://object-compare.aminmemariani.github.io**

## 📁 Files Created/Updated

### 1. CNAME File
- **File**: `CNAME`
- **Content**: `object-compare.aminmemariani.github.io`
- **Purpose**: Tells GitHub Pages to serve your app on this subdomain

### 2. GitHub Actions Workflow
- **File**: `.github/workflows/deploy.yml`
- **Updated**: Added `cname: object-compare.aminmemariani.github.io`
- **Purpose**: Automatically deploys to the correct subdomain

### 3. Documentation Updates
- **README.md**: Updated live demo links
- **Scripts**: Updated deployment messages
- **Badges**: Updated GitHub Pages badge URL

## 🚀 Deployment Steps

### 1. Push to GitHub
```bash
git add .
git commit -m "Configure subdomain deployment for object-compare.aminmemariani.github.io"
git push origin main
```

### 2. Enable GitHub Pages
1. Go to your repository: `https://github.com/AminMemariani/3d_object_compare`
2. Click **Settings** tab
3. Scroll to **Pages** section
4. Configure:
   - **Source**: Deploy from a branch
   - **Branch**: `gh-pages`
   - **Folder**: `/ (root)`
5. Click **Save**

### 3. Monitor Deployment
1. Go to **Actions** tab
2. Watch the "Deploy Flutter Web to GitHub Pages" workflow
3. Wait for completion (usually 2-3 minutes)

### 4. Access Your App
Once deployed, your app will be available at:
**https://object-compare.aminmemariani.github.io**

## 🔧 Technical Details

### DNS Configuration
- **Subdomain**: `object-compare`
- **Domain**: `aminmemariani.github.io`
- **Full URL**: `object-compare.aminmemariani.github.io`
- **Protocol**: HTTPS (automatic with GitHub Pages)

### Build Configuration
- **Flutter Version**: 3.32.6
- **Build Command**: `flutter build web --release`
- **Output Directory**: `build/web`
- **Deployment Branch**: `gh-pages`

### Automatic Deployment
- **Trigger**: Push to `main` branch
- **Tests**: All tests must pass before deployment
- **Build**: Optimized release build with tree-shaking
- **Deploy**: Automatic via GitHub Actions

## 🧪 Testing

### Local Testing
```bash
# Build locally
flutter build web --release

# Serve locally
cd build/web
python3 -m http.server 8000

# Visit: http://localhost:8000
```

### Production Testing
1. Push changes to main branch
2. Wait for GitHub Actions to complete
3. Visit: https://object-compare.aminmemariani.github.io
4. Test all functionality

## 📊 Monitoring

### GitHub Actions
- **Location**: Repository → Actions tab
- **Workflow**: "Deploy Flutter Web to GitHub Pages"
- **Status**: Check for green checkmark
- **Logs**: Click on workflow run for detailed logs

### GitHub Pages
- **Location**: Repository → Settings → Pages
- **Status**: Shows deployment status
- **Custom Domain**: Shows `object-compare.aminmemariani.github.io`

## 🚨 Troubleshooting

### Common Issues

1. **404 Error**
   - Check if CNAME file exists
   - Verify GitHub Pages settings
   - Ensure gh-pages branch exists

2. **Build Fails**
   - Check Flutter version compatibility
   - Verify all dependencies
   - Run `flutter doctor`

3. **Tests Fail**
   - Fix failing tests before deployment
   - Check test configuration
   - Ensure all dependencies are correct

4. **Subdomain Not Working**
   - Verify CNAME file content
   - Check GitHub Pages custom domain settings
   - Wait for DNS propagation (up to 24 hours)

### Debug Steps
1. Check GitHub Actions logs
2. Verify CNAME file in repository
3. Test local build
4. Check GitHub Pages settings

## 🎉 Success Indicators

✅ **GitHub Actions**: Green checkmark in Actions tab  
✅ **GitHub Pages**: Shows "Your site is published"  
✅ **Live URL**: https://object-compare.aminmemariani.github.io loads  
✅ **HTTPS**: Site loads with SSL certificate  
✅ **Functionality**: All app features work correctly  

## 📝 Notes

- The subdomain will be available immediately after deployment
- GitHub Pages provides free HTTPS
- The app automatically redeploys on every push to main
- All optimizations are included for web performance
- The deployment includes comprehensive testing

Your Flutter 3D Object Comparison App is now ready for the subdomain! 🚀
