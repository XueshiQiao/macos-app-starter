import SwiftUI
import Sparkle

@main
struct MacOSAppStarterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var updater = UpdateManager.shared

    init() {
        FileLog.shared.info("App started. version=\(AppInfo.versionString)")
        // app_name + bundle_id let us filter the maintainer's own template app
        // (bundle_id == "dev.xueshi.macos-app-starter") apart from forks that
        // forgot to replace APTABASE_KEY in project.yml.
        Analytics.shared.track("app_started", properties: [
            "app_name": AppInfo.displayName,
            "bundle_id": AppInfo.bundleID,
            "version": AppInfo.versionString
        ])
    }

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
                .environmentObject(localization)
                .environmentObject(updater)
                .frame(minWidth: 480, minHeight: 320)
                .id(localization.languageCode)
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(after: .appInfo) {
                Button(String(localized: "Check for Updates…")) {
                    updater.checkForUpdates()
                }
                .disabled(!updater.canCheckForUpdates)
            }
        }

        Settings {
            SettingsView()
                .environmentObject(localization)
                .environmentObject(updater)
                .id(localization.languageCode)
        }
    }
}

enum AppInfo {
    static var versionString: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        return "\(v) (\(b))"
    }

    static var bundleID: String {
        Bundle.main.bundleIdentifier ?? "dev.xueshi.macos-app-starter"
    }

    static var displayName: String {
        // CFBundleDisplayName when set, falling back to CFBundleName, then the
        // executable name. Matches what Finder shows in the app bundle title.
        (Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String)
            ?? (Bundle.main.infoDictionary?["CFBundleName"] as? String)
            ?? "MacOSAppStarter"
    }
}
