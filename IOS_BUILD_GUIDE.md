# iOS Build & Installation Guide

This guide explains how to build V-Shere for iPhone and install it on your device.

## 📱 Three Ways to Get V-Shere on iPhone

### Option 1: Ad-Hoc Build (Recommended for Personal Use)
✅ Install directly on your iPhone  
✅ No App Store submission needed  
✅ Valid for 1 year  
⚠️ Requires Apple Developer Account ($99/year)

### Option 2: Development Build (Testing Only)
✅ Free with Xcode  
✅ Quick testing  
⚠️ Expires after 7 days  
⚠️ Requires Mac with Xcode

### Option 3: App Store (Public Distribution)
✅ Available to everyone  
✅ Automatic updates  
⚠️ Requires Apple Developer Account  
⚠️ App Store review process (1-7 days)

---

## 🚀 Quick Start: Using Codemagic (Easiest)

### Step 1: Sign Up for Codemagic
1. Go to [codemagic.io](https://codemagic.io)
2. Sign up with GitHub/GitLab/Bitbucket
3. Free tier includes 500 build minutes/month

### Step 2: Connect Your Repository
1. Push your V-Shere code to GitHub/GitLab
2. In Codemagic, click **"Add application"**
3. Select your repository
4. Codemagic will detect `codemagic.yaml`

### Step 3: Set Up iOS Signing

#### For Ad-Hoc Build (Personal iPhone):

1. **Get Apple Developer Account**
   - Visit [developer.apple.com](https://developer.apple.com)
   - Enroll ($99/year)

2. **Add Your iPhone UDID to Apple Developer Portal**
   - Connect iPhone to Mac
   - Open Finder → Select iPhone → Copy UDID
   - Or use Codemagic's UDID finder: Run workflow first, get UDID from logs
   
   In Apple Developer Portal:
   - Certificates, IDs & Profiles → Devices
   - Click **+** to register device
   - Enter Name: "My iPhone" and UDID
   - Click **Continue** → **Register**

3. **In Codemagic Dashboard**:
   - Go to App settings → Code signing
   - Click **"Automatic code signing"**
   - Connect your Apple Developer account
   - Select **Ad-Hoc** distribution
   - Select your registered device

4. **Configure Environment Variables**:
   
   Go to App settings → Environment variables:
   
   ```
   BUNDLE_ID = com.example.v_shere
   ```

5. **Start Build**:
   - Select workflow: `v-shere-ios-adhoc`
   - Click **"Start new build"**
   - Wait 15-20 minutes
   - Download IPA from artifacts

### Step 4: Install IPA on iPhone

#### Method A: Install via Codemagic Link (Easiest)
1. After build completes, Codemagic sends email with link
2. Open email **on your iPhone**
3. Tap the install link
4. Follow on-screen instructions
5. Go to Settings → General → VPN & Device Management
6. Trust the developer profile
7. V-Shere is installed!

#### Method B: Install via TestFlight
1. In Codemagic, enable TestFlight publishing
2. Add your Apple ID as tester
3. You'll receive TestFlight invite
4. Install TestFlight app from App Store
5. Accept invite and install V-Shere

#### Method C: Install via AltStore (No Mac Needed)
1. Download [AltStore](https://altstore.io)
2. Install AltStore on your iPhone
3. Download IPA from Codemagic
4. Open IPA in AltStore
5. V-Shere is installed!
   
⚠️ **Note**: AltStore apps must be refreshed every 7 days

---

## 💻 Manual Build with Xcode (Free, 7-Day Expiry)

### Requirements
- Mac with Xcode installed
- Free Apple ID (no paid account needed)
- iPhone connected via USB

### Step 1: Open Project in Xcode
```bash
cd v_shere
flutter build ios --release --no-codesign
open ios/Runner.xcworkspace
```

### Step 2: Configure Signing
1. In Xcode, select **Runner** in project navigator
2. Go to **Signing & Capabilities** tab
3. Check **"Automatically manage signing"**
4. Select your **Team** (your Apple ID)
5. Change **Bundle Identifier** to something unique:
   - Example: `com.yourname.vshere`

### Step 3: Connect iPhone
1. Connect iPhone to Mac via USB
2. Unlock iPhone
3. Trust the computer when prompted
4. In Xcode, select your iPhone from device dropdown

### Step 4: Build and Run
1. Click **Product** → **Run** (or press ⌘R)
2. Wait for build to complete
3. App installs on iPhone automatically

### Step 5: Trust Developer
1. On iPhone, go to **Settings**
2. **General** → **VPN & Device Management**
3. Under "Developer App", tap your Apple ID
4. Tap **Trust**
5. Launch V-Shere!

⚠️ **Limitation**: App expires after 7 days. Rebuild to reinstall.

---

## 🏪 App Store Distribution (Public Release)

### Prerequisites
- Apple Developer Account ($99/year)
- Completed app metadata
- Screenshots for App Store listing
- Privacy policy URL

### Step 1: Prepare App Store Connect
1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Click **My Apps** → **+** → **New App**
3. Fill in app details:
   - **Name**: V-Shere
   - **Language**: English
   - **Bundle ID**: com.example.v_shere
   - **SKU**: vshere-001

### Step 2: Update Codemagic Configuration

Add to `codemagic.yaml`:

```yaml
publishing:
  app_store_connect:
    api_key: $APP_STORE_CONNECT_PRIVATE_KEY
    key_id: $APP_STORE_CONNECT_KEY_IDENTIFIER
    issuer_id: $APP_STORE_CONNECT_ISSUER_ID
    submit_to_testflight: true
    submit_to_app_store: false  # Set true when ready
```

### Step 3: Get API Keys from Apple
1. App Store Connect → Users and Access → Keys
2. Click **+** to create new key
3. Name: "Codemagic"
4. Access: **Admin** or **App Manager**
5. Download key file (`.p8`)
6. Save Key ID and Issuer ID

### Step 4: Add Keys to Codemagic
1. Codemagic → App settings → Environment variables
2. Add secure variables:
   ```
   APP_STORE_CONNECT_ISSUER_ID = (from Apple)
   APP_STORE_CONNECT_KEY_IDENTIFIER = (from Apple)
   APP_STORE_CONNECT_PRIVATE_KEY = (paste .p8 file content)
   ```

### Step 5: Build and Submit
1. Run workflow: `v-shere-ios`
2. Codemagic uploads to App Store Connect automatically
3. In App Store Connect, add screenshots and description
4. Submit for review
5. Wait 1-7 days for approval

---

## 📋 Comparison Table

| Method | Cost | Validity | Effort | Best For |
|--------|------|----------|--------|----------|
| **Ad-Hoc Build** | $99/year | 1 year | Medium | Personal use, testing |
| **Development Build** | Free | 7 days | Low | Quick testing |
| **App Store** | $99/year | Permanent | High | Public distribution |
| **AltStore** | Free | 7 days* | Low | No Mac available |

*Requires weekly refresh

---

## 🔧 Troubleshooting

### "Unable to install V-Shere"
- **Cause**: Device UDID not registered (Ad-Hoc) or certificate expired
- **Fix**: Re-register device in Apple Developer Portal, rebuild

### "Untrusted Developer"
- **Cause**: Developer certificate not trusted on device
- **Fix**: Settings → General → VPN & Device Management → Trust

### "Could not launch V-Shere"
- **Cause**: App expired (development builds expire after 7 days)
- **Fix**: Rebuild and reinstall

### "No signing certificate found"
- **Cause**: Xcode can't find valid certificate
- **Fix**: Check Apple Developer account, regenerate certificates

### Codemagic build fails with signing error
- **Cause**: Incorrect API keys or bundle ID mismatch
- **Fix**: Double-check environment variables, verify bundle ID

---

## 🎯 Recommended Workflow for You

### For Personal Use (Just Your iPhone):

1. **Use Ad-Hoc Build**:
   ```
   ✓ Get Apple Developer Account ($99/year)
   ✓ Register your iPhone UDID
   ✓ Use Codemagic to build Ad-Hoc IPA
   ✓ Install via Codemagic link (lasts 1 year)
   ```

2. **Alternative: Development Build** (Free but temporary):
   ```
   ✓ Use Xcode (requires Mac)
   ✓ Build with free Apple ID
   ✓ Install directly on iPhone
   ⚠️ Rebuild every 7 days
   ```

### For Sharing with Friends:

1. **Use TestFlight** (Free distribution to 100 testers):
   ```
   ✓ Requires Apple Developer Account
   ✓ Build via Codemagic
   ✓ Enable TestFlight publishing
   ✓ Invite friends via email
   ✓ They install via TestFlight app
   ```

### For Public Release:

1. **Submit to App Store**:
   ```
   ✓ Apple Developer Account required
   ✓ Create App Store Connect listing
   ✓ Add screenshots and description
   ✓ Submit for review
   ✓ Available to everyone after approval
   ```

---

## 📞 Quick Help Commands

### Get Your iPhone UDID (Windows):
```powershell
# Install ideviceinfo
winget install --id=libimobiledevice.libimobiledevice -e

# Get UDID
idevice_id -l
```

### Get Your iPhone UDID (Mac):
```bash
# Method 1: Using system_profiler
system_profiler SPUSBDataType | grep "Serial Number"

# Method 2: Using Finder
# Connect iPhone → Open Finder → Click iPhone → Click info below name
```

### Build IPA locally (with Mac):
```bash
# Clean build
flutter clean
flutter pub get

# Build IPA
flutter build ipa --release

# IPA location: build/ios/ipa/v_shere.ipa
```

---

## 🎉 Success!

Once installed, V-Shere will appear on your iPhone home screen with a lightning bolt icon ⚡

**First Launch**:
1. Open V-Shere
2. Grant network permissions when prompted
3. Tap "Receive Files" to test
4. Your iPhone is ready to receive files!

---

## 📚 Additional Resources

- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Codemagic iOS Documentation](https://docs.codemagic.io/yaml-code-signing/signing-ios/)
- [Apple Developer Portal](https://developer.apple.com)
- [TestFlight Guide](https://developer.apple.com/testflight/)

---

**Need more help?** Check the main README.md or open an issue on GitHub! 📱✨
