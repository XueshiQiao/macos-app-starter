import Foundation
import Sparkle

// Sparkle integration via SPUStandardUpdaterController.
//
// Setup checklist before shipping:
// 1. Generate an ed25519 key pair with Sparkle's `generate_keys` tool.
// 2. Put the public half (a base64 string) into Info.plist under SUPublicEDKey.
//    SUPublicEDKey is added in project.yml's INFOPLIST_KEY_*; replace the placeholder.
// 3. Set SUFeedURL in Info.plist (or via INFOPLIST_KEY_SUFeedURL) to the URL of your
//    appcast.xml — typically hosted on GitHub Pages or a CDN.
// 4. Keep the private key (sparkle_private_key) out of the repo. Add it to CI as
//    a secret (SPARKLE_ED_PRIVATE_KEY) and use Sparkle's sign_update tool in your
//    release workflow to sign each DMG.
@MainActor
final class UpdateManager: ObservableObject {
    static let shared = UpdateManager()

    let controller: SPUStandardUpdaterController

    @Published var canCheckForUpdates: Bool = false
    @Published var automaticallyChecksForUpdates: Bool = true {
        didSet {
            controller.updater.automaticallyChecksForUpdates = automaticallyChecksForUpdates
        }
    }

    init() {
        self.controller = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        self.canCheckForUpdates = controller.updater.canCheckForUpdates
        self.automaticallyChecksForUpdates = controller.updater.automaticallyChecksForUpdates
    }

    func refreshCanCheck() {
        canCheckForUpdates = controller.updater.canCheckForUpdates
    }

    func checkForUpdates() {
        controller.checkForUpdates(nil)
    }
}
