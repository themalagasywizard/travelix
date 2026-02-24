import XCTest
@testable import TravelJournalCore

final class MotionTokensTests: XCTestCase {
    func testMotionDurationsStayWithinPremiumBounds() {
        for preset in TJMotionPreset.allCases {
            let duration = preset.token.duration
            XCTAssertGreaterThanOrEqual(duration, 0.12)
            XCTAssertLessThanOrEqual(duration, 0.50)
        }
    }

    func testMotionHierarchyIsOrdered() {
        XCTAssertLessThan(TJMotion.quickFade.duration, TJMotion.standardTransition.duration)
        XCTAssertLessThan(TJMotion.standardTransition.duration, TJMotion.emphasizedTransition.duration)
        XCTAssertLessThan(TJMotion.emphasizedTransition.duration, TJMotion.globeFocus.duration)
    }

    func testGlobeFocusUsesSpringCurve() {
        XCTAssertEqual(TJMotion.globeFocus.curve, .spring)
    }
}
