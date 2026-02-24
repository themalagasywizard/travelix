import XCTest
@testable import TravelJournalUI

@MainActor
final class HomeViewModelTests: XCTestCase {
    func testToggleFilterAddsAndRemovesSelection() {
        let viewModel = HomeViewModel()

        viewModel.toggleFilter(.year)
        XCTAssertTrue(viewModel.selectedFilters.contains(.year))

        viewModel.toggleFilter(.year)
        XCTAssertFalse(viewModel.selectedFilters.contains(.year))
    }

    func testHandlePinSelectedSetsSelectedPlaceID() {
        let viewModel = HomeViewModel()

        viewModel.handlePinSelected("tokyo")

        XCTAssertEqual(viewModel.selectedPlaceID, "tokyo")
    }

    func testSelectedPlaceStoryViewModelBuiltFromSelection() {
        let viewModel = HomeViewModel()

        viewModel.handlePinSelected("paris")

        XCTAssertEqual(viewModel.selectedPlaceStoryViewModel?.placeName, "Paris")
        XCTAssertEqual(viewModel.selectedPlaceStoryViewModel?.visits.count, 1)
    }
}
