# V-Shere Setup Guide

## Quick Setup

### 1. Install Android SDK Platform 34

The app requires Android SDK Platform 34. Install it using one of these methods:

**Method A: Android Studio**
1. Open Android Studio
2. Go to `Tools` → `SDK Manager`
3. Under `SDK Platforms` tab, check `Android 14.0 (API 34)`
4. Click `Apply` and wait for installation
5. Return to V-Shere and run again

**Method B: Command Line (sdkmanager)**
```bash
sdkmanager "platforms;android-34"
```

**Method C: Flutter Doctor**
```bash
flutter doctor --android-licenses
```

### 2. Run the App

After installing Android SDK 34:

```bash
flutter clean
flutter pub get
flutter run -d emulator-5554
```

Or for a physical device:
```bash
flutter run
```

## Complete Setup from Scratch

### Step 1: Install Flutter

Download and install Flutter SDK from [flutter.dev](https://flutter.dev)

### Step 2: Verify Installation

```bash
flutter doctor
```

Fix any issues reported by flutter doctor.

### Step 3: Setup Android

1. Install Android Studio
2. Install Android SDK Platform 34 (see above)
3. Accept Android licenses:
```bash
flutter doctor --android-licenses
```

### Step 4: Setup V-Shere

1. Clone or download this project
2. Navigate to project directory:
```bash
cd v_shere
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run on emulator or device:
```bash
flutter run
```

## Platform-Specific Setup

### Android

**Requirements**:
- Android SDK Platform 34
- Minimum Android version: 5.0 (API 21)
- Target Android version: 14 (API 34)

**Permissions** (auto-configured):
- INTERNET
- ACCESS_NETWORK_STATE

### iOS

**Requirements**:
- Xcode 14.0 or later
- CocoaPods
- iOS 12.0 or later

**Setup**:
```bash
cd ios
pod install
cd ..
flutter run -d iPhone
```

**Permissions**: Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>V-Shere needs access to your local network to transfer files</string>
```

### Windows

**Requirements**:
- Windows 10 or later
- Visual Studio 2019/2022 with C++ desktop development

**Build**:
```bash
flutter config --enable-windows-desktop
flutter run -d windows
```

## Testing the Transfer

### Setup Two Devices

**Option 1: Emulator + Physical Device**
1. Start Android emulator
2. Connect physical device via USB
3. Run on emulator: `flutter run -d emulator-5554`
4. Run on device: `flutter run -d <device-id>`

**Option 2: Two Physical Devices**
1. Connect both to same Wi-Fi
2. Install APK on both devices
3. Test file transfer

### Test Transfer Flow

1. **Device A** (Receiver):
   - Open V-Shere
   - Tap "Receive Files"
   - Tap "Start Receiving"
   - Note IP address (e.g., `192.168.1.100`)

2. **Device B** (Sender):
   - Open V-Shere
   - Tap "Send Files"
   - Enter Device A's IP address
   - Tap "Choose Files"
   - Select test files
   - Tap "Send Now"

3. **Verify**:
   - Check sender shows "All files sent successfully!"
   - Check receiver shows received files list
   - Find files in device's V-Shere-Received folder

## Common Issues & Solutions

### Issue: "Failed to install Android SDK Platform 34"

**Solution**: Install manually via Android Studio SDK Manager

### Issue: "Could not find WiFi IP"

**Solution**: 
- Ensure device is connected to Wi-Fi (not cellular)
- Check app has network permissions
- Restart app

### Issue: "Connection refused" when sending

**Solution**:
- Ensure receiver is running ("Start Receiving" tapped)
- Both devices on same Wi-Fi network
- IP address entered correctly
- Firewall not blocking port 4040

### Issue: "File transfer hangs"

**Solution**:
- Check network connection strength
- Try smaller files first
- Restart both apps
- Check available storage on receiver

### Issue: Build fails with "Gradle task failed"

**Solution**:
```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

## Building Release APK

```bash
# Build APK
flutter build apk --release

# Output location:
# build/app/outputs/flutter-apk/app-release.apk

# Install on device:
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Building App Bundle (for Play Store)

```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

## Development Tips

### Hot Reload
While app is running, save changes and press:
- `r` in terminal for hot reload
- `R` for hot restart
- `q` to quit

### Debugging

**Enable debug logging**:
```dart
// In transfer_service.dart, add print statements
print('Received file: $fileName');
print('Server started on: $ipAddress:$port');
```

**View logs**:
```bash
flutter logs
```

**Android logs**:
```bash
adb logcat
```

### Performance Testing

Test with various file sizes:
- Small: < 1 MB
- Medium: 10-50 MB
- Large: 100+ MB
- Very large: 1+ GB

## Network Configuration

### Default Settings
- **Port**: 4040
- **Protocol**: HTTP over TCP
- **Timeout**: 15 seconds

### Custom Port

Edit `lib/services/transfer_service.dart`:
```dart
static const int port = 4040; // Change this
```

### Firewall Rules

**Windows**: Allow port 4040 through Windows Firewall
**Android**: No firewall configuration needed
**iOS**: No firewall configuration needed

## Production Checklist

Before releasing:
- [ ] Test on multiple devices
- [ ] Test with large files (>100MB)
- [ ] Test on different Wi-Fi networks
- [ ] Update version in pubspec.yaml
- [ ] Build release APK/IPA
- [ ] Test release build
- [ ] Update README with version
- [ ] Create release notes

## Support

For additional help:
- Check GitHub Issues
- Read Flutter documentation
- Review code comments
- Contact maintainers

---

**Ready to share files!** 🚀
