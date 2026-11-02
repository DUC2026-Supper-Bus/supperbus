# Get IPA File for V-Shere

## Quick Setup (5 minutes)

### Step 1: Push to GitHub
```bash
git init
git add .
git commit -m "V-Shere iOS build"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/v_shere.git
git push -u origin main
```

### Step 2: Codemagic Setup

1. **Go to [codemagic.io](https://codemagic.io)**
2. **Sign in with GitHub**
3. **Add application** → Select your `v_shere` repo
4. **Configure iOS code signing**:
   - Go to app settings → **Code signing identities**
   - Click **iOS code signing**
   - Choose **Automatic** 
   - Sign in with your Apple ID
   - Select **Ad-hoc** distribution
   - Add your device UDID (see below)

### Step 3: Get Your iPhone UDID

**On Windows**:
1. Connect iPhone to PC
2. Open iTunes or Finder
3. Click on your device
4. Click on "Serial Number" until it shows UDID
5. Right-click → Copy UDID

**Or use Codemagic**:
1. Start a build without device registered
2. Check build logs for UDID
3. Add UDID to Apple Developer Portal

### Step 4: Add Device to Apple Developer

1. Go to [developer.apple.com](https://developer.apple.com)
2. **Certificates, IDs & Profiles** → **Devices**
3. Click **+** button
4. Enter **Name**: My iPhone
5. Enter **UDID**: (paste from step 3)
6. Click **Register**

### Step 5: Build IPA

1. In Codemagic dashboard
2. Select workflow: **v-shere-ios-adhoc**
3. Click **Start new build**
4. Wait ~15-20 minutes
5. Build completes → **Download IPA** from artifacts

**You now have `v_shere.ipa`!** 🎉

---

## Install IPA on iPhone

### Method 1: Sideloadly (Windows, No Mac Needed)

1. **Download [Sideloadly](https://sideloadly.io/)**
2. **Install and open Sideloadly**
3. **Connect iPhone via USB**
4. **Drag `v_shere.ipa` into Sideloadly**
5. **Enter your Apple ID**
6. **Click Start**
7. **On iPhone**: Settings → General → VPN & Device Management → Trust
8. **Done!**

### Method 2: AltStore (Windows/Mac)

1. **Download [AltStore](https://altstore.io/)**
2. **Install AltStore on your PC**
3. **Install AltStore app on iPhone** (follow their guide)
4. **Open AltStore on iPhone**
5. **Tap "+" → Select `v_shere.ipa`**
6. **Trust developer in Settings**
7. **Done!**

### Method 3: 3uTools (Windows)

1. **Download [3uTools](http://www.3u.com/)**
2. **Connect iPhone**
3. **Go to Apps tab**
4. **Click Install → Select `v_shere.ipa`**
5. **Trust developer in Settings**
6. **Done!**

### Method 4: Apple Configurator (Mac)

1. **Download from Mac App Store**
2. **Connect iPhone**
3. **Drag `v_shere.ipa` onto your device**
4. **Trust developer in Settings**
5. **Done!**

---

## Troubleshooting

### "Unable to install"
- Make sure device UDID is registered in Apple Developer Portal
- Rebuild IPA with correct UDID

### "Untrusted Developer"
- Settings → General → VPN & Device Management
- Tap developer name → Trust

### "App installation failed"
- Delete old version if exists
- Restart iPhone
- Try different installation method

---

## No Apple Developer Account? ($99/year)

### Option: Development Build (Free, 7 days)

If you have a Mac:

```bash
# Connect iPhone via USB
flutter build ios --release --no-codesign
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select your iPhone as target
# 2. Select Runner → Signing & Capabilities
# 3. Check "Automatically manage signing"
# 4. Select your free Apple ID as Team
# 5. Change bundle ID to: com.yourname.vshere
# 6. Click Run (⌘R)
```

App expires after 7 days, rebuild to extend.

---

## Summary

**With Apple Developer Account ($99/year)**:
```
1. Push to GitHub
2. Setup Codemagic
3. Register device UDID
4. Build IPA (takes 15-20 min)
5. Install with Sideloadly/AltStore
6. Lasts 1 year ✓
```

**Without Apple Developer Account (Free)**:
```
1. Need a Mac with Xcode
2. Build and run directly from Xcode
3. Lasts 7 days
4. Rebuild weekly
```

**Easiest**: Get Apple Developer Account + use Codemagic → Install with Sideloadly

---

**Got your IPA?** Just drag it into Sideloadly and you're done! 📱✨
