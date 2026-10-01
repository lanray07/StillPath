import Foundation
import Observation
import XCTest
@testable import StillPath

@MainActor
final class AppStateTests: XCTestCase {
    func testCompletingOnboardingPersistsAndNotifiesObservers() {
        let suiteName = "AppStateTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let state = AppState(defaults: defaults)
        var didObserveChange = false

        withObservationTracking {
            _ = state.hasCompletedOnboarding
        } onChange: {
            didObserveChange = true
        }

        state.hasCompletedOnboarding = true

        XCTAssertTrue(didObserveChange)
        XCTAssertTrue(defaults.bool(forKey: "onboarding.complete"))
        XCTAssertTrue(AppState(defaults: defaults).hasCompletedOnboarding)
    }
}
