# MacOSAppStarter

> A production-ready macOS app scaffold demonstrating Sparkle auto-update, signed/notarized CI, i18n, menu bar + window UI, and Homebrew Cask publishing.

[![Build](https://github.com/XueshiQiao/macos-app-starter/actions/workflows/build.yml/badge.svg)](https://github.com/XueshiQiao/macos-app-starter/actions/workflows/build.yml)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## What this is

This repo is the **starter template** referenced by the `/macos-app-scaffold` skill. Use it as a GitHub template to spin up a new app in seconds — much cheaper in AI tokens than asking the model to generate every file from scratch.

```bash
gh repo create my-cool-app --template XueshiQiao/macos-app-starter --public --clone
cd my-cool-app
```

Then run the `/macos-app-scaffold` skill (or its enhance variant) to customize: rename the bundle, pick which features to keep, add new ones.

## Capabilities

| Feature | What's included |
|---|---|
| **Archetype** | Menu Bar + Window (hybrid). `NSStatusItem` with popover, plus a SwiftUI `WindowGroup` main window |
| **Build** | XcodeGen (`project.yml` source of truth), Swift 6.0, macOS 14+ |
| **Auto-update** | Sparkle 2.x via `SPUStandardUpdaterController` (placeholder appcast URL + EdDSA key) |
| **Global hotkey** | `KeyboardShortcuts` integration with rebindable shortcut in Settings → Shortcuts |
| **Settings** | SwiftUI `Settings` scene with General / Updates / Shortcuts / About tabs |
| **Onboarding** | First-launch welcome flow with language picker and Accessibility prompt |
| **Launch at Login** | `SMAppService.mainApp` toggle in Settings |
| **Accessibility gate** | `AXIsProcessTrusted` check + System Settings deep link |
| **Localization** | Full i18n via `Localizable.xcstrings` and `InfoPlist.xcstrings` (en + zh-Hans). `LocalizationManager` for runtime language switch |
| **File logging** | `FileLog.shared` writes to `~/Library/Logs/MacOSAppStarter.log` plus `os.Logger` to Console |
| **Analytics** | Aptabase wrapper, opt-out toggle, no-op until `APTABASE_KEY` is set |
| **CI/CD** | GitHub Actions: builds + tests on every push, signs + notarizes + releases on `v*` tags |
| **Code signing** | Inside-out signing of embedded Mach-O (Sparkle XPCs etc.) before main bundle signing |
| **Lint** | SwiftLint with sensible defaults |
| **Tests** | XCTest skeleton |
| **Distribution** | Homebrew Cask draft (`Casks/macosappstarter.rb`) |
| **License** | MIT |

## Quick start

```bash
# 1. Get the project file
brew install xcodegen
xcodegen generate

# 2. Open in Xcode and run
open MacOSAppStarter.xcodeproj
# Cmd+R

# 3. Or build from CLI
xcodebuild -project MacOSAppStarter.xcodeproj -scheme MacOSAppStarter build
```

## Setup before you ship

1. **Rename**. Update `project.yml` (`name`, `PRODUCT_BUNDLE_IDENTIFIER`, `MARKETING_VERSION`), `Casks/*.rb`, `LICENSE`, `README.md`, this file's badges. Search for `MacOSAppStarter` and `dev.xueshi.macos-app-starter` in the repo to catch every reference.

2. **Apple Developer secrets** (GitHub Actions). Add these repo secrets:
   - `MAC_CERTS_P12_BASE64` — base64'd Developer ID cert
   - `MAC_CERTS_P12_PASSWORD`
   - `APPLE_ID` — Apple ID email
   - `APPLE_TEAM_ID`
   - `APP_SPECIFIC_PASSWORD` — generated at appleid.apple.com
   - `SIGNING_IDENTITY` (optional)

3. **Sparkle — REGENERATE THE KEYPAIR.** This template ships with `SUPublicEDKey` set to a throwaway key whose private half is stored as the `SPARKLE_EDDSA_KEY` secret in *this* repo. If you fork without regenerating, releases you sign won't validate against template users' apps, and (worse) anyone with this template's secret could forge updates that your users would accept.

   Regenerate before your first release:

   ```bash
   # Build once so Sparkle's tools land in DerivedData:
   xcodegen generate && xcodebuild -scheme MacOSAppStarter build

   SPARKLE_BIN=$(find ~/Library/Developer/Xcode/DerivedData -path "*sparkle/Sparkle/bin" -type d | head -1)

   # Generate a fresh keypair scoped to your app (so it doesn't collide with
   # other Sparkle apps in your keychain):
   "$SPARKLE_BIN/generate_keys" --account <your-app-name>
   # Copy the printed SUPublicEDKey value into project.yml's info.properties.

   # Export the private key and set it as the GitHub secret:
   "$SPARKLE_BIN/generate_keys" --account <your-app-name> -x ./private.key
   gh secret set SPARKLE_EDDSA_KEY --repo <owner>/<repo> < ./private.key
   rm ./private.key
   ```

   **SUFeedURL** is already set to `https://raw.githubusercontent.com/<owner>/<repo>/main/appcast.xml`. Change `XueshiQiao/macos-app-starter` to your owner/repo. CI generates `appcast.xml` on every tagged release and commits it back to `main` (with `[skip ci]`) so the raw URL always serves the latest appcast. No GitHub Pages, no separate repo. Until your first release ships, the URL returns 404 — Sparkle reports a clean network error, which is expected.

4. **Aptabase — REPLACE THE KEY.** This template ships with `APTABASE_KEY: A-US-3800930688` so the maintainer can verify analytics flow during development. If you fork without changing it, your users' app-launch events will land in the maintainer's dashboard, not yours. Get a free key at aptabase.com and update `APTABASE_KEY` in `project.yml`. Set to empty string to disable analytics entirely.

5. **Homebrew Cask**. The cask in `Casks/` is a draft. Move it to a tap repo (see `macos-app-scaffold` skill docs for tap topology choices) before publishing.

## Development

See [AGENTS.md](AGENTS.md) for full conventions.

## License

[MIT](LICENSE)
