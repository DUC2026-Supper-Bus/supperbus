# V-Shere - Fast Wi-Fi File Sharing

A cross-platform file sharing application built with Flutter. Share files directly between devices on the same local Wi-Fi network without internet connection.

## 🚀 Features

- ✅ **Multiple File Selection**: Select and send multiple files at once
- ✅ **Direct Wi-Fi Transfer**: Transfer files directly over local network
- ✅ **Cross-Platform**: Works on Android, iPhone, and Windows
- ✅ **Automatic Device Discovery**: Find receiving devices on the same local Wi-Fi network
- ✅ **Manual IP Connection**: Connect directly by entering a receiver's IP address
- ✅ **Receiver IP Display**: Shows your device's IP address for easy sharing
- ✅ **Transfer Status**: Real-time transfer progress and status
- ✅ **Custom Save Location**: Choose where received files are saved (Windows/iOS)
- ✅ **Auto-Save**: Received files saved automatically
- ✅ **Modern UI**: Dark-themed Material Design 3 interface

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS (iPhone)
- ✅ Windows
- ⏳ macOS (coming soon)
- ⏳ Linux (coming soon)

## 🔧 How It Works

### Port Configuration

V-Shere uses **separate ports** for different platforms to avoid conflicts:
- **Android receiver**: Port `4040`
- **Windows receiver**: Port `4041`

### Receiving Files

1. **Start Receiver**: Open the app and tap "Receive Files"
2. **Choose Save Folder** (Windows/iOS only): Tap "Choose Save Folder" to select custom location
3. **Get IP & Port**: Your device's local IP and port will be displayed
4. **Share Info**: Give the IP and port to the sending device
5. **Wait for Files**: Files sent to this IP:Port will be automatically saved

### Sending Files

1. **Choose a Receiver**: Select a discovered device, or enter its IP address manually
2. **Select Files**: Tap "Choose Files" to select one or multiple files
3. **Send**: Tap "Send Now" to transfer all files
4. **Monitor Progress**: Watch real-time status updates for each file

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.11.5)
- Dart SDK
- Android SDK / Xcode / Windows SDK (depending on platform)

### Installation

1. **Clone the repository**:
```bash
git clone https://github.com/DUC2026-V-shere/V_SHERE.git
cd V_SHERE
```

2. **Install dependencies**:
```bash
flutter pub get
```

3. **Run the app**:
```bash
flutter run
```

## 📦 Dependencies

```yaml
file_picker: ^11.0.3
path_provider: ^2.1.6
network_info_plus: ^7.0.0
http: ^1.6.0
saf: ^2.1.2
```

## 📖 Documentation

- [DEVICE_DISCOVERY_GUIDE.md](DEVICE_DISCOVERY_GUIDE.md) - Automatic device discovery and troubleshooting
- [CONNECTION_GUIDE.md](CONNECTION_GUIDE.md) - Detailed connection scenarios
- [SAVE_FOLDER_GUIDE.md](SAVE_FOLDER_GUIDE.md) - Custom save location guide
- [ANDROID_STORAGE_FIX.md](ANDROID_STORAGE_FIX.md) - Android storage permissions info
- [IOS_BUILD_GUIDE.md](IOS_BUILD_GUIDE.md) - iOS build instructions
- [GET_IPA.md](GET_IPA.md) - IPA installation methods
- [GET_IPA_CHECKLIST.md](GET_IPA_CHECKLIST.md) - Step-by-step IPA guide

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

**V-Shere v1.0** - Share files. Fast. Private. Direct. ⚡
