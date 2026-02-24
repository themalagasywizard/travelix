import XCTest
@testable import TravelJournalUI

@MainActor
final class PlaceStoryViewModelTests: XCTestCase {
    func testVisitCountTextUsesPluralForm() {
        let viewModel = PlaceStoryViewModel(
            placeName: "Tokyo",
            countryName: "Japan",
            visits: [
                .init(id: "v1", title: "Spring 2025", dateRangeText: "Apr 01 - Apr 06", summary: "Sakura season"),
                .init(id: "v2", title: "Autumn 2025", dateRangeText: "Nov 10 - Nov 14", summary: nil)
            ]
        )

        XCTAssertEqual(viewModel.visitCountText, "2 visits")
    }

    func testApplyUpdatesVisitCountTextSingularForm() {
        let viewModel = PlaceStoryViewModel(
            placeName: "Lisbon",
            countryName: "Portugal",
            visits: []
        )

        viewModel.apply(visits: [
            .init(id: "v1", title: "Weekend", dateRangeText: "Jun 07 - Jun 09", summary: "Pasteis and viewpoints")
        ])

        XCTAssertEqual(viewModel.visitCountText, "1 visit")
        XCTAssertEqual(viewModel.visits.count, 1)
    }
}
