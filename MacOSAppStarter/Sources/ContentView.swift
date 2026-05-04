import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var updater: UpdateManager
    @StateObject private var accessibility = AccessibilityChecker.shared
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundStyle(.tint)
                VStack(alignment: .leading, spacing: 2) {
                    Text("MacOSAppStarter")
                        .font(.title2.bold())
                    Text("A scaffold for production macOS apps")
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Divider()

            GroupBox(String(localized: "Status")) {
                VStack(alignment: .leading, spacing: 6) {
                    statusRow(label: String(localized: "Version"),
                              value: AppInfo.versionString)
                    statusRow(label: String(localized: "Bundle ID"),
                              value: AppInfo.bundleID)
                    statusRow(label: String(localized: "Accessibility"),
                              value: accessibility.isTrusted
                                ? String(localized: "Granted")
                                : String(localized: "Not Granted"))
                }
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 8) {
                Button(String(localized: "Open Settings…")) {
                    NSApp.activate(ignoringOtherApps: true)
                    openSettings()
                }
                Button(String(localized: "Check for Updates…")) {
                    updater.checkForUpdates()
                }
                .disabled(!updater.canCheckForUpdates)
                Button(String(localized: "Request Accessibility")) {
                    accessibility.requestPermission()
                }
                .disabled(accessibility.isTrusted)
            }

            Spacer()
        }
        .padding(20)
    }

    private func statusRow(label: String, value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).monospaced()
        }
    }
}

struct MenuBarPopoverView: View {
    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MacOSAppStarter").font(.headline)
            Text("Menu bar quick actions")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            Button(String(localized: "Open Main Window")) {
                (NSApp.delegate as? AppDelegate)?.bringMainWindowForward()
            }
            .buttonStyle(.link)

            Button(String(localized: "Settings…")) {
                (NSApp.delegate as? AppDelegate)?.openSettings()
            }
            .buttonStyle(.link)

            Spacer()

            HStack {
                Spacer()
                Button(String(localized: "Quit")) {
                    NSApp.terminate(nil)
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(width: 320, height: 220, alignment: .topLeading)
    }
}
