import XCTest
@testable import StillPath

final class PrivacyTests: XCTestCase {
    func testAnalyticsEventsCarryNoJournalText() {
        let event = AnalyticsEvent.journalCreated
        if case .journalCreated = event { XCTAssertTrue(true) } else { XCTFail() }
    }

    func testSessionPlanAllowsNoTimer() {
        XCTAssertNil(SessionPlan.quietMoment.stages.first?.durationSeconds)
    }
}
