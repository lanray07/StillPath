import XCTest
@testable import StillPath

final class PremiumPurchaseLayoutTests: XCTestCase {
    func testPurchaseContentIsInsetFromRoundedButtonEdge() {
        XCTAssertGreaterThanOrEqual(PremiumPurchaseLayout.horizontalInset, 20)
    }

    func testPurchaseControlMeetsMinimumTapTarget() {
        XCTAssertGreaterThanOrEqual(PremiumPurchaseLayout.minimumTapHeight, 44)
    }
}
