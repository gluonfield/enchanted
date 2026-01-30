# Sideloading Installation Guide

This guide covers installing unsigned builds of Enchanted on macOS and iOS devices. The official release is available on the [App Store](https://apps.apple.com/gb/app/enchanted-llm/id6474268307), but developers or testers may need to install unsigned builds directly.

## macOS Installation

### Method 1: Terminal (Recommended)

When you download an unsigned `.app` file, macOS Gatekeeper will block it. Remove the quarantine attribute to allow execution:

```bash
xattr -cr /path/to/Enchanted.app
```

Or if you downloaded the DMG:

```bash
xattr -cr /path/to/Enchanted.dmg
```

Then open the DMG and drag Enchanted to your Applications folder.

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

### Prerequisites

- An Apple ID (free accounts work but apps expire after 7 days)
- The Enchanted `.ipa` file downloaded from releases
- A computer (Mac or Windows, depending on the tool)

### Method 1: AltStore (Recommended)

[AltStore](https://altstore.io/) is a free sideloading tool that uses your Apple ID to sign apps and automatically refreshes apps before they expire.

**Steps:**

1. Download and install AltServer on your computer from [altstore.io](https://altstore.io/)
2. Connect your iOS device via USB
3. On macOS: Run AltServer, click the menu bar icon, select your device, and click **Install AltStore**
4. On Windows: Install iTunes and iCloud from Apple's website (not Microsoft Store versions), then follow the same steps
5. On your iOS device, trust the developer certificate:
   - Go to **Settings** > **General** > **VPN & Device Management**
   - Tap your Apple ID under "Developer App"
   - Tap **Trust**
6. Open AltStore on your iOS device
7. Go to **My Apps** > tap **+** > select the Enchanted `.ipa` file
8. Enter your Apple ID credentials when prompted

**Note:** Free Apple IDs allow 3 sideloaded apps and require weekly re-signing. Keep AltServer running on your computer and connect to the same Wi-Fi to enable automatic refresh.

### Method 2: Sideloadly

[Sideloadly](https://sideloadly.io/) is a user-friendly tool for sideloading apps.

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

**Note:** Apple Configurator 2 requires the IPA to be signed or used with a developer account. For unsigned IPAs, use AltStore or Sideloadly instead.

**Steps:**

1. Install [Apple Configurator 2](https://apps.apple.com/app/apple-configurator-2/id1037126344) from the Mac App Store
2. Connect your iOS device via USB and trust the computer
3. Open Apple Configurator 2 and select your device
4. Go to **Add** > **Apps**
5. Click **Choose from my Mac** and select the `.ipa` file
6. The app will be installed on your device

---

## Troubleshooting

### macOS Issues

**"Enchanted.app is damaged and can't be opened"**
- Run `xattr -cr /path/to/Enchanted.app` in Terminal
- If using a DMG, run the command on the DMG file first, then on the extracted app
- If the error persists, re-download the file (it may be corrupted)

**"Cannot be opened because the developer cannot be verified"**
- Use any of the three methods above to bypass Gatekeeper
- Try right-clicking the app and selecting "Open" instead of double-clicking

**App crashes immediately after opening**
- Check Console.app for crash logs
- Ensure you're running a compatible macOS version
- Try removing and re-extracting the app

### iOS Issues

**"Unable to Install" error**
- Ensure you're using a valid Apple ID
- Free Apple IDs have a limit of 3 apps at a time
- Try revoking existing app certificates in the sideloading tool
- Generate an app-specific password at [appleid.apple.com](https://appleid.apple.com) if needed

**"Untrusted Developer" message**
- Go to **Settings** > **General** > **VPN & Device Management**
- Find your Apple ID under "Developer App"
- Tap "Trust [your email]"

**App expires after 7 days (free Apple ID)**
- Free Apple IDs require re-signing every 7 days
- Keep AltServer running and connected to the same Wi-Fi as your device
- Alternatively, use a paid Apple Developer account ($99/year) for 1-year signatures

**App crashes immediately on launch**
- The certificate may have expired (7 days for free accounts)
- Reinstall the app using your sideloading tool
- With AltStore, ensure AltServer is running on your computer to auto-refresh

**App won't install on iOS 17+**
- Ensure your sideloading tool is updated to the latest version
- Try enabling Developer Mode: **Settings** > **Privacy & Security** > **Developer Mode**

**"Maximum number of apps reached" (free Apple ID)**
- Free accounts allow only 3 sideloaded apps
- Remove an existing sideloaded app before installing a new one

---

## Building from Source

If you prefer to build Enchanted yourself:

1. Clone the repository
2. Open `Enchanted.xcodeproj` in Xcode
3. Select your target device/simulator
4. Build and run (Cmd+R)

For CI-built artifacts, check the GitHub Actions workflow runs for downloadable builds.
