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

    func testSelectTagFiltersPinsDeterministically() {
        let pins = [
            GlobePin(id: "paris", latitude: 48.8566, longitude: 2.3522),
            GlobePin(id: "tokyo", latitude: 35.6764, longitude: 139.65),
            GlobePin(id: "lisbon", latitude: 38.7223, longitude: -9.1393)
        ]
        let viewModel = HomeViewModel(
            pins: pins,
            placeIDsByTagID: [
                "food": ["tokyo", "lisbon"]
            ]
        )

        viewModel.selectTag("food")
        XCTAssertEqual(viewModel.visiblePins.map(\.id), ["tokyo", "lisbon"])

        viewModel.selectTag(nil)
        XCTAssertEqual(viewModel.visiblePins.map(\.id), ["paris", "tokyo", "lisbon"])
    }
}
