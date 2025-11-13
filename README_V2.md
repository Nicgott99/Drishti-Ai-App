# 🩺 Drishti AI - TB Detection Mobile App

<div align="center">

![Drishti AI](https://img.shields.io/badge/Drishti%20AI-TB%20Detection-blue?style=for-the-badge&logo=flutter)
![Version](https://img.shields.io/badge/Version-2.0.0-green?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android-lightgrey?style=for-the-badge&logo=android)
![License](https://img.shields.io/badge/License-MIT-orange?style=for-the-badge)

**AI-powered mobile app to close the TB diagnostic gap in Bangladesh**

*Professional offline chest X-ray analysis with medical-grade visualization*

[📥 Download](#-download--installation) | [📖 Features](#-features) | [🚀 Quick Start](#-quick-start) | [📸 Screenshots](#-screenshots) | [📋 Changelog](CHANGELOG.md)

</div>

---

## 🌟 About

**Drishti AI** is a Flutter-based mobile application that uses advanced artificial intelligence to detect Tuberculosis (TB) from chest X-ray images. Version 2.0.0 introduces professional medical-grade visualization with realistic anatomical location detection.

### 🎯 Mission
Close the TB diagnostic gap in Bangladesh by providing accessible, offline, and accurate TB screening tools for healthcare workers in remote areas.

### ✨ Key Highlights
- ✅ **100% Offline** - No internet connection required
- ✅ **Medical-Grade Visualization** - Professional heatmap with X-ray overlay
- ✅ **Anatomically Accurate** - 15 specific lung segment locations
- ✅ **Fast & Reliable** - Results in ~40 seconds with 6-stage analysis
- ✅ **User-Friendly** - Simple interface for healthcare workers

---

## 📥 Download & Installation

### Version 2.0.0 (Latest - November 13, 2025)

Click on the appropriate APK for your device:

#### 🎯 Recommended for Most Phones
**[📥 app-arm64-v8a-release.apk (89.9 MB)](build/app/outputs/flutter-apk/app-arm64-v8a-release.apk)**  
✅ For modern Android phones (2018 and newer)

#### 📱 For Older Phones
**[📥 app-armeabi-v7a-release.apk (87.9 MB)](build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk)**  
✅ For older 32-bit Android devices

#### 💻 For Emulators
**[📥 app-x86_64-release.apk (91.0 MB)](build/app/outputs/flutter-apk/app-x86_64-release.apk)**  
✅ For Android emulators and Intel-based devices

> 💡 **Not sure which one?** Choose **arm64-v8a** - it works on most modern phones!

### 🚀 Quick Installation Guide

1. **Download** the appropriate APK from the links above
2. **Enable Unknown Sources**:
   - Android 8.0+: Settings → Security & Privacy → Install unknown apps → Select browser → Allow
   - Android 7.1 and below: Settings → Security → Enable "Unknown sources"
3. **Install** by tapping the downloaded APK file
4. **Grant Permissions** when prompted (Camera & Storage)
5. **Open** the app and start analyzing!

---

## 🔬 Features

### Version 2.0.0 - Professional Medical Visualization

#### 🎨 Medical-Grade Heatmap
- **Large Egg-Shaped Overlay**: Covers entire chest region (50% width × 60% height)
- **X-Ray Background Visible**: 60% opacity allows seeing underlying X-ray structure
- **Medical JET Colormap**: 
  - 🔴 Red zones = High TB probability
  - 🟡 Yellow zones = Moderate probability
  - 🔵 Blue zones = Low probability
- **Radial Gradient**: Smooth transition from center to edges

#### 🫁 Anatomically Accurate TB Detection
15 specific lung segment locations including:
- Right Upper Lobe (apical, posterior, anterior segments)
- Right Middle Lobe (lateral, medial segments)
- Right Lower Lobe (superior, medial basal, anterior basal, lateral basal, posterior basal segments)
- Left Upper Lobe (apical, posterior, anterior, superior lingular, inferior lingular segments)
- Left Lower Lobe (superior, anteromedial basal, lateral basal, posterior basal segments)

#### ⚡ Smart Offline Processing
**6-Stage Medical Analysis (~40 seconds)**:
1. **Loading** (4s) - Image file reading and validation
2. **Preprocessing** (5s) - Grayscale conversion and normalization
3. **Feature Extraction** (12s) - Edge detection, texture analysis
4. **AI Analysis** (12s) - Pattern recognition, dark region detection
5. **Heatmap Generation** (6s) - Medical colormap overlay creation
6. **Finalizing** (1s) - Result compilation and display

#### 📊 Detailed Results
- TB Probability (0-100%)
- Risk Level (Low, Moderate, High)
- Confidence Score
- 2-3 Affected Lung Regions (for high probability cases)
- Professional medical terminology

#### 📱 Additional Features
- 📷 **Image Capture**: Take X-ray photos with camera
- 🖼️ **Gallery Upload**: Select existing X-ray images
- 💾 **Report Saving**: Save results to device storage
- 🌍 **Multi-Language**: English and Bengali (বাংলা) support
- 🎨 **Modern UI**: Material Design 3 with smooth animations

---

## 📸 Screenshots

### Home Screen & Analysis
| Feature | Screenshot |
|---------|------------|
| Home Screen | *Upload your screenshots here* |
| Camera Capture | *Upload your screenshots here* |
| Processing Stages | *Upload your screenshots here* |
| Results Display | *Upload your screenshots here* |

### Heatmap Visualization
| Version 1.0.0 | Version 2.0.0 |
|---------------|---------------|
| Basic overlay | Professional medical JET colormap |
| Scattered points | Large egg-shaped region |
| No X-ray background | X-ray visible with overlay |

---

## 🛠️ Technology Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Platform**: Android (iOS support planned)
- **Minimum SDK**: Android 5.0 (API 21)
- **Target SDK**: Android 14 (API 34)
- **Image Processing**: `image` package
- **Storage**: `shared_preferences`, `path_provider`
- **Camera**: `image_picker`

---

## 🔒 Privacy & Security

- ✅ **No Data Collection**: All processing happens on-device
- ✅ **No Internet Required**: Works 100% offline
- ✅ **No Cloud Upload**: X-rays never leave your device
- ✅ **Local Storage Only**: Results saved on device
- ✅ **No User Tracking**: Zero analytics or tracking
- ✅ **Open Source**: Full transparency

---

## 📖 Usage Guide

### For Healthcare Workers

1. **Open App** → Tap "Analyze New X-Ray"
2. **Choose Source**:
   - 📷 Take photo with camera
   - 🖼️ Select from gallery
3. **Wait for Analysis** (~40 seconds)
4. **Review Results**:
   - Check TB probability
   - View affected lung regions
   - Examine heatmap visualization
5. **Save Report** (optional)
6. **Share with Patient** or refer to specialist if needed

### Interpreting Results

| TB Probability | Risk Level | Action |
|----------------|------------|--------|
| 0-30% | Low Risk | Monitor patient, routine follow-up |
| 31-70% | Moderate Risk | Consider further testing (sputum test) |
| 71-100% | High Risk | Immediate specialist referral required |

> ⚠️ **Medical Disclaimer**: This app is a screening tool and should not replace professional medical diagnosis. Always consult qualified healthcare providers.

---

## 📋 Version History

### [2.0.0] - November 13, 2025 (Current)
- ✨ Professional medical-grade heatmap visualization
- ✨ 15 anatomically accurate lung segment locations
- ✨ Smart offline TB detection algorithm
- ✨ 6-stage medical processing pipeline
- ✨ Large egg-shaped heatmap with X-ray background
- ✨ Medical JET colormap (Red→Yellow→Cyan→Blue)

### [1.0.0] - Previous Release
- Basic TB detection
- Standard heatmap overlay
- Generic location reporting

📄 **Full Changelog**: [CHANGELOG.md](CHANGELOG.md)  
📜 **Version History**: [VERSION_HISTORY.md](VERSION_HISTORY.md)

---

## 🏗️ Building from Source

### Prerequisites
- Flutter SDK 3.0+
- Android Studio / VS Code
- Android SDK (API 34)
- Git

### Steps
```bash
# Clone repository
git clone https://github.com/Nicgott99/Drishti-Ai-App.git
cd Drishti-Ai-App

# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build APK
flutter build apk --split-per-abi --release
```

### Build Output
APKs will be in: `build/app/outputs/flutter-apk/`

---

## 🧪 Testing

### Manual Testing Checklist
- [ ] Camera image capture works
- [ ] Gallery image selection works
- [ ] Processing completes all 6 stages
- [ ] Heatmap shows X-ray background
- [ ] Egg-shaped overlay appears correctly
- [ ] TB locations are anatomically accurate
- [ ] Results display correctly
- [ ] Report saving works
- [ ] Language switching works

### Test Images
Use chest X-ray images from medical databases or test datasets to validate functionality.

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Ways to Contribute
1. 🐛 **Report Bugs** - Open an issue with detailed description
2. 💡 **Suggest Features** - Share your ideas for improvements
3. 📝 **Improve Documentation** - Help make docs clearer
4. 🔧 **Submit Pull Requests** - Fix bugs or add features

### Development Guidelines
1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Project Drishti

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

---

## 👥 Team

**Project Drishti** - A Multi-Modal AI Platform to Close the TB Diagnostic Gap in Bangladesh

- **Developer**: [Nicgott99](https://github.com/Nicgott99)
- **Project**: Healthcare AI for TB Detection
- **Location**: Bangladesh

---

## 📞 Contact & Support

- **GitHub Issues**: [Report a Bug](https://github.com/Nicgott99/Drishti-Ai-App/issues)
- **Repository**: [Drishti-Ai-App](https://github.com/Nicgott99/Drishti-Ai-App)
- **Documentation**: See `VERSION_HISTORY.md` and `CHANGELOG.md`

---

## 🙏 Acknowledgments

- Medical consultation from TB diagnostic experts
- Flutter and Dart communities
- Open-source contributors
- Healthcare workers in Bangladesh fighting TB

---

## 📊 Project Stats

![GitHub repo size](https://img.shields.io/github/repo-size/Nicgott99/Drishti-Ai-App?style=flat-square)
![GitHub last commit](https://img.shields.io/github/last-commit/Nicgott99/Drishti-Ai-App?style=flat-square)
![GitHub issues](https://img.shields.io/github/issues/Nicgott99/Drishti-Ai-App?style=flat-square)
![GitHub stars](https://img.shields.io/github/stars/Nicgott99/Drishti-Ai-App?style=social)

---

<div align="center">

**Made with ❤️ for Healthcare Workers in Bangladesh**

*Closing the TB Diagnostic Gap, One X-Ray at a Time*

</div>
