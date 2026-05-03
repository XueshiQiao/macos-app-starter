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

    private func bringMainWindowForward() {
        NSApp.activate(ignoringOtherApps: true)
        for window in NSApp.windows where window.identifier?.rawValue.contains("main") == true {
            window.makeKeyAndOrderFront(nil)
            return
        }
        // No window currently — open one.
        if let url = URL(string: "macosappstarter://open") {
            NSWorkspace.shared.open(url)
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
