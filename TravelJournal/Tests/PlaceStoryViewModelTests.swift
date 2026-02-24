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

    func testSelectingVisitBuildsVisitDetailViewModel() {
        let row = PlaceStoryVisitRow(
            id: "v42",
            title: "Tokyo Food Run",
            dateRangeText: "Apr 01 - Apr 04",
            summary: "Ramen and markets",
            notes: "Book in advance",
            photoCount: 4,
            spots: [
                .init(id: "s1", name: "Sushi Dai", category: "restaurant", ratingText: "5/5", note: "Arrive early")
            ],
            recommendations: ["Go before 7am"]
        )
        let viewModel = PlaceStoryViewModel(
            placeName: "Tokyo",
            countryName: "Japan",
            visits: [row]
        )

        viewModel.selectVisit("v42")

        XCTAssertEqual(viewModel.selectedVisitID, "v42")
        XCTAssertEqual(viewModel.selectedVisitDetailViewModel?.title, "Tokyo Food Run")
        XCTAssertEqual(viewModel.selectedVisitDetailViewModel?.summary, "Ramen and markets")
        XCTAssertEqual(viewModel.selectedVisitDetailViewModel?.notes, "Book in advance")
        XCTAssertEqual(viewModel.selectedVisitDetailViewModel?.photoCount, 4)
        XCTAssertEqual(viewModel.selectedVisitDetailViewModel?.spots.count, 1)
        XCTAssertEqual(viewModel.selectedVisitDetailViewModel?.recommendations, ["Go before 7am"])
    }
}
