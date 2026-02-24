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
        let visitID = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
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
            id: visitID,
            placeID: placeID,
            tripID: nil,
            startDate: now,
            endDate: now.addingTimeInterval(86_400),
            summary: "Autumn Trip",
            notes: "Book TeamLab early. Try omakase in Ginza.",
            createdAt: now,
            updatedAt: now
        )
        let spot = Spot(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            visitID: visitID,
            name: "Sushi Dai",
            category: "restaurant",
            latitude: nil,
            longitude: nil,
            address: nil,
            rating: 5,
            note: "Queue before opening",
            createdAt: now,
            updatedAt: now
        )

        let viewModel = HomeViewModel(
            pins: [GlobePin(id: "tokyo-pin", latitude: 35.6764, longitude: 139.65)],
            pinIDToPlaceID: ["tokyo-pin": placeID],
            placeRepository: StubPlaceRepository(placeByID: [placeID: place]),
            visitRepository: StubVisitRepository(visitsByPlaceID: [placeID: [visit]]),
            spotRepository: StubSpotRepository(spotsByVisitID: [visitID: [spot]]),
            mediaRepository: StubMediaRepository(mediaByVisitID: [visitID: [
                Media(id: UUID(), visitID: visitID, localIdentifier: "1", fileURL: nil, width: 100, height: 100, createdAt: now, updatedAt: now),
                Media(id: UUID(), visitID: visitID, localIdentifier: "2", fileURL: nil, width: 100, height: 100, createdAt: now, updatedAt: now)
            ]])
        )

        viewModel.handlePinSelected("tokyo-pin")

        let row = viewModel.selectedPlaceStoryViewModel?.visits.first
        XCTAssertEqual(viewModel.selectedPlaceStoryViewModel?.placeName, "Tokyo")
        XCTAssertEqual(viewModel.selectedPlaceStoryViewModel?.countryName, "Japan")
        XCTAssertEqual(row?.title, "Autumn Trip")
        XCTAssertEqual(row?.summary, "Autumn Trip")
        XCTAssertEqual(row?.notes, "Book TeamLab early. Try omakase in Ginza.")
        XCTAssertEqual(row?.photoCount, 2)
        XCTAssertEqual(row?.spots.first?.name, "Sushi Dai")
        XCTAssertEqual(row?.spots.first?.ratingText, "5/5")
        XCTAssertEqual(row?.recommendations, ["Book TeamLab early", "Try omakase in Ginza"])
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

private struct StubSpotRepository: SpotRepository {
    let spotsByVisitID: [UUID: [Spot]]

    func addSpot(_ spot: Spot) throws {}

    func updateSpot(_ spot: Spot) throws {}

    func deleteSpot(id: UUID) throws {}

    func fetchSpots(forVisit visitID: UUID) throws -> [Spot] {
        spotsByVisitID[visitID] ?? []
    }
}

private struct StubMediaRepository: MediaRepository {
    let mediaByVisitID: [UUID: [Media]]

    func addMedia(_ media: Media) throws {}

    func importMedia(from payload: MediaImportPayload, forVisit visitID: UUID, importedAt: Date) throws -> Media {
        Media(id: UUID(), visitID: visitID, localIdentifier: payload.localIdentifier, fileURL: payload.fileURL, width: payload.width, height: payload.height, createdAt: importedAt, updatedAt: importedAt)
    }

    func updateMedia(_ media: Media) throws {}

    func deleteMedia(id: UUID) throws {}

    func fetchMedia(forVisit visitID: UUID) throws -> [Media] {
        mediaByVisitID[visitID] ?? []
    }

    func fetchMedia(id: UUID) throws -> Media? {
        mediaByVisitID.values.flatMap { $0 }.first(where: { $0.id == id })
    }
}
