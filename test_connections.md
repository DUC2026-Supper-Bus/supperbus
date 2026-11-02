# V-Shere Connection Testing

## Test Scenarios

### Test 1: Android Emulator → Windows

**Setup:**
1. Start Android emulator:
```bash
flutter emulators --launch <emulator-name>
# or use Android Studio AVD Manager
```

2. Start V-Shere on Windows:
```bash
# In a separate terminal/window
flutter run -d windows
```

3. Start V-Shere on Android emulator:
```bash
# In another terminal
flutter run -d emulator-5554
```

**Testing:**

**On Windows app:**
1. Click "Receive Files"
2. Click "Start Receiving"
3. Note: Port should show `4041`

**On Android emulator app:**
1. Click "Send Files"
2. Enter IP: `10.0.2.2`
3. Enter Port: `4041`
4. Click "Choose Files"
5. Select test file(s)
6. Click "Send Now"

**Expected Result:**
- ✅ Status shows "Sending 1/X: filename.ext"
- ✅ Windows shows "Received: filename.ext"
- ✅ File appears in received files list
- ✅ Final status: "All files sent successfully!"

---

### Test 2: Windows → Android Emulator (requires ADB)

**Setup ADB Forwarding:**
```bash
adb forward tcp:4040 tcp:4040
```

Verify:
```bash
adb forward --list
# Should show: 127.0.0.1:4040 tcp:4040
```

**Testing:**

**On Android emulator app:**
1. Click "Receive Files"
2. Click "Start Receiving"
3. Note: Port should show `4040`

**On Windows app:**
1. Click "Send Files"
2. Enter IP: `127.0.0.1`
3. Enter Port: `4040`
4. Click "Choose Files"
5. Select test file(s)
6. Click "Send Now"

**Expected Result:**
- ✅ Status shows "Sending 1/X: filename.ext"
- ✅ Android shows "Received: filename.ext"
- ✅ File appears in received files list
- ✅ Final status: "All files sent successfully!"

---

### Test 3: Android → Windows (Same Wi-Fi)

**Prerequisites:**
- Physical Android device
- Connected to same Wi-Fi as Windows PC

**Testing:**

**On Windows app:**
1. Click "Receive Files"
2. Click "Start Receiving"
3. Note your IP address (e.g., `192.168.1.100`)
4. Note port: `4041`

**On Android device app:**
1. Click "Send Files"
2. Enter Windows IP (e.g., `192.168.1.100`)
3. Enter Port: `4041`
4. Click "Choose Files"
5. Select test file(s)
6. Click "Send Now"

**Expected Result:**
- ✅ Transfer completes successfully
- ✅ File received on Windows

---

### Test 4: Windows → Android (Same Wi-Fi)

**Prerequisites:**
- Physical Android device
- Connected to same Wi-Fi as Windows PC

**Find Android IP:**
- Settings → Wi-Fi → Tap connected network
- Or use V-Shere: "Receive Files" → "Start Receiving"

**Testing:**

**On Android device app:**
1. Click "Receive Files"
2. Click "Start Receiving"
3. Note your IP address (e.g., `192.168.1.150`)
4. Note port: `4040`

**On Windows app:**
1. Click "Send Files"
2. Enter Android IP (e.g., `192.168.1.150`)
3. Enter Port: `4040`
4. Click "Choose Files"
5. Select test file(s)
6. Click "Send Now"

**Expected Result:**
- ✅ Transfer completes successfully
- ✅ File received on Android

---

## Quick Test Files

Create these test files for comprehensive testing:

**Small file (< 1 MB):**
```bash
# Windows PowerShell
"This is a test file for V-Shere" | Out-File -FilePath test_small.txt
```

**Medium file (~10 MB):**
```bash
# Windows PowerShell
fsutil file createnew test_medium.bin 10485760
```

**Large file (~100 MB):**
```bash
# Windows PowerShell
fsutil file createnew test_large.bin 104857600
```

**Test with actual files:**
- Image: .jpg, .png
- Video: .mp4
- Document: .pdf, .docx
- Archive: .zip

---

## Automated Test Script (PowerShell)

Save as `test_v_shere.ps1`:

```powershell
# V-Shere Connection Test Script

Write-Host "=== V-Shere Connection Test ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Check if Android SDK is available
Write-Host "1. Checking ADB..." -ForegroundColor Yellow
$adb = Get-Command adb -ErrorAction SilentlyContinue
if ($adb) {
    Write-Host "   ✓ ADB found" -ForegroundColor Green
    
    # List connected devices
    Write-Host "   Connected devices:" -ForegroundColor Gray
    adb devices
} else {
    Write-Host "   ✗ ADB not found. Install Android SDK." -ForegroundColor Red
}

Write-Host ""

# Test 2: Check Flutter installation
Write-Host "2. Checking Flutter..." -ForegroundColor Yellow
$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if ($flutter) {
    Write-Host "   ✓ Flutter found" -ForegroundColor Green
    flutter --version | Select-String "Flutter"
} else {
    Write-Host "   ✗ Flutter not found." -ForegroundColor Red
}

Write-Host ""

# Test 3: Setup ADB forwarding for emulator
Write-Host "3. Setting up ADB port forwarding..." -ForegroundColor Yellow
try {
    adb forward tcp:4040 tcp:4040
    Write-Host "   ✓ Port forwarding configured: 4040 → 4040" -ForegroundColor Green
    
    # Verify
    $forwards = adb forward --list
    if ($forwards -match "4040") {
        Write-Host "   ✓ Verified: $forwards" -ForegroundColor Green
    }
} catch {
    Write-Host "   ✗ Failed to setup forwarding" -ForegroundColor Red
}

Write-Host ""

# Test 4: Check network connectivity
Write-Host "4. Checking network..." -ForegroundColor Yellow
$ip = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"} | Select-Object -First 1
if ($ip) {
    Write-Host "   ✓ Your Windows IP: $($ip.IPAddress)" -ForegroundColor Green
    Write-Host "   Use this IP when sending FROM Android" -ForegroundColor Gray
} else {
    Write-Host "   ✗ No network connection found" -ForegroundColor Red
}

Write-Host ""

# Test 5: Create test files
Write-Host "5. Creating test files..." -ForegroundColor Yellow
$testDir = "test_files"
if (!(Test-Path $testDir)) {
    New-Item -ItemType Directory -Path $testDir | Out-Null
}

# Small text file
"V-Shere Test File - Small" | Out-File -FilePath "$testDir\test_small.txt"
Write-Host "   ✓ Created: test_small.txt" -ForegroundColor Green

# Medium binary file (1 MB)
if (!(Test-Path "$testDir\test_medium.bin")) {
    fsutil file createnew "$testDir\test_medium.bin" 1048576 | Out-Null
    Write-Host "   ✓ Created: test_medium.bin (1 MB)" -ForegroundColor Green
}

# Large binary file (10 MB)
if (!(Test-Path "$testDir\test_large.bin")) {
    fsutil file createnew "$testDir\test_large.bin" 10485760 | Out-Null
    Write-Host "   ✓ Created: test_large.bin (10 MB)" -ForegroundColor Green
}

Write-Host ""

# Summary
Write-Host "=== Test Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Run: flutter run -d windows" -ForegroundColor White
Write-Host "2. In another terminal: flutter run -d emulator-5554" -ForegroundColor White
Write-Host "3. Test transfers using the connection guide" -ForegroundColor White
Write-Host ""
Write-Host "Connection Info:" -ForegroundColor Yellow
Write-Host "- Windows receiver port: 4041" -ForegroundColor White
Write-Host "- Android receiver port: 4040" -ForegroundColor White
Write-Host "- Emulator → Windows: Use IP 10.0.2.2:4041" -ForegroundColor White
Write-Host "- Windows → Emulator: Use IP 127.0.0.1:4040" -ForegroundColor White
Write-Host ""
```

Run the script:
```bash
powershell -ExecutionPolicy Bypass -File test_v_shere.ps1
```

---

## Manual Testing Checklist

Use this checklist to verify all functionality:

### Basic Functionality
- [ ] App launches without errors (Windows)
- [ ] App launches without errors (Android/Emulator)
- [ ] Home screen displays correctly
- [ ] Navigation to Send screen works
- [ ] Navigation to Receive screen works

### Receive Mode
- [ ] Can start receiver
- [ ] IP address displays correctly
- [ ] Correct port shows (4040 for Android, 4041 for Windows)
- [ ] Can copy IP address
- [ ] Can stop receiver
- [ ] Received files list updates in real-time

### Send Mode
- [ ] Can enter IP address
- [ ] Can enter port number
- [ ] Can select single file
- [ ] Can select multiple files
- [ ] File list displays correctly with sizes
- [ ] Send button disabled when no files selected
- [ ] Status updates during transfer
- [ ] Success message appears after transfer

### File Transfers
- [ ] Small file (<1 MB) transfers successfully
- [ ] Medium file (10 MB) transfers successfully
- [ ] Large file (100+ MB) transfers successfully
- [ ] Multiple files transfer in sequence
- [ ] Transfer progress shows for each file
- [ ] Receiver updates list immediately

### Platform-Specific
- [ ] Android emulator → Windows works
- [ ] Windows → Android emulator works (with ADB)
- [ ] Physical Android → Windows works
- [ ] Windows → Physical Android works

### Error Handling
- [ ] Graceful error for invalid IP address
- [ ] Graceful error for invalid port
- [ ] Graceful error when receiver not running
- [ ] Graceful error for network timeout
- [ ] Graceful error when file access denied

---

## Performance Testing

Test with various file sizes and types:

| File Size | File Type | Expected Time | Status |
|-----------|-----------|---------------|--------|
| < 1 MB | .txt | < 1 sec | [ ] |
| 10 MB | .jpg | 1-3 sec | [ ] |
| 50 MB | .pdf | 5-10 sec | [ ] |
| 100 MB | .zip | 10-20 sec | [ ] |
| 500 MB | .mp4 | 1-2 min | [ ] |
| 1 GB | .iso | 2-5 min | [ ] |

**Notes:**
- Times vary based on Wi-Fi speed
- Emulator may be slower than physical devices
- Windows ↔ Windows typically fastest

---

## Debugging Tips

### Enable Verbose Logging

Add to `transfer_service.dart`:
```dart
print('📤 Sending to: $receiverIp:$receiverPort');
print('📥 File: ${file.name} (${file.size} bytes)');
print('✅ Transfer complete');
```

### View Flutter Logs

```bash
# All logs
flutter logs

# Filtered
flutter logs | Select-String "V-Shere"
```

### View Android Logs

```bash
# All logs
adb logcat

# Filtered for app
adb logcat | Select-String "flutter"
```

### Test Network Connectivity

**Ping test (Windows):**
```bash
ping 10.0.2.2
```

**Test receiver availability:**
```bash
curl http://10.0.2.2:4041/health
# Should return: "V-Shere is ready"
```

---

## Common Issues & Solutions

### Issue: "Connection refused"
**Solution:** Ensure receiver is started first

### Issue: Emulator can't reach Windows
**Solution:** Use `10.0.2.2`, not `127.0.0.1` or `localhost`

### Issue: Windows can't reach emulator
**Solution:** Setup ADB forwarding: `adb forward tcp:4040 tcp:4040`

### Issue: Transfer hangs at 0%
**Solution:** Check firewall, verify IP and port are correct

### Issue: "File does not exist"
**Solution:** Grant storage permissions on Android

---

**Ready to test!** Follow the connection scenarios and mark off each test. 🧪
