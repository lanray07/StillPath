import Foundation
import Observation
import XCTest
@testable import StillPath

@MainActor
final class AppStateTests: XCTestCase {
    func testTabTitlesAreResolvedBeforeTheyReachPlatformTabChrome() {
        let titles: [String] = AppTab.allCases.map(\.title)

        XCTAssertEqual(titles.count, AppTab.allCases.count)
        XCTAssertFalse(titles.contains(where: { $0.hasPrefix("tab.") }))
    }

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
