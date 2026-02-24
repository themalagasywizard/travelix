import XCTest
@testable import TravelJournalCore

final class AccessibilityTokensTests: XCTestCase {
    func testAccessibilityIdentifiersAreStableAndNonEmpty() {
        XCTAssertFalse(TJAccessibility.Identifier.homeSearchField.isEmpty)
        XCTAssertTrue(TJAccessibility.Identifier.homeFilterChipPrefix.hasPrefix("home.filter.chip"))
        XCTAssertFalse(TJAccessibility.Identifier.visitSummarySection.isEmpty)
        XCTAssertFalse(TJAccessibility.Identifier.visitRecommendationsSection.isEmpty)
    }

    func testDynamicFilterChipLabelReflectsSelectionState() {
        XCTAssertEqual(TJAccessibility.Label.filterChip("Tag", isSelected: false), "Tag filter")
        XCTAssertEqual(TJAccessibility.Label.filterChip("Tag", isSelected: true), "Tag filter selected")
    }
}
