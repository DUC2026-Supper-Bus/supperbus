# Device Discovery Guide - V-Shere v2.0

## 🎉 What's New

V-Shere now has **automatic device discovery**! No more typing IP addresses manually.

### Key Features

- ✅ **Auto-Discovery**: Devices appear automatically on the same Wi-Fi network
- ✅ **One-Tap Connection**: Just tap a device to send files
- ✅ **Platform Detection**: See what type of device you're connecting to (Android/iOS/Windows)
- ✅ **Manual Fallback**: Still supports manual IP entry if needed
- ✅ **Real-time Updates**: Devices appear/disappear as they come online/offline

---

## 🚀 How It Works

### On Receiver Side

1. **Open V-Shere**
2. **Tap "Receive Files"**
3. **Tap "Start Receiving"**
4. Device automatically announces itself on the network
5. Wait for files (or share your IP manually if sender can't see you)

### On Sender Side

1. **Open V-Shere**
2. **Tap "Send Files"**
3. **Tap "Choose Files"** and select files
4. **Wait a few seconds** for devices to appear
5. **Tap on a device** to send files
6. Done! No IP typing needed!

---

## 🔍 Discovery Methods

### Method 1: Automatic Discovery (Recommended)

**Pros:**
- No IP typing needed
- See device names and platforms
- One-tap to connect
- Real-time device list

**Cons:**
- Requires same Wi-Fi network
- May take 2-5 seconds to discover
- Some networks block mDNS (corporate/school networks)

### Method 2: Manual IP Entry (Fallback)

**When to use:**
- Auto-discovery doesn't work
- Corporate/school networks
- VPN connections
- Cross-network transfers

**How to:**
1. On Send screen, tap the **edit icon** (top right)
2. Enter receiver's IP and port manually
3. Choose files and send

---

## 📱 User Interface

### Send Screen - Device List Mode (Default)

```
┌─────────────────────────────────┐
│  Send Files          [✏️] [🔄]  │
├─────────────────────────────────┤
│                                 │
│  [📎 Choose Files (2 selected)] │
│                                 │
│  2 device(s) found              │
│                                 │
│  Available Devices              │
│                                 │
│  ┌─────────────────────────────┐│
│  │ 🤖 V-Shere-100             ││
│  │ 192.168.1.100:4040 • Android││
│  │                          → ││
│  └─────────────────────────────┘│
│                                 │
│  ┌─────────────────────────────┐│
│  │ 💻 V-Shere-101             ││
│  │ 192.168.1.101:4041 • Windows││
│  │                          → ││
│  └─────────────────────────────┘│
│                                 │
└─────────────────────────────────┘
```

**Icons:**
- [✏️] - Switch to manual IP entry
- [🔄] - Refresh device list
- → - Tap device to send files

### Send Screen - Manual Entry Mode

```
┌─────────────────────────────────┐
│  Send Files          [📱] [🔄]  │
├─────────────────────────────────┤
│                                 │
│  [📎 2 file(s) selected]        │
│                                 │
│  Receiver IP Address            │
│  [192.168.1.100           ]    │
│                                 │
│  Receiver Port                  │
│  [4040                    ]    │
│                                 │
│  [        Send Now         ]    │
│                                 │
└─────────────────────────────────┘
```

**Icons:**
- [📱] - Switch back to device list
- [🔄] - Refresh (still available)

---

## 🛠️ Technical Details

### mDNS/Bonjour Protocol

V-Shere uses **multicast DNS** (same as AirDrop, Chromecast) to discover devices.

**Service Type:** `_vshere._tcp.local`

**Announcement:**
- Every 3 seconds while receiver is running
- Includes device name, IP, port, and platform

**Discovery:**
- Sender queries network every 2 seconds
- Devices respond with their information
- Auto-updates as devices come/go

### Ports

- Android: `4040`
- Windows: `4041`
- iOS: `4040`

### Permissions Required

**Android:**
- `INTERNET` - Network communication
- `ACCESS_NETWORK_STATE` - Check Wi-Fi status
- `CHANGE_WIFI_MULTICAST_STATE` - mDNS discovery

**iOS:**
- `NSLocalNetworkUsageDescription` - Local network access
- `NSBonjourServices` - mDNS services

**Windows:**
- No special permissions needed
- May need to allow through Windows Firewall

---

## 🐛 Troubleshooting

### No Devices Showing Up

**Check:**
1. ✅ Both devices on **same Wi-Fi network**
2. ✅ Receiver is **running** ("Ready to receive files")
3. ✅ Wait **5-10 seconds** after opening Send screen
4. ✅ Tap **refresh icon** to search again
5. ✅ Try **manual IP entry** as fallback

### Devices Appear But Can't Connect

**Solutions:**
1. **Firewall**: Check Windows Firewall or antivirus
2. **Router**: Some routers block device-to-device communication (AP Isolation)
3. **VPN**: Disable VPN if active
4. **Network**: Try different Wi-Fi network

### Discovery Works on One Platform But Not Another

**Common Issues:**
- **Android Emulator**: Discovery won't work, use manual IP with ADB forwarding
- **Windows**: May need to allow app through Windows Firewall first time
- **iOS**: Grant "Local Network" permission when prompted

### Corporate/School Network

Many corporate and school networks **block mDNS** for security.

**Workaround:**
- Use **manual IP entry mode**
- Or use a personal hotspot

---

## 🔐 Security

### Is Discovery Secure?

**Yes, but with caveats:**
- Devices only visible on **local network** (not internet)
- No authentication required (trust-based)
- Files transferred over **unencrypted HTTP**

**Future plans (v3.0):**
- End-to-end encryption
- Device pairing/authentication
- HTTPS transfers

### Privacy

- Device name shown is auto-generated (`V-Shere-XXX`)
- Only visible while receiver is running
- No personal information broadcasted

---

## 💡 Tips & Tricks

### Faster Discovery

1. Start receiver **before** opening sender
2. Keep both devices **close** to router
3. Use **5GHz Wi-Fi** if available (faster than 2.4GHz)

### Troubleshooting Connection Issues

1. Try the **refresh button** first
2. Check **receiver is running** (shows IP on screen)
3. Try **manual IP entry** as fallback
4. Restart both apps if needed

### Best Performance

- **Same Wi-Fi band** (both on 2.4GHz or both on 5GHz)
- **Close proximity** to router
- **Minimal interference** (microwave, Bluetooth devices)
- **Good signal strength** on both devices

---

## 📊 Comparison: Discovery vs Manual

| Feature | Auto-Discovery | Manual IP |
|---------|---------------|-----------|
| **Ease of use** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Speed** | 2-5 seconds | Instant |
| **Network requirements** | Same Wi-Fi | Any network |
| **Works on all networks** | ❌ | ✅ |
| **Device info shown** | ✅ | ❌ |
| **One-tap connect** | ✅ | ❌ |
| **Fallback option** | ✅ | N/A |

---

## 🔄 How to Switch Modes

### Switch to Manual Mode

1. Open Send screen
2. Tap **edit icon** (✏️) in top right
3. Enter IP and port manually

### Switch Back to Device List

1. In manual mode
2. Tap **devices icon** (📱) in top right
3. See auto-discovered devices again

---

## 🎯 Use Cases

### Home Network (Auto-Discovery)

Perfect for:
- Sharing photos with family
- Transferring files between your devices
- Quick document sharing

### Office/School (Manual IP)

Better for:
- Networks that block mDNS
- VPN connections
- When auto-discovery doesn't work

### Emulator/Development (Manual IP)

Required for:
- Android emulator ↔ Windows (use `10.0.2.2`)
- Testing with ADB forwarding
- Docker containers

---

## 📝 Version History

**v2.0 (Current)**
- ✅ Automatic device discovery
- ✅ One-tap connection
- ✅ Platform detection
- ✅ Manual IP fallback
- ✅ Real-time device updates

**v1.0**
- Manual IP entry only
- No device discovery
- Basic file transfer

---

## 🚀 Coming Soon (v3.0)

- 🔐 End-to-end encryption
- 🔑 Device pairing/authentication
- 📊 Transfer speed indicator
- ⏸️ Pause/resume transfers
- 📁 Folder transfer
- 🌐 QR code pairing

---

**V-Shere v2.0** - Discover. Connect. Share. ⚡
