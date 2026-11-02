# Get IPA File for Sideloadly - Quick Checklist

## What You Need
- Apple Developer Account (free or paid)
- Your iPhone connected to computer
- Codemagic account connected to GitHub

---

## ☐ Step 1: Register Bundle ID (5 minutes)

1. Go to: https://developer.apple.com/account/resources/identifiers/list
2. Click the **+ button** (top right)
3. Select **App IDs** → Click **Continue**
4. Select **App** → Click **Continue**
5. Fill in:
   - **Description**: `V-Shere`
   - **Bundle ID**: Select **Explicit** and enter: `com.vsal007.vshere`
6. Click **Continue** → Click **Register**

✅ Done when you see "Registration Complete"

---

## ☐ Step 2: Register Your iPhone UDID (5 minutes)

### Get UDID:
**Windows (iTunes):**
1. Connect iPhone to computer
2. Open iTunes
3. Click on iPhone icon (top left)
4. Click on text below iPhone name until you see **UDID**
5. Right-click UDID → Copy

**Mac (Finder):**
1. Connect iPhone to computer
2. Open Finder
3. Select iPhone in sidebar
4. Click on text below iPhone name until you see **UDID**
5. Right-click UDID → Copy

### Register UDID:
1. Go to: https://developer.apple.com/account/resources/devices/list
2. Click the **+ button**
3. Select **iOS, tvOS, watchOS** → Click **Continue**
4. Fill in:
   - **Device Name**: `My iPhone` (or any name you want)
   - **UDID**: Paste the copied UDID
5. Click **Continue** → Click **Register**

✅ Done when you see "Registration Complete"

---

## ☐ Step 3: Configure Codemagic Code Signing (10 minutes)

1. Go to: https://codemagic.io/apps
2. Click on your **V_SHERE** app
3. Go to **App settings** (gear icon)
4. Click **Code signing identities** (left sidebar)
5. Scroll to **iOS code signing**
6. Click **Connect Apple Developer Portal**
7. Follow the prompts to authenticate
8. Codemagic will automatically fetch your certificates and provisioning profiles

✅ Done when you see your certificates listed

---

## ☐ Step 4: Start Correct Build (2 minutes)

1. In Codemagic, go to your V_SHERE app
2. Click **Start new build** button
3. **IMPORTANT**: Select workflow: **`v-shere-ios-adhoc`** 
   - ❌ NOT `v-shere-ios` (that's for App Store)
   - ✅ USE `v-shere-ios-adhoc` (that's for Sideloadly)
4. Click **Start new build**

✅ Done when build status shows "Building..."

---

## ☐ Step 5: Download IPA (after build completes)

1. Wait for build to complete (~10-20 minutes)
2. Build status will show **Success** with green checkmark
3. Click on the build
4. Go to **Artifacts** tab
5. Download **v_shere.ipa** file

✅ Done when you have .ipa file on your computer

---

## ☐ Step 6: Install with Sideloadly

1. Download Sideloadly from: https://sideloadly.io/
2. Install and open Sideloadly
3. Connect your iPhone to computer
4. In Sideloadly:
   - Drag the **v_shere.ipa** file to Sideloadly window
   - Select your iPhone from device dropdown
   - Enter your Apple ID email
   - Click **Start**
5. Enter your Apple ID password when prompted
6. Wait for installation to complete

### On Your iPhone:
1. Go to **Settings** → **General** → **VPN & Device Management**
2. Find your Apple ID
3. Tap on **V-Shere**
4. Tap **Trust "your-email@example.com"**
5. Tap **Trust** again to confirm

✅ Done when V-Shere app opens on your iPhone!

---

## Common Issues

### "No provisioning profile found"
- Make sure you completed Step 1 (Register Bundle ID)
- Make sure you completed Step 2 (Register iPhone UDID)
- Make sure you completed Step 3 (Connect Apple Developer Portal in Codemagic)

### "Build failed - distribution type"
- Make sure you selected **`v-shere-ios-adhoc`** workflow
- Do NOT use `v-shere-ios` workflow (that's for App Store)

### "Sideloadly error: Device not found"
- Make sure iPhone is unlocked
- Make sure you tapped "Trust This Computer" on iPhone
- Try different USB cable
- Try different USB port

### "App crashes on launch"
- This might be normal for first launch
- Try force-closing and reopening
- Check iPhone Settings → Privacy for permissions

---

## Summary

```
Bundle ID: com.vsal007.vshere
Workflow: v-shere-ios-adhoc (for Sideloadly)
Distribution: Ad-Hoc (not App Store)
Install Method: Sideloadly
```

**Total time: ~30-40 minutes** (including build time)

---

## Need Help?

- Codemagic docs: https://docs.codemagic.io/yaml-code-signing/signing-ios/
- Sideloadly guide: https://sideloadly.io/#instructions
- Apple Developer Portal: https://developer.apple.com/account/
