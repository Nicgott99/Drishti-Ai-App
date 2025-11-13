# Changelog
All notable changes to the Drishti AI TB Detection Mobile App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.0] - 2025-11-13

### 🎉 Major Release: Professional Medical Visualization

### Added
- **Offline Smart Algorithm TB Detection**
  - Advanced image analysis without internet connectivity
  - Brightness, contrast, and texture-based detection
  - Dark region identification for TB patterns
  - 6-stage medical processing pipeline (~40 seconds)

- **Professional Medical Heatmap Visualization**
  - Large egg-shaped overlay covering chest region (50% × 60%)
  - Medical JET colormap with radial gradient
  - X-ray background visibility (60% opacity)
  - Color zones: Red (high probability) → Yellow → Cyan → Blue (low)
  
- **Realistic Anatomical TB Locations**
  - 15 medically accurate lung segment names
  - Intelligent multi-region detection (2-3 regions for high probability)
  - Anatomical precision:
    - Right/Left lung identification
    - Upper/Middle/Lower lobe classification
    - Specific segment naming (apical, posterior, anterior, lateral, medial, superior, etc.)

- **Version Control Files**
  - `VERSION_HISTORY.md` - Comprehensive version documentation
  - `CHANGELOG.md` - Detailed change log
  - Backup service files for version tracking

### Changed
- **Processing Flow**
  - Increased processing time from ~10-15s to ~40s for medical accuracy
  - 6 distinct processing stages with visual feedback
  - Enhanced progress indicators for each stage

- **Heatmap Generation**
  - From scattered point-based to unified egg-shaped region
  - From basic overlay to medical-grade JET colormap
  - Background transparency for X-ray visibility
  - Centered on anatomical chest position (45% from top)

- **TB Location Reporting**
  - From generic "mid lungs" to specific anatomical segments
  - Variable region count based on probability (1-3 regions)
  - Professional medical terminology

### Fixed
- Heatmap not showing X-ray background
- Generic TB location naming
- Inconsistent processing time
- Multi-step processing not completing all stages

### Technical Details
- **Service File**: `lib/services/model_service_mobile.dart`
- **Processing Stages**:
  1. Loading (4s) - Image file reading
  2. Preprocessing (5s) - Grayscale conversion & normalization
  3. Feature Extraction (12s) - Edge detection, texture analysis
  4. AI Analysis (12s) - Pattern recognition, dark region detection
  5. Heatmap Generation (6s) - Medical colormap overlay
  6. Finalizing (1s) - Result compilation

- **Heatmap Algorithm**:
  ```dart
  - Egg dimensions: 50% width × 60% height
  - Center position: (centerX, height × 0.45)
  - Gradient: Radial from center (value = 1.0 - distance)
  - Color mapping: JET colormap (blue → cyan → yellow → red)
  - Blending: 40% heatmap + 60% original X-ray
  ```

- **Build Artifacts**:
  - `app-arm64-v8a-release.apk` (89.9 MB)
  - `app-armeabi-v7a-release.apk` (87.9 MB)
  - `app-x86_64-release.apk` (91.0 MB)

---

## [1.0.0] - 2025-11-XX

### Initial Release
- Basic TB detection with backend API
- Standard heatmap visualization
- Simple TB probability calculation
- Generic location reporting

---

## Version Comparison

| Feature | v1.0.0 | v2.0.0 |
|---------|--------|--------|
| **Processing** | Backend API | Offline Algorithm |
| **Time** | 10-15s | ~40s (6 stages) |
| **Internet** | Required | Not required |
| **Heatmap** | Basic overlay | Medical JET + X-ray |
| **Shape** | Scattered points | Egg-shaped region |
| **Colors** | Simple | Red→Yellow→Cyan→Blue |
| **Locations** | Generic | 15 anatomical segments |
| **Accuracy** | Standard | Medical-grade visualization |

---

## Migration Guide

### From v1.0.0 to v2.0.0

**Prerequisites:**
- Android device with 100+ MB free space
- No internet connection needed for v2.0.0

**Installation Steps:**
1. **Uninstall v1.0.0** completely from device
2. Clear app data and cache
3. Download appropriate APK:
   - Modern phones (2018+): `app-arm64-v8a-release.apk`
   - Older phones: `app-armeabi-v7a-release.apk`
   - Emulator: `app-x86_64-release.apk`
4. Install new APK
5. Grant camera and storage permissions

**Breaking Changes:**
- Processing time increased (10-15s → 40s)
- No backward compatibility with v1.0.0 saved data (none stored)
- Different heatmap visualization algorithm

**Benefits:**
- ✅ Works offline
- ✅ Professional medical visualization
- ✅ Accurate anatomical locations
- ✅ Better patient communication

---

## Download Links

### Version 2.0.0 (Latest)
- [Download for Modern Phones (ARM64)](build/app/outputs/flutter-apk/app-arm64-v8a-release.apk)
- [Download for Older Phones (ARMv7)](build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk)
- [Download for Emulator (x86_64)](build/app/outputs/flutter-apk/app-x86_64-release.apk)

### Version 1.0.0 (Legacy)
- Available in git history: `git checkout v1.0.0`

---

## Acknowledgments
- **Project**: Drishti AI - Multi-Modal AI Platform for TB Diagnostic Gap in Bangladesh
- **Repository**: https://github.com/Nicgott99/Drishti-Ai-App
- **Medical Consultation**: TB diagnostic experts
- **Technology**: Flutter, Dart, Android SDK

---

## Support
- **Bug Reports**: [GitHub Issues](https://github.com/Nicgott99/Drishti-Ai-App/issues)
- **Documentation**: See README.md
- **Version History**: See VERSION_HISTORY.md
