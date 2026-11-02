# V-Shere Connection Guide

## Port Configuration

V-Shere uses **separate ports** for Android and Windows to avoid conflicts:

- **Android receiver**: Port `4040`
- **Windows receiver**: Port `4041`

This ensures both platforms can send and receive files simultaneously without port conflicts.

---

## Connection Scenarios

### 1. Android → Windows (Same Network)

**Windows Device (Receiver)**:
1. Open V-Shere on Windows
2. Tap "Receive Files" → "Start Receiving"
3. Note your IP address (e.g., `192.168.1.100`)
4. Note the port: `4041` (automatically shown)

**Android Device (Sender)**:
1. Open V-Shere on Android
2. Tap "Send Files"
3. Enter Windows IP: `192.168.1.100`
4. Enter Port: `4041`
5. Choose files and send

---

### 2. Windows → Android (Same Network)

**Android Device (Receiver)**:
1. Open V-Shere on Android
2. Tap "Receive Files" → "Start Receiving"
3. Note your IP address (e.g., `192.168.1.150`)
4. Note the port: `4040` (automatically shown)

**Windows Device (Sender)**:
1. Open V-Shere on Windows
2. Tap "Send Files"
3. Enter Android IP: `192.168.1.150`
4. Enter Port: `4040`
5. Choose files and send

---

### 3. Android Emulator → Windows Host

The Android emulator runs in a virtual network. Use the special IP `10.0.2.2` to reach your Windows host machine.

**Windows (Receiver)**:
1. Open V-Shere on Windows
2. Tap "Receive Files" → "Start Receiving"
3. Windows will listen on port `4041`

**Android Emulator (Sender)**:
1. Open V-Shere in emulator
2. Tap "Send Files"
3. Enter IP: `10.0.2.2` (special address for host machine)
4. Enter Port: `4041`
5. Choose files and send

**Why `10.0.2.2`?**
- Android emulator uses a virtual network
- `10.0.2.2` is the emulator's gateway to the host machine
- This is standard for all Android emulators

---

### 4. Windows → Android Emulator

Sending from Windows to the Android emulator requires **ADB port forwarding** because the emulator is isolated in a virtual network.

**Step 1: Setup ADB Port Forwarding**

Open PowerShell/Command Prompt and run:
```bash
adb forward tcp:4040 tcp:4040
```

This maps your Windows port 4040 to the emulator's port 4040.

**Step 2: Start Receiving on Emulator**

**Android Emulator (Receiver)**:
1. Open V-Shere in emulator
2. Tap "Receive Files" → "Start Receiving"
3. Emulator will listen on port `4040`

**Step 3: Send from Windows**

**Windows (Sender)**:
1. Open V-Shere on Windows
2. Tap "Send Files"
3. Enter IP: `127.0.0.1` (localhost, forwarded via ADB)
4. Enter Port: `4040`
5. Choose files and send

**Important Notes**:
- Keep ADB forwarding active during transfer
- If connection fails, rerun the `adb forward` command
- Close unused emulators to avoid confusion

---

### 5. Android → Android (Same Network)

**Device A (Receiver)**:
1. Open V-Shere
2. Tap "Receive Files" → "Start Receiving"
3. Note IP (e.g., `192.168.1.120`)
4. Port: `4040`

**Device B (Sender)**:
1. Open V-Shere
2. Tap "Send Files"
3. Enter Device A's IP: `192.168.1.120`
4. Enter Port: `4040`
5. Choose files and send

---

### 6. Windows → Windows (Same Network)

**Computer A (Receiver)**:
1. Open V-Shere
2. Tap "Receive Files" → "Start Receiving"
3. Note IP (e.g., `192.168.1.101`)
4. Port: `4041`

**Computer B (Sender)**:
1. Open V-Shere
2. Tap "Send Files"
3. Enter Computer A's IP: `192.168.1.101`
4. Enter Port: `4041`
5. Choose files and send

---

## Quick Reference Table

| Scenario | Receiver Platform | Receiver Port | Sender IP | Sender Port |
|----------|------------------|---------------|-----------|-------------|
| Android → Windows | Windows | 4041 | Windows LAN IP | 4041 |
| Windows → Android | Android | 4040 | Android LAN IP | 4040 |
| Emulator → Windows | Windows | 4041 | `10.0.2.2` | 4041 |
| Windows → Emulator | Android Emulator | 4040 | `127.0.0.1` (via ADB) | 4040 |
| Android → Android | Android | 4040 | Android LAN IP | 4040 |
| Windows → Windows | Windows | 4041 | Windows LAN IP | 4041 |

---

## Finding Your IP Address

### Windows
**Method 1 - Command Prompt:**
```bash
ipconfig
```
Look for "IPv4 Address" under your active network adapter (usually Wi-Fi or Ethernet).

**Method 2 - Settings:**
1. Open Settings → Network & Internet
2. Click on your connection (Wi-Fi or Ethernet)
3. Find your IP address

### Android
**Method 1 - Settings:**
1. Settings → Wi-Fi
2. Tap on connected network
3. View IP address

**Method 2 - V-Shere:**
Just tap "Receive Files" → "Start Receiving" and V-Shere will display your IP!

### Android Emulator
The emulator shows its internal IP, but to reach the host Windows machine, always use `10.0.2.2`.

---

## Troubleshooting

### "Connection refused" error

**Check these:**
1. ✅ Receiver is running ("Start Receiving" button tapped)
2. ✅ Both devices on same Wi-Fi network (not cellular)
3. ✅ IP address is correct
4. ✅ Port number matches receiver's port
5. ✅ Firewall not blocking the port

**For Emulator → Windows:**
- Use IP: `10.0.2.2`
- Use Port: `4041` (Windows port)

**For Windows → Emulator:**
- Setup ADB forwarding: `adb forward tcp:4040 tcp:4040`
- Use IP: `127.0.0.1`
- Use Port: `4040`

### "Transfer failed" mid-transfer

**Possible causes:**
- Weak Wi-Fi signal
- Network changed during transfer
- Receiver stopped or closed app
- Device went to sleep

**Solutions:**
- Stay close to Wi-Fi router
- Keep both devices awake during transfer
- Try smaller files first
- Restart both apps

### Windows Firewall blocking

**Allow V-Shere through firewall:**
1. Windows Security → Firewall & network protection
2. Advanced settings
3. Inbound Rules → New Rule
4. Port → TCP → 4041
5. Allow connection → Finish

### ADB Forwarding issues

**If forwarding doesn't work:**
```bash
# Remove existing forwarding
adb forward --remove tcp:4040

# Setup new forwarding
adb forward tcp:4040 tcp:4040

# Verify forwarding
adb forward --list
```

Should output:
```
127.0.0.1:4040 tcp:4040
```

### Multiple emulators running

If you have multiple emulators:
```bash
# List devices
adb devices

# Forward to specific device
adb -s emulator-5554 forward tcp:4040 tcp:4040
```

---

## Advanced: Custom Ports

If you need to change ports (e.g., 4040/4041 are blocked):

**Edit `lib/services/transfer_service.dart`:**
```dart
static const int androidPort = 4040;  // Change this
static const int windowsPort = 4041;  // Change this
```

Then rebuild the app:
```bash
flutter clean
flutter pub get
flutter run
```

**Remember:**
- Update firewall rules for new ports
- Update ADB forwarding for new Android port
- Both sender and receiver must use matching ports

---

## Testing Checklist

Before deploying or sharing V-Shere, test these scenarios:

- [ ] Android → Windows (same network)
- [ ] Windows → Android (same network)
- [ ] Android Emulator → Windows host
- [ ] Windows → Android Emulator (with ADB)
- [ ] Android → Android (same network)
- [ ] Windows → Windows (same network)
- [ ] Large file transfer (>100 MB)
- [ ] Multiple files at once
- [ ] Transfer over different Wi-Fi networks

---

## Security Notes

**Current Version (v1.0):**
- ✅ Local network only (no internet exposure)
- ✅ Manual IP entry (explicit connections)
- ⚠️ No encryption (files sent in plain text)
- ⚠️ No authentication (anyone with IP can send)

**Upcoming v2.0:**
- 🔒 End-to-end encryption
- 🔐 Device authentication
- 🎯 QR code pairing
- 📡 Automatic device discovery

**Best Practices:**
- Only use on trusted Wi-Fi networks
- Don't use on public Wi-Fi
- Verify sender before accepting files
- Check received files for malware

---

## Summary

**Key Points:**
1. Android uses port **4040**, Windows uses port **4041**
2. For emulator → Windows: use IP `10.0.2.2` and port `4041`
3. For Windows → emulator: use ADB forwarding, then `127.0.0.1:4040`
4. Always ensure receiver is started before sending
5. Both devices must be on same Wi-Fi (except emulator cases)

**Quick Start:**
1. Start receiver → note IP and port
2. On sender → enter receiver's IP and port
3. Choose files → send!

---

**Need more help?** Check the main README.md or open an issue on GitHub! 🚀
