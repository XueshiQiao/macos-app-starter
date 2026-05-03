import Foundation
import ServiceManagement

@MainActor
final class LaunchAtLoginManager: ObservableObject {
    static let shared = LaunchAtLoginManager()

    @Published private(set) var isEnabled: Bool

    private init() {
        self.isEnabled = SMAppService.mainApp.status == .enabled
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
            isEnabled = SMAppService.mainApp.status == .enabled
            FileLog.shared.info("LaunchAtLogin set to \(isEnabled)")
        } catch {
            FileLog.shared.error("LaunchAtLogin failed: \(error.localizedDescription)")
        }
    }
}
