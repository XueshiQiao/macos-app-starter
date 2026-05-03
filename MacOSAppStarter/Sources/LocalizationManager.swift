import Foundation
import SwiftUI

@MainActor
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @AppStorage("app.language") var languageCode: String = "" {
        didSet { applyLanguage() }
    }

    private init() {
        applyLanguage()
    }

    private func applyLanguage() {
        if languageCode.isEmpty {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        }
        objectWillChange.send()
    }
}
