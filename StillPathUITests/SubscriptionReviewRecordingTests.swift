import StoreKitTest
import XCTest

final class SubscriptionReviewRecordingTests: XCTestCase {
    @MainActor
    func testShowRequiredSubscriptionInformation() throws {
        guard ProcessInfo.processInfo.environment["RECORD_APP_REVIEW"] == "1" else {
            throw XCTSkip("Runs only while producing the App Review recording.")
        }

        let storeKit = try SKTestSession(configurationFileNamed: "StillPath")
        storeKit.disableDialogs = true
        storeKit.clearTransactions()

        let app = XCUIApplication()
        app.launchArguments = ["-onboarding.complete", "YES"]
        app.launch()

        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 10))
        settingsTab.tap()

        let premiumButton = app.buttons["StillPath Premium"]
        XCTAssertTrue(premiumButton.waitForExistence(timeout: 10))
        premiumButton.tap()

        XCTAssertTrue(app.navigationBars["StillPath Premium"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["£4.99 / month"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.staticTexts["£39.99 / year"].exists)
        sleep(4)

        let paywall = app.scrollViews.firstMatch
        XCTAssertTrue(paywall.exists)
        paywall.swipeUp()

        XCTAssertTrue(app.links["Privacy Policy"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.links["Terms of Use (EULA)"].exists)
        sleep(7)
    }
}
