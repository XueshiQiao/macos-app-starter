import AppKit
import SwiftUI
import KeyboardShortcuts

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        installStatusItem()
        registerHotkey()
        AccessibilityChecker.shared.refresh()
        if !UserDefaults.standard.bool(forKey: "onboarding.completed") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.showOnboarding()
            }
        }
    }

    private func installStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "sparkles",
                                   accessibilityDescription: String(localized: "MacOSAppStarter"))
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 220)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: MenuBarPopoverView()
                .environmentObject(LocalizationManager.shared)
        )

        self.statusItem = item
        self.popover = popover
    }

    @objc private func togglePopover(_ sender: NSStatusBarButton) {
        guard let popover, let button = statusItem?.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func registerHotkey() {
        KeyboardShortcuts.onKeyUp(for: .toggleMainWindow) { [weak self] in
            self?.bringMainWindowForward()
        }
    }

    func bringMainWindowForward() {
        popover?.performClose(nil)
        NSApp.activate(ignoringOtherApps: true)
        // SwiftUI WindowGroup windows are hidden, not destroyed, when closed.
        // Show the first non-popover, non-settings window we find.
        for window in NSApp.windows {
            let title = window.title
            let isPopover = window.className.contains("PopoverWindow")
            let isPanel = window is NSPanel
            guard !isPopover, !isPanel,
                  title != String(localized: "Settings"),
                  title != String(localized: "Welcome to MacOSAppStarter") else { continue }
            window.makeKeyAndOrderFront(nil)
            return
        }
        // Fallback: trigger applicationShouldHandleReopen by unhiding.
        NSApp.unhide(nil)
    }

    // Opens the SwiftUI Settings scene. Activation + async dispatch are needed
    // because callers from the menu bar popover lose key window during dismissal,
    // and `showSettingsWindow:` needs the responder chain to be settled first.
    func openSettings() {
        popover?.performClose(nil)
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async {
            // macOS 13+: SwiftUI's Settings scene listens for showSettingsWindow:.
            // Send to nil so it travels the responder chain and reaches NSApp.
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
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
