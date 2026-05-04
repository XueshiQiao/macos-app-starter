import AppKit
import SwiftUI
import KeyboardShortcuts

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        registerHotkey()
        AccessibilityChecker.shared.refresh()
        if !UserDefaults.standard.bool(forKey: "onboarding.completed") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.showOnboarding()
            }
        }
    }

    private func registerHotkey() {
        KeyboardShortcuts.onKeyUp(for: .toggleMainWindow) {
            NSApp.activate(ignoringOtherApps: true)
            // SwiftUI WindowGroup windows survive close as hidden — show whichever
            // looks like a main window. NSPanel and popover-style windows are skipped.
            for window in NSApp.windows {
                guard !(window is NSPanel),
                      !window.className.contains("Popover"),
                      !window.title.lowercased().contains("settings"),
                      !window.title.lowercased().contains("preferences"),
                      !window.title.lowercased().contains("welcome") else { continue }
                window.makeKeyAndOrderFront(nil)
                return
            }
            // No candidate window — unhide the app, which restores hidden WindowGroup windows.
            NSApp.unhide(nil)
        }
    }

    private func showOnboarding() {
        let host = NSHostingController(rootView: OnboardingView()
            .environmentObject(LocalizationManager.shared))
        let window = NSWindow(contentViewController: host)
        window.title = String(localized: "Welcome to MacOSAppStarter")
        window.styleMask = [.titled, .closable]
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

extension KeyboardShortcuts.Name {
    static let toggleMainWindow = Self("toggleMainWindow",
                                       default: .init(.s, modifiers: [.command, .option, .control]))
}
