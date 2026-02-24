import XCTest
@testable import TravelJournalData
@testable import TravelJournalDomain
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

    func testCanManageSpotsIsFalseWithoutEditor() {
        let viewModel = VisitDetailViewModel(
            title: "Lisbon Weekend",
            dateRangeText: "Jun 07 - Jun 09",
            summary: nil,
            notes: nil,
            photoCount: 0,
            spots: [],
            recommendations: []
        )

        viewModel.presentSpotsEditor()

        XCTAssertFalse(viewModel.canManageSpots)
        XCTAssertFalse(viewModel.isSpotsEditorPresented)
    }

    func testPresentAndRefreshSpotsFromEditor() {
        let repository = InMemorySpotRepository()
        let visitID = UUID()
        let editor = VisitSpotsEditorViewModel(visitID: visitID, repository: repository)
        let viewModel = VisitDetailViewModel(
            title: "Rome",
            dateRangeText: "May 01 - May 03",
            summary: nil,
            notes: nil,
            photoCount: 2,
            spots: [],
            recommendations: [],
            spotsEditorViewModel: editor
        )

        editor.addSpot(name: "Roscioli", category: "restaurant", note: "Book ahead")
        viewModel.presentSpotsEditor()
        viewModel.refreshSpotsFromEditor()

        XCTAssertTrue(viewModel.canManageSpots)
        XCTAssertTrue(viewModel.isSpotsEditorPresented)
        XCTAssertEqual(viewModel.spots.count, 1)
        XCTAssertEqual(viewModel.spots.first?.name, "Roscioli")
    }
}

private final class InMemorySpotRepository: SpotRepository {
    private var spotsByVisitID: [UUID: [Spot]] = [:]

    func addSpot(_ spot: Spot) throws {
        var spots = spotsByVisitID[spot.visitID] ?? []
        spots.append(spot)
        spotsByVisitID[spot.visitID] = spots
    }

    func updateSpot(_ spot: Spot) throws {
        guard var spots = spotsByVisitID[spot.visitID],
              let index = spots.firstIndex(where: { $0.id == spot.id }) else { return }
        spots[index] = spot
        spotsByVisitID[spot.visitID] = spots
    }

    func deleteSpot(id: UUID) throws {
        for (visitID, spots) in spotsByVisitID {
            spotsByVisitID[visitID] = spots.filter { $0.id != id }
        }
    }

    func fetchSpots(forVisit visitID: UUID) throws -> [Spot] {
        spotsByVisitID[visitID] ?? []
    }
}
