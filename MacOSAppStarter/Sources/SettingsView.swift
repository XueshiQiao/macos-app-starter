import SwiftUI
import KeyboardShortcuts
import ServiceManagement

struct SettingsView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var updater: UpdateManager
    @StateObject private var loginManager = LaunchAtLoginManager.shared
    @AppStorage("settings.analytics.enabled") private var analyticsEnabled: Bool = true

    var body: some View {
        TabView {
            generalTab.tabItem { Label(String(localized: "General"), systemImage: "gear") }
            updatesTab.tabItem { Label(String(localized: "Updates"), systemImage: "arrow.down.circle") }
            shortcutsTab.tabItem { Label(String(localized: "Shortcuts"), systemImage: "keyboard") }
            aboutTab.tabItem { Label(String(localized: "About"), systemImage: "info.circle") }
        }
        .frame(width: 480, height: 320)
        .padding()
    }

    private var generalTab: some View {
        Form {
            Toggle(String(localized: "Launch at Login"),
                   isOn: Binding(
                    get: { loginManager.isEnabled },
                    set: { loginManager.setEnabled($0) }))

            Picker(String(localized: "Language"),
                   selection: $localization.languageCode) {
                Text(String(localized: "Follow System")).tag("")
                Text("English").tag("en")
                Text("简体中文").tag("zh-Hans")
            }

            Toggle(String(localized: "Send anonymous usage statistics"),
                   isOn: $analyticsEnabled)
                .onChange(of: analyticsEnabled) { _, newValue in
                    Analytics.shared.setEnabled(newValue)
                }
        }
        .formStyle(.grouped)
    }

    private var updatesTab: some View {
        Form {
            Toggle(String(localized: "Check for updates automatically"),
                   isOn: Binding(
                    get: { updater.automaticallyChecksForUpdates },
                    set: { updater.automaticallyChecksForUpdates = $0 }))
            Button(String(localized: "Check for Updates Now")) {
                updater.checkForUpdates()
            }
            .disabled(!updater.canCheckForUpdates)
        }
        .formStyle(.grouped)
    }

    private var shortcutsTab: some View {
        Form {
            KeyboardShortcuts.Recorder(String(localized: "Toggle Main Window"),
                                       name: .toggleMainWindow)
        }
        .formStyle(.grouped)
    }

    private var aboutTab: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("MacOSAppStarter").font(.title2.bold())
            Text(AppInfo.versionString).foregroundStyle(.secondary)
            Link(String(localized: "View on GitHub"),
                 destination: URL(string: "https://github.com/XueshiQiao/macos-app-starter")!)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
