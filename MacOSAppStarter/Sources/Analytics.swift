import Foundation
import Aptabase

// Privacy-respecting analytics via Aptabase. Set APTABASE_KEY in Info.plist (or
// via INFOPLIST_KEY_APTABASE_KEY in project.yml) to the key from your Aptabase
// project. When the key is empty, this becomes a no-op so the starter still
// builds cleanly.
final class Analytics: @unchecked Sendable {
    static let shared = Analytics()

    private var enabled: Bool
    private var initialized = false

    private init() {
        let userPref = UserDefaults.standard.object(forKey: "settings.analytics.enabled") as? Bool
        self.enabled = userPref ?? true
        configureIfPossible()
    }

    private func configureIfPossible() {
        guard !initialized else { return }
        guard let key = Bundle.main.object(forInfoDictionaryKey: "APTABASE_KEY") as? String,
              !key.isEmpty else {
            FileLog.shared.info("Aptabase key not set; analytics disabled.")
            return
        }
        Aptabase.shared.initialize(appKey: key)
        initialized = true
        FileLog.shared.info("Aptabase initialized (key: \(key.prefix(6))…)")
    }

    func setEnabled(_ value: Bool) {
        enabled = value
        UserDefaults.standard.set(value, forKey: "settings.analytics.enabled")
        FileLog.shared.info("Analytics enabled=\(value)")
    }

    func track(_ event: String, properties: [String: Any]? = nil) {
        guard enabled, initialized else { return }
        if let properties {
            Aptabase.shared.trackEvent(event, with: properties)
        } else {
            Aptabase.shared.trackEvent(event)
        }
    }
}
