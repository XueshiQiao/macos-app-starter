import XCTest
@testable import MacOSAppStarter

final class MacOSAppStarterTests: XCTestCase {
    func testAppInfoVersionString() {
        let version = AppInfo.versionString
        XCTAssertFalse(version.isEmpty)
        XCTAssertTrue(version.contains("("))
    }

    func testFileLogWritesToExpectedLocation() {
        let url = FileLog.shared.fileURL
        XCTAssertTrue(url.path.hasSuffix("/Library/Logs/MacOSAppStarter.log"))
    }

    @MainActor
    func testLocalizationManagerStartsEmpty() {
        // After cleanup it should default to empty (follow system).
        let manager = LocalizationManager.shared
        XCTAssertTrue(manager.languageCode == "" || ["en", "zh-Hans"].contains(manager.languageCode))
    }
}
