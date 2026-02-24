import XCTest
@testable import TravelJournalUI

@MainActor
final class VisitDetailViewModelTests: XCTestCase {
    func testPhotoSectionTitleIncludesCount() {
        let viewModel = VisitDetailViewModel(
            title: "Tokyo Spring",
            dateRangeText: "Apr 01 - Apr 07",
            summary: "Great trip",
            notes: nil,
            photoCount: 12,
            spots: [],
            recommendations: []
        )

        XCTAssertEqual(viewModel.photoSectionTitle, "Photos (12)")
    }

    func testSpotsAndRecommendationsStateInitialization() {
        let viewModel = VisitDetailViewModel(
            title: "Lisbon Weekend",
            dateRangeText: "Jun 07 - Jun 09",
            summary: nil,
            notes: "Lots of walking",
            photoCount: 3,
            spots: [
                .init(id: "s1", name: "Time Out Market", category: "food", ratingText: "4/5", note: "Go early")
            ],
            recommendations: ["Book tram tickets in advance"]
        )

        XCTAssertEqual(viewModel.spots.count, 1)
        XCTAssertEqual(viewModel.recommendations.count, 1)
    }
}
