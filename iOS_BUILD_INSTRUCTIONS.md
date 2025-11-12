# iOS Build Instructions

## Requirements

Building iOS apps requires:
- **MacOS** computer (Mac mini, MacBook, iMac)
- **Xcode** 14.0 or higher (free from App Store)
- **Apple Developer Account** ($99/year for distribution)

## Build Steps

### 1. Setup
```bash
# Install CocoaPods
sudo gem install cocoapods

# Navigate to project
cd "Drishti-AI-mobile_app"

# Get dependencies
flutter pub get

# Setup iOS
cd ios
pod install
cd ..
```

### 2. Configure Signing
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Runner" project
3. Go to "Signing & Capabilities"
4. Select your Team (Apple Developer Account)
5. Change Bundle Identifier to unique ID (e.g., `com.yourname.drishti`)

### 3. Build IPA
```bash
# Build for release
flutter build ios --release

# Or build and create IPA
flutter build ipa --release
```

### 4. Distribute

**Option A: TestFlight** (Recommended for testing)
1. Open Xcode
2. Archive: Product → Archive
3. Upload to App Store Connect
4. TestFlight automatically distributes to testers

**Option B: Ad-Hoc Distribution**
1. Archive in Xcode
2. Export IPA with "Ad Hoc" provisioning
3. Install via Apple Configurator or Xcode

**Option C: Enterprise** (requires $299/year Enterprise account)
1. Create Enterprise provisioning profile
2. Build with enterprise certificate
3. Distribute IPA directly via web link

## Alternative: Use Windows/Linux

If you don't have Mac, use **CI/CD services**:

### GitHub Actions (Free)
1. Push code to GitHub
2. Create `.github/workflows/ios.yml`:
```yaml
name: iOS Build
on: push
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build ios --release --no-codesign
```

### Codemagic (Free tier available)
1. Sign up at codemagic.io
2. Connect GitHub repository
3. Select iOS build configuration
4. Automatic builds on push

## System Requirements

- **iOS**: 12.0 or higher
- **Storage**: 150 MB
- **RAM**: 2 GB minimum

## Testing Without Developer Account

You can test on physical device WITHOUT $99 account:
1. Connect iPhone to Mac
2. Open Xcode
3. Select "Personal Team" (free)
4. Run: `flutter run --release`
5. **Limitation**: App expires after 7 days, must rebuild

## Notes

- iOS build requires Mac hardware or cloud Mac service
- Cannot build iOS apps on Windows/Linux directly
- If competition judges need iOS version, request Mac access or use GitHub Actions
- TestFlight is the standard way to distribute test apps

---

**For Competition**: Focus on Android APK. Most users in Bangladesh use Android (90%+ market share).
