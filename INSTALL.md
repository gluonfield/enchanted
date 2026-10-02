# Sideloading Installation Guide

This guide covers installing unsigned builds of Enchanted on macOS and iOS devices. The official release is available on the [App Store](https://apps.apple.com/gb/app/enchanted-llm/id6474268307), but developers or testers may need to install unsigned builds directly.

## macOS Installation

### Method 1: Terminal (Recommended)

When you download an unsigned `.app` file, macOS Gatekeeper will block it. Remove the quarantine attribute to allow execution:

```bash
xattr -cr /path/to/Enchanted.app
```

Then open the app normally by double-clicking or running:

```bash
open /path/to/Enchanted.app
```

### Method 2: System Settings

1. Attempt to open the app (it will be blocked)
2. Open **System Settings** > **Privacy & Security**
3. Scroll to the **Security** section
4. Find the message about Enchanted being blocked
5. Click **Open Anyway**
6. Confirm by clicking **Open** in the dialog

### Method 3: Right-Click Open

1. Right-click (or Control-click) on `Enchanted.app`
2. Select **Open** from the context menu
3. Click **Open** in the security dialog

This bypasses Gatekeeper for that specific launch and remembers your choice.

---

## iOS Installation

iOS requires sideloading tools to install unsigned `.ipa` files. Choose one of the following methods.

### Method 1: AltStore

[AltStore](https://altstore.io/) is a free sideloading tool that uses your Apple ID to sign apps.

**Requirements:**
- macOS or Windows computer
- Apple ID (free account works)
- Lightning/USB-C cable

**Steps:**

1. Download and install AltServer on your computer from [altstore.io](https://altstore.io/)
2. Connect your iOS device via USB
3. On macOS: Run AltServer, click the menu bar icon, select your device, and click **Install AltStore**
4. On your iOS device, trust the developer certificate:
   - Go to **Settings** > **General** > **VPN & Device Management**
   - Tap your Apple ID under "Developer App"
   - Tap **Trust**
5. Open AltStore on your iOS device
6. Go to **My Apps** > tap **+** > select the Enchanted `.ipa` file
7. Enter your Apple ID credentials when prompted

**Note:** Free Apple IDs allow 3 sideloaded apps and require weekly re-signing. Keep AltServer running on your computer and connect to the same Wi-Fi to enable automatic refresh.

### Method 2: Sideloadly

[Sideloadly](https://sideloadly.io/) is a user-friendly tool for sideloading apps.

**Requirements:**
- macOS or Windows computer
- Apple ID
- USB cable

**Steps:**

1. Download Sideloadly from [sideloadly.io](https://sideloadly.io/)
2. Connect your iOS device via USB
3. Open Sideloadly and drag the `.ipa` file onto the window
4. Enter your Apple ID in the "Apple account" field
5. Select your iOS device from the dropdown
6. Click **Start**
7. Enter your Apple ID password when prompted
8. On your iOS device, trust the developer certificate:
   - **Settings** > **General** > **VPN & Device Management**
   - Tap your Apple ID > **Trust**

### Method 3: Apple Configurator 2 (macOS only)

Apple Configurator 2 is Apple's official tool for deploying apps to iOS devices.

**Requirements:**
- Mac with Apple Configurator 2 (free from Mac App Store)
- Apple ID enrolled in Apple Developer Program or valid provisioning profile
- USB cable

**Steps:**

1. Install [Apple Configurator 2](https://apps.apple.com/app/apple-configurator-2/id1037126344) from the Mac App Store
2. Connect your iOS device via USB
3. Open Apple Configurator 2 and select your device
4. Go to **Add** > **Apps**
5. Click **Choose from my Mac** and select the `.ipa` file
6. The app will be installed on your device

**Note:** Apple Configurator 2 works best with properly signed apps or when used with a developer account.

---

## Troubleshooting

### macOS Issues

**"Enchanted.app is damaged and can't be opened"**
- Run `xattr -cr /path/to/Enchanted.app` in Terminal
- If the error persists, re-download the file (it may be corrupted)

**"Cannot be opened because the developer cannot be verified"**
- Use any of the three methods above to bypass Gatekeeper
- Ensure you have admin privileges on your Mac

**App crashes immediately after opening**
- Check Console.app for crash logs
- Ensure you're running a compatible macOS version
- Try removing and re-extracting the app

### iOS Issues

**"Unable to Install" error in AltStore/Sideloadly**
- Ensure your Apple ID doesn't have two-factor authentication issues
- Generate an app-specific password at [appleid.apple.com](https://appleid.apple.com) if needed
- Check that your device is trusted on your computer

**"Untrusted Developer" message**
- Go to **Settings** > **General** > **VPN & Device Management**
- Tap the developer profile and select **Trust**

**App expires after 7 days (free Apple ID)**
- Free Apple IDs require re-signing every 7 days
- Keep AltServer running and connected to the same Wi-Fi as your device
- Alternatively, use a paid Apple Developer account ($99/year) for 1-year signatures

**"Your session has expired" in AltStore**
- Re-enter your Apple ID credentials in AltStore settings
- Generate a new app-specific password if using two-factor authentication

**"Maximum number of apps reached" (free Apple ID)**
- Free accounts allow only 3 sideloaded apps
- Remove an existing sideloaded app before installing a new one

**App won't open after installation**
- Verify the `.ipa` file is not corrupted
- Check that the app supports your iOS version
- Try reinstalling with a fresh download

### General Tips

- Always download `.ipa` and `.app` files from trusted sources
- Keep backups of your provisioning profiles and certificates
- For development builds, ensure the correct bundle identifier is used
- If using a corporate or school Apple ID, contact your administrator as managed IDs may have restrictions
