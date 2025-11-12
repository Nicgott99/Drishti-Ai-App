# Changelog

All notable changes to Drishti AI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-13

### 🎉 Initial Release

The first official release of Drishti AI - TB Detection App!

### ✨ Added

#### Core Features
- **Offline TB Detection**: Complete AI-powered analysis without internet connectivity
- **EfficientNetV2 Model**: Deep learning model for accurate TB detection
- **Grad-CAM++ Heatmaps**: Visual explanation of AI predictions highlighting affected lung regions
- **Risk Classification**: Categorizes results as TB Positive, TB Suspected, or Normal/Low Risk
- **Patient Management**: Complete patient registration with history tracking
- **PDF Reports**: Downloadable comprehensive medical reports with embedded heatmaps

#### User Interface
- **Bilingual Support**: English and Bengali (বাংলা) interface
- **Modern Material Design**: Clean, intuitive UI following Material Design 3
- **Dark/Light Theme**: Automatic theme adaptation
- **Responsive Layout**: Optimized for all screen sizes
- **Real-time Progress**: Visual feedback during AI analysis (7 stages)

#### AI Features
- **Gemini AI Assistant**: Integrated AI chatbot for medical queries
- **Context-Aware Responses**: Understands TB-related medical questions
- **Multilingual Chat**: Responds in user's preferred language

#### Technical Features
- **Image Preprocessing**: Optimized pipeline for X-ray analysis
- **Lung Mask Detection**: Anatomical landmark-based lung region identification
- **TB Pattern Detection**: Multi-feature analysis (darkness, texture, edges)
- **Spatial Pooling**: Focus on clustered abnormalities
- **Gaussian Blur**: Smooth medical-grade gradients
- **JET Colormap**: Professional heatmap visualization
- **Memory Optimization**: Efficient handling of large images

### 🔧 Fixed

- **Crash Prevention**: Comprehensive error handling in heatmap generation
- **Memory Management**: Optimized Gaussian kernel size (capped at 61×61)
- **Array Bounds Checking**: Prevented index out of bounds errors
- **Image Deep Copy**: Fixed shallow copy issues in pixel manipulation
- **PDF Generation**: Proper base64 image embedding
- **Randomness Reduction**: Consistent TB detection (±0.05 variation)

### 🛡️ Security

- **Local Storage Only**: All patient data stored on device
- **No Data Upload**: X-rays and personal info never transmitted
- **Secure Preferences**: Encrypted app settings
- **Privacy by Design**: GDPR-compliant data handling

### 📱 Platform Support

- **Android**: ARM64-v8a, ARMv7a, x86_64 architectures
- **Minimum SDK**: Android 7.0 (API 24)
- **Target SDK**: Android 14 (API 34)
- **File Size**: 87.7 MB - 90.8 MB (architecture-specific)

### 📊 Performance

- **Analysis Time**: 30-40 seconds per X-ray
- **Heatmap Generation**: 5-8 seconds
- **PDF Creation**: 1-2 seconds
- **Memory Usage**: < 200 MB during analysis
- **Battery Impact**: Minimal (efficient CPU usage)

### 🌐 Localization

- **English (EN)**: Complete translation
- **Bengali (বাংলা)**: Complete translation
- **Dynamic Switching**: Change language without restart
- **Localized Reports**: PDF reports in selected language

### 📚 Documentation

- **README.md**: Comprehensive project documentation
- **LICENSE**: MIT License
- **CONTRIBUTING.md**: Contribution guidelines
- **Installation Guide**: Step-by-step setup instructions
- **Usage Guide**: Detailed how-to for end users
- **Screenshots**: 9 app screens + 2 report examples

### 🔄 Known Limitations

- **iOS Support**: Not yet available (Android only)
- **Model Updates**: Requires app update for model improvements
- **Offline Only**: No cloud sync or backup
- **Image Format**: Best with PNG/JPEG X-ray images
- **File Size**: Large app size due to embedded AI model

### 🎯 Future Roadmap

See [GitHub Projects](https://github.com/Nicgott99/Drishti-Ai-App/projects) for planned features:

- iOS version
- Additional language support (Hindi, Urdu, etc.)
- Cloud backup option
- Multi-patient comparison
- Export to DICOM format
- Integration with hospital systems
- Offline model updates

---

## Version History

- **1.0.0** (2025-11-13): Initial public release

---

For detailed changes, see [GitHub Releases](https://github.com/Nicgott99/Drishti-Ai-App/releases).
