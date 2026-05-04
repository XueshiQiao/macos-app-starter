# AGENTS.md

Conventions for AI agents and humans working in this repo.

## Build & run

This project uses **XcodeGen** as the source of truth for build configuration:

```bash
brew install xcodegen
xcodegen generate
open MacOSAppStarter.xcodeproj
```

Cmd+R in Xcode to build and run. Or from the CLI:

```bash
xcodebuild -project MacOSAppStarter.xcodeproj -scheme MacOSAppStarter \
  -configuration Debug build
```

Run tests:
```bash
xcodebuild -project MacOSAppStarter.xcodeproj -scheme MacOSAppStarter \
  -destination 'platform=macOS' test
```

## Tech stack

- **Swift 6.0** with strict concurrency
- **macOS 14+** deployment target
- **SwiftUI + AppKit** hybrid: SwiftUI for window/Settings/views, AppKit for `NSStatusItem` (menu bar) and onboarding window
- **XcodeGen** — `project.yml` is the source of truth; never edit `*.xcodeproj` directly
- **SPM dependencies**: Sparkle (auto-update), KeyboardShortcuts (global hotkeys), Aptabase (privacy-first analytics)

## Architecture

- Single-process app (no XPC helper). Hybrid archetype: menu bar + window.
- `MacOSAppStarterApp.swift` is the entry point. `AppDelegate` installs the `NSStatusItem` and registers the global hotkey.
- All UI code lives in `MacOSAppStarter/Sources/*View.swift`.
- All persistence is `UserDefaults` for simplicity. Structured data should move to GRDB or Core Data when needed.
- File logging at `~/Library/Logs/MacOSAppStarter.log` via `FileLog.shared`. `os.Logger` mirrors to Console.

## Localization

**All UI strings must go through `String(localized:)` (or SwiftUI implicit `Text("...")`).** Never use bare `String` literals for text shown to users. New strings appear automatically in `Localizable.xcstrings` after build (`SWIFT_EMIT_LOC_STRINGS: YES`); translate non-English entries before merging.

Languages: English (base), Simplified Chinese (zh-Hans). Adding a language means: extend `knownRegions` in `project.yml`, add the locale to `Localizable.xcstrings` and `InfoPlist.xcstrings`, add a row in `SettingsView` and `OnboardingView` language pickers.

Display name (`CFBundleDisplayName`) is localized via `InfoPlist.xcstrings` so the app bundle shows the right name in Finder.

## Sandbox

This app is **NOT sandboxed** (`com.apple.security.app-sandbox = false`). Adding sandbox is incompatible with `Accessibility` (`AXIsProcessTrusted`), `CGEventTap`, and other system-level APIs that this scaffold demonstrates. If you don't need those, flip the entitlement and remove the related code.

## Code style

- SwiftLint runs on save (config in `.swiftlint.yml`).
- `force_unwrapping` is opt-in: avoid `!` outside of preview / test code.
- Prefer `@MainActor` annotation on UI-touching classes (LocalizationManager, AppDelegate, etc.) over ad-hoc `DispatchQueue.main.async`.

## CI/CD & secrets

`.github/workflows/build.yml` is two-track: it builds & tests unsigned by default, and signs+notarizes+releases when Apple secrets are present.

Required GitHub secrets for full release flow:
- `MAC_CERTS_P12_BASE64`, `MAC_CERTS_P12_PASSWORD` — Developer ID cert
- `APPLE_ID`, `APPLE_TEAM_ID`, `APP_SPECIFIC_PASSWORD` — notarytool
- `SIGNING_IDENTITY` (optional, defaults to "Developer ID Application")
- `SPARKLE_EDDSA_KEY` — Sparkle's ed25519 private key (full base64-encoded contents of the file `generate_keys` saves). The public half goes in `project.yml` under `info.properties.SUPublicEDKey`. The CI workflow uses this key in `sign_update` to produce the `sparkle:edSignature` attribute in the appcast. Without it, releases ship without an appcast and Check for Updates can't validate any update.
- `HOMEBREW_TAP_TOKEN` — fine-grained PAT to push cask updates to your tap repo (only if you publish via Homebrew)

Tag-triggered releases: `git tag v0.1.0 && git push --tags`.

## Release notes

Releases must include sections for each configured language:
- English (required)
- 简体中文 / Chinese (required when localizing zh-Hans)

`generate_release_notes: true` produces a base; edit before publishing if you want translations.
