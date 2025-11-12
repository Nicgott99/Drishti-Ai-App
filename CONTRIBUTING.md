# Contributing to Drishti AI

First off, thank you for considering contributing to Drishti AI! It's people like you that make Drishti AI such a great tool for addressing the TB diagnostic gap.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Pull Requests](#pull-requests)
- [Development Setup](#development-setup)
- [Style Guidelines](#style-guidelines)
- [Community](#community)

## Code of Conduct

This project and everyone participating in it is governed by respect, professionalism, and inclusivity. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples**
- **Describe the behavior you observed and what you expected**
- **Include screenshots if applicable**
- **Include device information** (Android version, device model, app version)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide a detailed description of the suggested enhancement**
- **Explain why this enhancement would be useful**
- **List any alternatives you've considered**

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Follow the coding style** used throughout the project
3. **Test your changes** thoroughly on multiple devices if possible
4. **Update documentation** if you're adding new features
5. **Write clear commit messages**
6. **Submit your pull request**

## Development Setup

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (included with Flutter)
- Android Studio or VS Code
- Android SDK for Android development
- Xcode for iOS development (macOS only)

### Setup Steps

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/Drishti-Ai-App.git
cd Drishti-Ai-App

# Install dependencies
flutter pub get

# Run the app
flutter run

# Build APK
flutter build apk --release --split-per-abi
```

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── providers/                # State management
├── screens/                  # UI screens
├── services/                 # Business logic & API calls
├── widgets/                  # Reusable UI components
└── l10n/                     # Localization files
```

## Style Guidelines

### Dart Code Style

- Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` before committing
- Maximum line length: 120 characters
- Use meaningful variable and function names
- Add comments for complex logic
- Use const constructors where possible

### Commit Messages

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and pull requests after the first line

Example:
```
Add Grad-CAM heatmap generation

- Implement Grad-CAM++ algorithm for TB detection visualization
- Add JET colormap for better visibility
- Optimize for mobile performance

Closes #123
```

### File Naming

- Use lowercase with underscores for file names: `patient_info.dart`
- Widget files should match the widget name: `results_screen.dart` contains `ResultsScreen`
- Service files end with `_service.dart`: `model_service.dart`

## Areas for Contribution

### Priority Areas

1. **Bug Fixes** 🐛
   - App crashes or freezes
   - Incorrect results
   - UI/UX issues

2. **Feature Enhancements** ✨
   - Improved heatmap visualization
   - Better patient data management
   - Additional language support
   - Performance optimizations

3. **Testing** 🧪
   - Unit tests
   - Widget tests
   - Integration tests
   - Testing on various devices

4. **Documentation** 📚
   - Code documentation
   - User guides
   - API documentation
   - Translation improvements

5. **Accessibility** ♿
   - Screen reader support
   - High contrast mode
   - Font size adjustments
   - Voice commands

### Language Translations

We welcome translations to additional languages! Currently supported:
- English
- Bengali (বাংলা)

To add a new language:
1. Create new ARB file in `lib/l10n/`
2. Translate all strings
3. Update `l10n.yaml`
4. Test thoroughly
5. Submit PR

## Testing Your Changes

### Before Submitting

- [ ] Code compiles without errors
- [ ] All existing tests pass
- [ ] New tests added for new features
- [ ] Tested on at least one Android device/emulator
- [ ] No console warnings or errors
- [ ] UI looks good on different screen sizes
- [ ] Both English and Bengali languages work
- [ ] PDF generation works correctly
- [ ] Heatmap displays properly for TB cases

### Testing Checklist

1. **Patient Registration**: Can register new patients
2. **Image Upload**: Camera and gallery selection work
3. **TB Detection**: Correct classification (TB/Normal)
4. **Heatmap**: Displays only for TB cases, shows in lung area
5. **PDF Download**: Includes all information and heatmap
6. **History**: Past scans displayed correctly
7. **AI Assistant**: Responds to queries
8. **Language Switch**: Seamless switching between EN/BN

## Community

### Getting Help

- 📧 Email: support@drishti-ai.org
- 💬 GitHub Discussions: [Drishti-Ai-App Discussions](https://github.com/Nicgott99/Drishti-Ai-App/discussions)
- 🐛 Issues: [GitHub Issues](https://github.com/Nicgott99/Drishti-Ai-App/issues)

### Recognition

Contributors will be acknowledged in:
- README.md Contributors section
- Release notes
- Project documentation

## License

By contributing to Drishti AI, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Drishti AI! Together, we're closing the TB diagnostic gap. 🩺❤️
