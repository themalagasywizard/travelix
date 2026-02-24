import XCTest
@testable import TravelJournalUI
@testable import TravelJournalData
@testable import TravelJournalDomain

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

    func testMultipleFilterChipsIntersectVisiblePins() {
        let pins = [
            GlobePin(id: "paris", latitude: 48.8566, longitude: 2.3522),
            GlobePin(id: "tokyo", latitude: 35.6764, longitude: 139.65),
            GlobePin(id: "lisbon", latitude: 38.7223, longitude: -9.1393)
        ]
        let viewModel = HomeViewModel(
            pins: pins,
            placeIDsByTagID: ["food": ["tokyo", "lisbon"]],
            placeIDsByTripID: ["japan-2025": ["tokyo"]],
            placeIDsByYear: [2025: ["tokyo", "paris"]]
        )

        viewModel.selectTag("food")
        viewModel.selectTrip("japan-2025")
        viewModel.selectYear(2025)

        XCTAssertEqual(viewModel.visiblePins.map(\.id), ["tokyo"])
    }

    func testDisablingFilterChipClearsItsSelectionAndRelaxesFilter() {
        let pins = [
            GlobePin(id: "paris", latitude: 48.8566, longitude: 2.3522),
            GlobePin(id: "tokyo", latitude: 35.6764, longitude: 139.65),
            GlobePin(id: "lisbon", latitude: 38.7223, longitude: -9.1393)
        ]
        let viewModel = HomeViewModel(
            pins: pins,
            placeIDsByTagID: ["food": ["tokyo", "lisbon"]],
            placeIDsByTripID: ["japan-2025": ["tokyo"]]
        )

        viewModel.selectTag("food")
        viewModel.selectTrip("japan-2025")
        XCTAssertEqual(viewModel.visiblePins.map(\.id), ["tokyo"])

        viewModel.toggleFilter(.trip)

        XCTAssertNil(viewModel.selectedTripID)
        XCTAssertEqual(viewModel.visiblePins.map(\.id), ["tokyo", "lisbon"])
    }

    func testSelectedPlaceStoryUsesRepositoryBackedPlaceAndVisitsWhenAvailable() {
        let placeID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let place = Place(
            id: placeID,
            name: "Tokyo",
            country: "Japan",
            latitude: 35.6764,
            longitude: 139.65,
            createdAt: now,
            updatedAt: now
        )
        let visit = Visit(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            placeID: placeID,
            tripID: nil,
            startDate: now,
            endDate: now.addingTimeInterval(86_400),
            summary: "Autumn Trip",
            notes: "Shibuya and sushi",
            createdAt: now,
            updatedAt: now
        )

        let viewModel = HomeViewModel(
            pins: [GlobePin(id: "tokyo-pin", latitude: 35.6764, longitude: 139.65)],
            pinIDToPlaceID: ["tokyo-pin": placeID],
            placeRepository: StubPlaceRepository(placeByID: [placeID: place]),
            visitRepository: StubVisitRepository(visitsByPlaceID: [placeID: [visit]])
        )

        viewModel.handlePinSelected("tokyo-pin")

        XCTAssertEqual(viewModel.selectedPlaceStoryViewModel?.placeName, "Tokyo")
        XCTAssertEqual(viewModel.selectedPlaceStoryViewModel?.countryName, "Japan")
        XCTAssertEqual(viewModel.selectedPlaceStoryViewModel?.visits.first?.title, "Autumn Trip")
        XCTAssertEqual(viewModel.selectedPlaceStoryViewModel?.visits.first?.summary, "Shibuya and sushi")
    }
}

private struct StubPlaceRepository: PlaceRepository {
    let placeByID: [UUID: Place]

    func upsertPlace(_ place: Place) throws {}

    func fetchPlacesWithVisitCounts() throws -> [(place: Place, visitCount: Int)] {
        []
    }

    func fetchPlace(id: UUID) throws -> Place? {
        placeByID[id]
    }
}

private struct StubVisitRepository: VisitRepository {
    let visitsByPlaceID: [UUID: [Visit]]

    func createVisit(_ visit: Visit) throws {}

    func updateVisit(_ visit: Visit) throws {}

    func deleteVisit(id: UUID) throws {}

    func fetchVisits(forPlace placeID: UUID) throws -> [Visit] {
        visitsByPlaceID[placeID] ?? []
    }

    func fetchVisits(forTrip tripID: UUID) throws -> [Visit] {
        []
    }
}
