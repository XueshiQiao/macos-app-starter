import Foundation
import Sparkle

// Sparkle integration via SPUStandardUpdaterController.
//
// Setup checklist before shipping (see README "Setup before you ship"):
// 1. Regenerate the ed25519 keypair with Sparkle's `generate_keys` — the
//    template's keypair is shared via this repo's secret, so forks MUST
//    replace it.
// 2. Put the public half into project.yml's `info.properties.SUPublicEDKey`.
// 3. SUFeedURL is also in `info.properties` and points at the raw GitHub URL
//    for `appcast.xml` on `main`. CI commits the appcast on every tagged release.
// 4. Add the private key to CI as the `SPARKLE_EDDSA_KEY` repo secret. CI's
//    `sign_update` step uses it to produce sparkle:edSignature for the appcast.
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
