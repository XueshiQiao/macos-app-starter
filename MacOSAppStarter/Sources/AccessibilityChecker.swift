import AppKit
import ApplicationServices

@MainActor
final class AccessibilityChecker: ObservableObject {
    static let shared = AccessibilityChecker()

    @Published private(set) var isTrusted: Bool = false

    private init() {
        refresh()
    }

    func refresh() {
        isTrusted = AXIsProcessTrusted()
    }

    func requestPermission() {
        // Swift 6: kAXTrustedCheckOptionPrompt is a global CFString and can't cross
        // concurrency domains directly. Build the key locally as a String literal.
        let promptKey = "AXTrustedCheckOptionPrompt"
        let opts: CFDictionary = [promptKey: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(opts)
        isTrusted = trusted
        if !trusted {
            // Open System Settings → Privacy & Security → Accessibility as a fallback.
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
        FileLog.shared.info("Accessibility trust=\(trusted)")
    }
}
