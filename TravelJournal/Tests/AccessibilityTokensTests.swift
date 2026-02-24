import XCTest
@testable import TravelJournalCore

final class AccessibilityTokensTests: XCTestCase {
    func testAccessibilityIdentifiersAreStableAndNonEmpty() {
        XCTAssertFalse(TJAccessibility.Identifier.homeSearchField.isEmpty)
        XCTAssertTrue(TJAccessibility.Identifier.homeFilterChipPrefix.hasPrefix("home.filter.chip"))
        XCTAssertFalse(TJAccessibility.Identifier.homeErrorBanner.isEmpty)
        XCTAssertFalse(TJAccessibility.Identifier.homePinsListButton.isEmpty)
        XCTAssertTrue(TJAccessibility.Identifier.homePinsListRowPrefix.hasPrefix("home.pins.list.row"))
        XCTAssertFalse(TJAccessibility.Identifier.homeSettingsButton.isEmpty)
        XCTAssertFalse(TJAccessibility.Identifier.homeTripsButton.isEmpty)
        XCTAssertFalse(TJAccessibility.Identifier.homeAddVisitButton.isEmpty)
        XCTAssertTrue(TJAccessibility.Identifier.homeSearchResultRowPrefix.hasPrefix("home.search.result.row"))
        XCTAssertFalse(TJAccessibility.Identifier.visitSummarySection.isEmpty)
        XCTAssertFalse(TJAccessibility.Identifier.visitRecommendationsSection.isEmpty)
    }

    func testDynamicFilterChipLabelReflectsSelectionState() {
        XCTAssertEqual(TJAccessibility.Label.filterChip("Tag", isSelected: false), "Tag filter")
        XCTAssertEqual(TJAccessibility.Label.filterChip("Tag", isSelected: true), "Tag filter selected")
    }

    func testPinListAccessibilityLabelsArePredictable() {
        XCTAssertEqual(TJAccessibility.Label.homePinsListButton, "Open list of visible pins")
        XCTAssertEqual(TJAccessibility.Label.pinListRow("Tokyo"), "Select place Tokyo")
    }

    func testBottomActionButtonLabelsArePredictable() {
        XCTAssertEqual(TJAccessibility.Label.homeSettingsButton, "Open settings")
        XCTAssertEqual(TJAccessibility.Label.homeTripsButton, "Open trips list")
        XCTAssertEqual(TJAccessibility.Label.homeAddVisitButton, "Add a new visit")
    }
}
