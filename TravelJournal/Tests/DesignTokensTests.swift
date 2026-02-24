import XCTest
@testable import TravelJournalCore

final class DesignTokensTests: XCTestCase {
    func testSpacingScaleMatchesDesignSystem() {
        XCTAssertEqual(TJSpacing.x1, 4)
        XCTAssertEqual(TJSpacing.x2, 8)
        XCTAssertEqual(TJSpacing.x3, 12)
        XCTAssertEqual(TJSpacing.x4, 16)
        XCTAssertEqual(TJSpacing.x6, 24)
        XCTAssertEqual(TJSpacing.x8, 32)
    }

    func testTypographyTokensFollowExpectedHierarchy() {
        XCTAssertGreaterThan(TJTypography.largeTitle.size, TJTypography.title2.size)
        XCTAssertGreaterThan(TJTypography.title2.size, TJTypography.body.size)
        XCTAssertGreaterThan(TJTypography.body.size, TJTypography.footnote.size)
        XCTAssertGreaterThanOrEqual(TJTypography.body.lineHeight, TJTypography.body.size)
    }

    func testShadowTokensUseSubtleOpacityRange() {
        XCTAssertEqual(TJShadow.card.opacity, 0.12, accuracy: 0.001)
        XCTAssertEqual(TJShadow.floating.opacity, 0.16, accuracy: 0.001)
        XCTAssertGreaterThan(TJShadow.floating.blur, TJShadow.card.blur)
    }
}
