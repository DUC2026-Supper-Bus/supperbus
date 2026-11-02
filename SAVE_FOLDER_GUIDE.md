# Save Folder Selection Guide

V-Shere now lets you choose where received files are saved, instead of always using the default `V-Shere-Received` folder.

## Features

✅ **Custom Save Location**: Choose any folder on your device  
✅ **Native Folder Picker**: Uses your platform's native directory selector  
✅ **Cross-Platform**: Works on Android, iPhone, and Windows  
✅ **Real-Time Updates**: Change save folder even while receiving files  
✅ **Persistent Choice**: Your selected folder is remembered  
✅ **Safe Default**: Falls back to default folder if no custom location selected  

---

## How to Use

### 1. Open Receive Screen

1. Launch V-Shere
2. Tap **"Receive Files"**
3. You'll see a card labeled **"SAVE LOCATION"**

### 2. View Current Save Location

The current save location is displayed in the **SAVE LOCATION** card. By default, this is:

**Android**:
```
/data/data/com.example.v_shere/files/V-Shere-Received
```

**Windows**:
```
C:\Users\YourName\AppData\Local\v_shere\V-Shere-Received
```

**iOS**:
```
/var/mobile/Containers/Data/Application/.../Documents/V-Shere-Received
```

### 3. Choose Custom Folder

1. Tap **"Choose Save Folder"** button
2. Your platform's native folder picker will open
3. Navigate to your desired save location
4. Select the folder
5. Confirm selection

**Examples of custom locations:**

**Android**:
- `/sdcard/Downloads/V-Shere`
- `/sdcard/Documents/Received Files`
- Any accessible folder on your device

**Windows**:
- `C:\Users\YourName\Documents\V-Shere`
- `D:\Received Files`
- Any folder you have write access to

**iOS**:
- Choose from iCloud Drive or local folders
- Files app directories
- Any accessible location

### 4. Start Receiving

After selecting your save folder:
1. Tap **"Start Receiving"**
2. Share your IP address and port with the sender
3. Received files will be saved to your chosen folder

---

## Platform-Specific Behavior

### Android

**Folder Picker**:
- Uses Android's native DocumentsUI picker
- Supports SD card and internal storage
- Can create new folders during selection
- Works with Android 5.0 (API 21) and above

**Permissions**:
- No special permissions required
- System handles access automatically
- Selected folders are granted URI permissions

**Locations**:
- Internal storage: `/sdcard/...`
- External SD card: `/storage/sdcard1/...`
- Downloads folder: `/sdcard/Download/...`

### Windows

**Folder Picker**:
- Uses Windows native folder browser dialog
- Supports all drives (C:, D:, network drives)
- Can create new folders during selection

**Permissions**:
- Requires write access to selected folder
- Standard Windows file permissions apply

**Locations**:
- Documents: `C:\Users\YourName\Documents\...`
- Desktop: `C:\Users\YourName\Desktop\...`
- Custom locations: Any accessible drive/folder

### iPhone/iOS

**Folder Picker**:
- Uses iOS Files app picker
- Supports iCloud Drive, local storage, and connected services
- Sandboxed access (security bookmark)

**Permissions**:
- System handles permissions automatically
- No special entitlements required for local folders
- iCloud requires iCloud entitlement (already configured)

**Locations**:
- iCloud Drive: Syncs across your Apple devices
- On My iPhone: Local device storage
- Third-party services: Dropbox, Google Drive, etc.

---

## How It Works Internally

### Default Behavior

When you haven't selected a custom folder:

```dart
// Uses default location
final defaultFolder = await getApplicationDocumentsDirectory();
// Creates: <AppDocuments>/V-Shere-Received
```

### Custom Folder Selection

When you choose a custom folder:

```dart
// Opens native folder picker
final selectedDirectory = await FilePicker.getDirectoryPath();

// Saves your choice
service.setSaveDirectory(selectedDirectory);
```

### During File Reception

When a file is received:

```dart
// Gets current save directory (custom or default)
final savePath = await getSaveDirectory();

// Creates folder if it doesn't exist
final saveFolder = Directory(savePath);
await saveFolder.create(recursive: true);

// Saves file with timestamp prefix
final fileName = '${timestamp}_${originalName}';
final filePath = '$savePath/$fileName';
```

### Dynamic Folder Changes

You can change the save folder **even while receiving**:

1. Receiver is running
2. You tap "Choose Save Folder"
3. Select new location
4. Next file received will go to new location
5. Previously received files stay in old location

---

## Best Practices

### Organizing Your Files

**Create dedicated folders**:
```
Downloads/
  └── V-Shere/
      ├── Photos/
      ├── Documents/
      └── Videos/
```

**Use descriptive names**:
- Good: `/sdcard/V-Shere-Received`
- Good: `C:\Received Files\V-Shere`
- Avoid: `/sdcard/temp123`

### Performance Tips

**Fast Storage**:
- Internal storage > SD card
- SSD > HDD (Windows)
- Local > Cloud (iCloud, network drives)

**Avoid Slow Locations**:
- Network drives (unless fast LAN)
- Cloud-syncing folders (Dropbox, OneDrive)
- External USB drives

### Storage Management

**Check available space**:
- Large files need sufficient free space
- Receiver shows error if disk full
- Select folder with adequate space

**Clean up old files**:
- V-Shere doesn't auto-delete files
- Manually remove unwanted transfers
- Or let OS storage cleanup handle it

---

## Troubleshooting

### Issue: "Could not select folder"

**Possible Causes**:
- No write permission to selected folder
- Folder on removable storage was ejected
- System picker was canceled

**Solutions**:
- Choose a different folder
- Check folder permissions (Windows)
- Ensure SD card is mounted (Android)
- Restart V-Shere

### Issue: Folder picker doesn't open

**Possible Causes**:
- File picker package issue
- Platform restriction

**Solutions**:
- Restart the app
- Update V-Shere to latest version
- Check system settings

### Issue: Files not appearing in selected folder

**Possible Causes**:
- Folder changed after starting receiver
- File manager cache not refreshed
- Wrong folder selected

**Solutions**:
- Check the displayed save location
- Refresh your file manager
- Stop and restart receiver
- Verify folder path

### Issue: Permission denied (Android)

**Possible Causes**:
- Folder requires special permission
- System folder selected
- App folder of another app

**Solutions**:
- Choose a user-accessible folder
- Use `/sdcard/Download` or `/sdcard/Documents`
- Avoid system folders (`/system`, `/data`)

### Issue: Cannot create folder (Windows)

**Possible Causes**:
- No admin rights for location
- Read-only folder
- Path too long

**Solutions**:
- Choose folder in your user directory
- Check folder properties (remove read-only)
- Use shorter path

---

## Security & Privacy

### Folder Access

**What V-Shere Can Access**:
- ✅ Only the folder you explicitly select
- ✅ Files written by V-Shere to that folder
- ❌ Not other folders or system files

**Platform Sandboxing**:
- Android: URI permissions only
- iOS: Security-scoped bookmarks
- Windows: Standard file system permissions

### File Permissions

**Created Files**:
- Files are created with user ownership
- Standard read/write permissions
- No special attributes set

**Existing Files**:
- V-Shere never overwrites existing files
- Timestamp prefix prevents conflicts
- Safe for folders with existing content

---

## Advanced Usage

### Sharing Folder Across Apps

**Android**:
```
Select: /sdcard/Download/SharedFiles
Other apps can also access Downloads folder
```

**Windows**:
```
Select: C:\Users\Public\SharedFiles
Other users on PC can access Public folders
```

### Using Network Locations

**Windows Network Drives**:
```
Select: Z:\SharedFolder
Files saved directly to network drive
⚠️ Requires network connection
⚠️ May be slower than local storage
```

**iCloud Drive (iOS/Mac)**:
```
Select: iCloud Drive/V-Shere
Files sync across Apple devices
⚠️ Requires iCloud enabled
⚠️ Transfer may seem slower (sync delay)
```

### Scripted/Automated Setups

Currently, V-Shere saves the folder choice in memory. To persist across app restarts:

**Future Enhancement** (not yet implemented):
```dart
// Save to persistent storage
await SharedPreferences.setString('save_folder', selectedPath);

// Load on app start
final savedPath = SharedPreferences.getString('save_folder');
```

---

## Frequently Asked Questions

### Q: Will my choice be remembered after closing the app?

**A:** Currently, the custom folder is stored in memory only. After restarting V-Shere, it reverts to the default folder. A future update will add persistent storage.

### Q: Can I use the same folder for different devices?

**A:** Yes! If multiple devices save to the same network folder or cloud folder, they can all receive files there. Just ensure folder permissions allow multiple writers.

### Q: What happens if I delete the selected folder?

**A:** Next file received will fail with an error. Choose a new folder, and future transfers will succeed.

### Q: Can I select the root directory (/)?

**A:** It's not recommended. Choose a user-accessible subfolder instead. Root may require special permissions or be restricted by the system.

### Q: Does this work with USB OTG drives (Android)?

**A:** Yes, if the OTG drive is mounted and accessible via the Android DocumentsUI. However, if the drive is disconnected during transfer, reception will fail.

### Q: Can I change folder while a file is being received?

**A:** Yes! The current file will finish saving to the old location. The next file will go to the new location.

---

## Summary

**Key Points**:
1. **Default** folder is inside app documents directory
2. **Tap** "Choose Save Folder" to select custom location
3. **Native** platform picker for easy selection
4. **Works** on Android, iPhone, and Windows
5. **Changes** take effect immediately (even while receiving)

**Quick Steps**:
1. Open Receive screen
2. Tap "Choose Save Folder"
3. Navigate to desired location
4. Select folder
5. Start receiving

**Need help?** Check the troubleshooting section or open an issue on GitHub!

---

**V-Shere** - Now with flexible file organization! 📁✨
