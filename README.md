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

3. **Sparkle**. Generate ed25519 keys with Sparkle's `generate_keys` tool (built when you build the project — it's in `~/Library/Developer/Xcode/DerivedData/.../SourcePackages/artifacts/sparkle/Sparkle/bin/`). Put the public key in Info.plist as `SUPublicEDKey`. Add the private key to GitHub secrets as `SPARKLE_ED_PRIVATE_KEY`. Set `SUFeedURL` to your appcast URL.

4. **Aptabase** (optional). Create a free project at aptabase.com, put the key in Info.plist as `APTABASE_KEY`. Without it, analytics calls are no-ops.

5. **Homebrew Cask**. The cask in `Casks/` is a draft. Move it to a tap repo (see `macos-app-scaffold` skill docs for tap topology choices) before publishing.

## Development

See [AGENTS.md](AGENTS.md) for full conventions.

## License

[MIT](LICENSE)
