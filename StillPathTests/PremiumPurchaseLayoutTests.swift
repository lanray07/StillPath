import XCTest
@testable import StillPath

final class PremiumPurchaseLayoutTests: XCTestCase {
    func testPurchaseContentIsInsetFromRoundedButtonEdge() {
        XCTAssertGreaterThanOrEqual(PremiumPurchaseLayout.horizontalInset, 20)
    }

    func testPurchaseControlMeetsMinimumTapTarget() {
        XCTAssertGreaterThanOrEqual(PremiumPurchaseLayout.minimumTapHeight, 44)
    }

    func testSubscriptionBillingPeriodsAreExplicit() {
        XCTAssertEqual(
            PremiumSubscriptionDisclosure.billingPeriod(for: EntitlementStore.monthlyID),
            "month"
        )
        XCTAssertEqual(
            PremiumSubscriptionDisclosure.billingPeriod(for: EntitlementStore.annualID),
            "year"
        )
    }

    func testAnnualSubscriptionProvidesMonthlyEquivalent() {
        XCTAssertEqual(
            PremiumSubscriptionDisclosure.monthlyEquivalent(
                for: Decimal(string: "39.99")!,
                productID: EntitlementStore.annualID
            ),
            Decimal(string: "3.3325")!
        )
        XCTAssertNil(
            PremiumSubscriptionDisclosure.monthlyEquivalent(
                for: Decimal(string: "4.99")!,
                productID: EntitlementStore.monthlyID
            )
        )
    }

    func testPremiumLegalLinksAreSecureAndFunctionalTargets() {
        XCTAssertEqual(PremiumLegalLinks.privacyURL.scheme, "https")
        XCTAssertEqual(PremiumLegalLinks.privacyURL.host, "lanray07.github.io")
        XCTAssertEqual(PremiumLegalLinks.termsURL.scheme, "https")
        XCTAssertEqual(PremiumLegalLinks.termsURL.host, "www.apple.com")
    }
}
