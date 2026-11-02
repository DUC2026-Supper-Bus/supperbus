# V-Shere - Fast Wi-Fi File Sharing

A cross-platform file sharing application built with Flutter. Share files directly between devices on the same local Wi-Fi network without internet connection.

## 🚀 Features

- ✅ **Multiple File Selection**: Select and send multiple files at once
- ✅ **Direct Wi-Fi Transfer**: Transfer files directly over local network
- ✅ **Cross-Platform**: Works on Android, iPhone, and Windows
- ✅ **Manual IP Connection**: Simple IP-based connection (no discovery needed)
- ✅ **Receiver IP Display**: Shows your device's IP address for easy sharing
- ✅ **Transfer Status**: Real-time transfer progress and status
- ✅ **Custom Save Location**: Choose where received files are saved
- ✅ **Auto-Save**: Received files saved in your selected folder
- ✅ **Modern UI**: Dark-themed Material Design 3 interface

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS (iPhone)
- ✅ Windows
- ⏳ macOS (coming soon)
- ⏳ Linux (coming soon)

## 🏗️ Project Structure

```
lib/
├── main.dart                      # App entry point
├── screens/
│   ├── home_screen.dart          # Main dashboard with Send/Receive buttons
│   ├── send_screen.dart          # File selection and sending interface
│   └── receive_screen.dart       # Receiver with IP display
└── services/
    └── transfer_service.dart     # Core file transfer logic (HTTP server)
```

## 🔧 How It Works

### Port Configuration

V-Shere uses **separate ports** for different platforms to avoid conflicts:
- **Android receiver**: Port `4040`
- **Windows receiver**: Port `4041`

### Receiving Files

1. **Start Receiver**: Open the app and tap "Receive Files"
2. **Choose Save Folder** (Optional): Tap "Choose Save Folder" to select custom location, or use default
3. **Get IP & Port**: Your device's local IP and port will be displayed
   - Android: Shows IP with port `4040`
   - Windows: Shows IP with port `4041`
4. **Share Info**: Give the IP and port to the sending device
5. **Wait for Files**: Files sent to this IP:Port will be automatically saved to your chosen folder

### Sending Files

1. **Enter IP & Port**: Enter the receiver's IP address and port number
   - For Android receiver: Use port `4040`
   - For Windows receiver: Use port `4041`
2. **Select Files**: Tap "Choose Files" to select one or multiple files
3. **Send**: Tap "Send Now" to transfer all files
4. **Monitor Progress**: Watch real-time status updates for each file

### Special Cases

**Android Emulator → Windows**:
- Use IP: `10.0.2.2` (special gateway to host machine)
- Use Port: `4041` (Windows receiver port)

**Windows → Android Emulator**:
- Setup ADB forwarding first: `adb forward tcp:4040 tcp:4040`
- Use IP: `127.0.0.1` (localhost via ADB)
- Use Port: `4040` (Android receiver port)

See [CONNECTION_GUIDE.md](CONNECTION_GUIDE.md) for detailed scenarios.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.11.5)
- Dart SDK
- Android SDK / Xcode / Windows SDK (depending on platform)

### Installation

1. **Clone the repository**:
```bash
git clone <repository-url>
cd v_shere
```

2. **Install dependencies**:
```bash
flutter pub get
```

3. **Run the app**:

**For Android**:
```bash
flutter run -d emulator-5554
# or
flutter run -d <your-device-id>
```

**For iOS**:
```bash
flutter run -d iPhone
```

**For Windows**:
```bash
flutter run -d windows
```

## 📦 Dependencies

```yaml
file_picker: ^8.3.7           # File selection
path_provider: ^2.1.6         # File system paths
network_info_plus: ^7.0.0     # Network information
http: ^1.6.0                  # HTTP client
```

## 🔐 Permissions

### Android
The app requires these permissions (already configured in `AndroidManifest.xml`):
- `INTERNET` - Required for network communication
- `ACCESS_NETWORK_STATE` - Required to check Wi-Fi connection

### iOS
Add these to your `Info.plist` (if not already present):
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>V-Shere needs access to your local network to transfer files</string>
```

## 📖 Usage Guide

### Quick Start

1. **On Receiving Device**:
   - Open V-Shere
   - Tap "Receive Files"
   - (Optional) Tap "Choose Save Folder" to select where files will be saved
   - Tap "Start Receiving"
   - Note your IP address (e.g., `192.168.1.100`)

2. **On Sending Device**:
   - Open V-Shere
   - Tap "Send Files"
   - Enter receiver's IP address
   - Tap "Choose Files" and select files
   - Tap "Send Now"

3. **Monitor Transfer**:
   - Sender sees progress for each file
   - Receiver sees files appear in the received list
   - All files saved automatically to chosen location

### Choosing Save Location

**Default Location**:
- Android: `/data/.../V-Shere-Received`
- Windows: `C:\Users\...\V-Shere-Received`
- iOS: App sandbox documents folder

**Custom Location**:
1. Tap "Choose Save Folder" on Receive screen
2. Navigate to desired location using native picker
3. Select folder
4. All future files will be saved there

See [SAVE_FOLDER_GUIDE.md](SAVE_FOLDER_GUIDE.md) for detailed instructions.

### Finding Received Files

**Default Location**:
Files are saved in the app's documents directory with a timestamp prefix:

- **Android**: `/data/data/com.example.v_shere/files/V-Shere-Received/`
- **iOS**: App sandbox documents folder
- **Windows**: `%LOCALAPPDATA%\v_shere\V-Shere-Received\`

**Custom Location**:
If you selected a custom save folder, files will be there instead.

**Accessing Files**:
- File manager apps
- Native file explorer
- Share functionality from other apps
- The folder path is displayed on the Receive screen

See [SAVE_FOLDER_GUIDE.md](SAVE_FOLDER_GUIDE.md) for more details on managing save locations.

## 🐛 Troubleshooting

### Connection Issues

**Cannot connect between devices?**
- Ensure both devices are on the **same Wi-Fi network**
- Check if firewall is blocking port 4040
- Verify the IP address is correct
- Try pinging the receiver from sender

**File transfer fails?**
- Check available storage space
- Ensure receiver is still running
- Try smaller files first
- Check for timeout issues (connection may be slow)

### Platform-Specific Issues

**Android**:
- Grant storage permissions in system settings
- Disable battery optimization for V-Shere
- Check if network permissions are granted

**iOS**:
- Grant local network permission when prompted
- Check Wi-Fi connection (not cellular)

**Windows**:
- Allow app through Windows Firewall
- Check Windows Defender settings

## 🔜 Upcoming Features (v2.0)

- 🔍 **Automatic Device Discovery**: No manual IP entry needed
- 📊 **Transfer History**: View all past transfers
- 🔒 **Encryption**: End-to-end encrypted transfers
- ⏸️ **Pause/Resume**: Pause and resume large transfers
- 📁 **Folder Transfer**: Send entire folders
- 🎯 **QR Code Pairing**: Scan QR to connect
- 🌐 **Cross-Network**: Transfer across different networks (with relay)
- 📝 **Transfer Notes**: Add messages to transfers
- 🎨 **Light Theme**: Alternative light color scheme

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

Run specific tests:
```bash
flutter test test/widget_test.dart
```

## 🔨 Building for Release

**Android APK**:
```bash
flutter build apk --release
```

**iOS IPA**:
```bash
flutter build ios --release
```

**Windows EXE**:
```bash
flutter build windows --release
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Contact: [your-email@example.com]

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Community packages used in this project
- All contributors and testers

---

**V-Shere v1.0** - Share files. Fast. Private. Direct. ⚡
