# Android Storage Fix

## Problem

Android 10+ introduced **Scoped Storage** which restricts apps from writing to shared storage locations like:
- `/storage/emulated/0/DCIM/`
- `/storage/emulated/0/Music/`
- `/storage/emulated/0/Download/`
- Other shared directories

When users tried to select these folders, they got:
```
PathAccessException: Cannot open file, path = '/storage/emulated/0/DCIM/...'
(OS Error: Operation not permitted, errno = 1)
```

## Solution

### 1. Android Uses App-Specific External Storage

**Location**: `/storage/emulated/0/Android/data/com.example.v_shere/files/V-Shere-Received`

**Benefits**:
- ✅ No permissions required
- ✅ User can access via file managers
- ✅ Follows Android best practices
- ✅ No scoped storage restrictions
- ✅ Cleaned up when app uninstalled

### 2. Custom Folder Selection Disabled on Android

On Android, the "Choose Save Folder" button is now disabled because:
- Most user-selected folders require `MANAGE_EXTERNAL_STORAGE` permission
- This permission is restricted and discouraged by Google Play
- App-specific storage is the recommended approach
- It avoids all permission issues

### 3. Custom Folders Work on Windows and iOS

- **Windows**: Full folder picker access, no restrictions
- **iOS**: Files app picker with proper sandboxing

## How to Access Received Files on Android

### Method 1: File Manager Apps

1. Open any file manager (Files by Google, etc.)
2. Navigate to: **Android** → **data** → **com.example.v_shere** → **files** → **V-Shere-Received**
3. Your received files are there

### Method 2: Android Storage Settings

1. Settings → Apps → V-Shere → Storage
2. Tap "Manage storage" or "Clear data"
3. View files location

### Method 3: ADB (for developers)

```bash
adb shell ls /storage/emulated/0/Android/data/com.example.v_shere/files/V-Shere-Received
adb pull /storage/emulated/0/Android/data/com.example.v_shere/files/V-Shere-Received/filename.ext
```

## Code Changes

### transfer_service.dart

```dart
// Changed default location for Android
Future<String> getDefaultSaveDirectory() async {
  if (Platform.isAndroid) {
    // Use app-specific external storage
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      final folder = Directory(
        '${directory.path}${Platform.pathSeparator}V-Shere-Received',
      );
      await folder.create(recursive: true);
      return folder.path;
    }
  }
  
  // Fallback for other platforms
  final directory = await getApplicationDocumentsDirectory();
  // ...
}
```

### receive_screen.dart

```dart
// Disabled folder picker on Android
Future<void> chooseSaveFolder() async {
  if (Platform.isAndroid) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('On Android, files are saved to app storage folder'),
      ),
    );
    return;
  }
  // ... Windows/iOS folder picker
}
```

## Why Not Use Storage Access Framework (SAF)?

We added the `saf` package but chose not to use it because:

1. **Complexity**: SAF requires URI-based file access, more complex than File API
2. **Limitations**: Doesn't work well with HttpServer streaming
3. **User Experience**: Folder picker UX is confusing on Android
4. **Permissions**: Still requires user to grant folder access
5. **App-specific storage is simpler**: No permissions, easy access, standard approach

## Future Enhancements

If users really need custom locations on Android, we could:

1. **Request MANAGE_EXTERNAL_STORAGE** (not recommended by Google)
2. **Use MediaStore API** for specific media types
3. **Add "Move to..." feature** after receiving files
4. **Share functionality** to send files to other apps

## Testing

✅ **Android**: Receives files to app-specific storage without errors
✅ **Windows**: Can choose any folder
✅ **iOS**: Can choose from Files app locations

## Summary

**Android (Fixed)**:
- Default location: App-specific external storage
- Custom folders: Disabled (to avoid permission errors)
- User access: Via file managers

**Windows/iOS (Unchanged)**:
- Default location: App documents
- Custom folders: Fully supported
- User access: Native file explorers

---

**The fix ensures V-Shere works reliably on all platforms without permission errors!** 🎉
