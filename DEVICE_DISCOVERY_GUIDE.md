# Device Discovery Guide - V-Shere v2.0

## 🎉 What's New

V-Shere can automatically discover receiving devices on the same local Wi-Fi network. Manual IP entry is also available as a fallback.

### Key Features

- ✅ **Auto-Discovery**: Devices appear automatically on the same Wi-Fi network
- ✅ **Quick Connection**: Select a discovered device, then send files
- ✅ **Platform Detection**: See what type of device you're connecting to (Android/iOS/Windows)
- ✅ **Manual Fallback**: Still supports manual IP entry if needed
- ✅ **Refreshable Device List**: Rescan the network for available receivers

---

## 🚀 How It Works

### On Receiver Side

1. **Open V-Shere**
2. **Tap "Receive Files"**
3. **Tap "Start Receiving"**
4. The receiver responds to discovery requests from the sender
5. Wait for files (or share your IP manually if sender can't see you)

### On Sender Side

1. **Open V-Shere**
2. **Tap "Send Files"**
3. **Tap "Choose Files"** and select files
4. **Wait a few seconds** for devices to appear
5. **Select a device** from the list
6. Choose **Send Now** to transfer the files

---

## 🔍 Discovery Methods

### Method 1: Automatic Discovery (Recommended)

**Pros:**
- No IP typing needed
- See device names and platforms
- Select a device instead of entering its IP address
- Device list updates as receivers respond

**Cons:**
- Requires same Wi-Fi network
- May take 2-5 seconds to discover
- Some networks block UDP broadcast traffic (corporate/school networks)

### Method 2: Manual IP Entry (Fallback)

**When to use:**
- Auto-discovery doesn't work
- Corporate/school networks
- VPN connections
- Cross-network transfers

**How to:**
1. Enter the receiver's IP address in the receiver field.
2. Use the settings icon to show the port field if the receiver uses a non-default port.
3. Choose files and send.

---

## 📱 User Interface

### Send Screen

```
┌─────────────────────────────────┐
│  Send Files                 [⚙️] │
├─────────────────────────────────┤
│                                 │
│  [📎 Choose Files (2 selected)] │
│                                 │
│  2 device(s) found              │
│                                 │
│  Available Devices              │
│                                 │
│  ┌─────────────────────────────┐│
│  │ 🤖 receiver-host            ││
│  │ 192.168.1.100:4040 • Android││
│  │                          → ││
│  └─────────────────────────────┘│
│                                 │
│  ┌─────────────────────────────┐│
│  │ 💻 desktop-host              ││
│  │ 192.168.1.101:4041 • Windows││
│  │                          → ││
│  └─────────────────────────────┘│
│                                 │
└─────────────────────────────────┘
```

The receiver field accepts a discovered device name or an IP address. Tap a device to fill in its details, then choose files and send them. Use the settings icon to show or hide the port field, and the refresh icon above the device list to scan again.

---

## 🛠️ Technical Details

### UDP Broadcast Discovery

V-Shere uses UDP broadcast to find receivers on the local network.

**Discovery port:** `4042`

**Request:** The sender broadcasts `V_SHERE_DISCOVER` every 3 seconds.

**Response:** A running receiver replies with its local IP address, port, device name, and platform.

### Ports

- Android: `4040`
- Windows: `4041`
- iOS: `4040`

### Permissions Required

**Android:**
- `INTERNET` - Network communication
- `ACCESS_NETWORK_STATE` - Check Wi-Fi status

**iOS:**
- `NSLocalNetworkUsageDescription` - Local network access

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
4. ✅ Tap the refresh icon above the device list to search again
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

Some corporate and school networks block UDP broadcast traffic or isolate Wi-Fi clients.

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

- The device's local hostname, IP address, and platform are shared with senders on the local network
- Only visible while receiver is running

---

## 💡 Tips & Tricks

### Faster Discovery

1. Start receiver **before** opening sender
2. Keep both devices **close** to router
3. Use **5GHz Wi-Fi** if available (faster than 2.4GHz)

### Troubleshooting Connection Issues

1. Try the refresh button above the device list
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
| **Select receiver by name** | ✅ | ❌ |
| **Fallback option** | ✅ | N/A |

---

## 🔄 Manual Connection

Enter the receiver's IP address in the receiver field. Use the settings icon to show the port field when the receiver uses a non-default port. Discovered devices appear in the nearby devices list.

---

## 🎯 Use Cases

### Home Network (Auto-Discovery)

Perfect for:
- Sharing photos with family
- Transferring files between your devices
- Quick document sharing

### Office/School (Manual IP)

Better for:
- Networks that block UDP broadcast traffic
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
