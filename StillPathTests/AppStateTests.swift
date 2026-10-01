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
        let changeObserved = expectation(description: "Observable state publishes onboarding completion")

        withObservationTracking {
            _ = state.hasCompletedOnboarding
        } onChange: {
            changeObserved.fulfill()
        }

        state.hasCompletedOnboarding = true

        wait(for: [changeObserved], timeout: 1)
        XCTAssertTrue(defaults.bool(forKey: "onboarding.complete"))
        XCTAssertTrue(AppState(defaults: defaults).hasCompletedOnboarding)
    }
}
