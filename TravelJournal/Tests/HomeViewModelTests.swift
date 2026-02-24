import XCTest
@testable import TravelJournalUI
@testable import TravelJournalCore
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

    func testHandlePinSelectedTriggersSelectionHaptic() {
        let engine = RecordingHapticsEngine()
        let viewModel = HomeViewModel(hapticsClient: HapticsClient(engine: engine))

        viewModel.handlePinSelected("paris")

        XCTAssertEqual(engine.events, [.selection])
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

    func testSearchTextFiltersVisiblePinsByPinIdentifier() {
        let pins = [
            GlobePin(id: "paris", latitude: 48.8566, longitude: 2.3522),
            GlobePin(id: "tokyo", latitude: 35.6764, longitude: 139.65),
            GlobePin(id: "lisbon", latitude: 38.7223, longitude: -9.1393)
        ]
        let viewModel = HomeViewModel(pins: pins)

        viewModel.searchText = "to"

        XCTAssertEqual(viewModel.visiblePins.map(\.id), ["tokyo"])
    }

    func testSearchTextMatchesPinMetadataTitleAndSubtitle() {
        let pins = [
            GlobePin(id: "pin-a", latitude: 35.6764, longitude: 139.65),
            GlobePin(id: "pin-b", latitude: 48.8566, longitude: 2.3522)
        ]
        let viewModel = HomeViewModel(
            pins: pins,
            placeSearchMetadataByPinID: [
                "pin-a": .init(title: "Tokyo", subtitle: "Japan"),
                "pin-b": .init(title: "Paris", subtitle: "France")
            ]
        )

        viewModel.searchText = "japan"
        XCTAssertEqual(viewModel.visiblePins.map(\.id), ["pin-a"])

        viewModel.searchText = "pari"
        XCTAssertEqual(viewModel.visiblePins.map(\.id), ["pin-b"])
    }

    func testSearchTextCombinesWithActiveFilters() {
        let pins = [
            GlobePin(id: "paris", latitude: 48.8566, longitude: 2.3522),
            GlobePin(id: "tokyo", latitude: 35.6764, longitude: 139.65),
            GlobePin(id: "lisbon", latitude: 38.7223, longitude: -9.1393)
        ]
        let viewModel = HomeViewModel(
            pins: pins,
            placeIDsByTagID: ["food": ["tokyo", "lisbon"]]
        )

        viewModel.selectTag("food")
        viewModel.searchText = "lis"

        XCTAssertEqual(viewModel.visiblePins.map(\.id), ["lisbon"])
    }

    func testEnablingFilterSeedsDefaultSelectionDeterministically() {
        let viewModel = HomeViewModel(
            pins: [GlobePin(id: "tokyo", latitude: 35.6764, longitude: 139.65)],
            placeIDsByTagID: ["zeta": ["tokyo"], "alpha": ["tokyo"]],
            placeIDsByTripID: ["trip-b": ["tokyo"], "trip-a": ["tokyo"]],
            placeIDsByYear: [2026: ["tokyo"], 2024: ["tokyo"]]
        )

        viewModel.toggleFilter(.tag)
        viewModel.toggleFilter(.trip)
        viewModel.toggleFilter(.year)

        XCTAssertEqual(viewModel.selectedTagID, "alpha")
        XCTAssertEqual(viewModel.selectedTripID, "trip-a")
        XCTAssertEqual(viewModel.selectedYear, 2024)
    }

    func testChipTitleReflectsCurrentSelection() {
        let viewModel = HomeViewModel()

        XCTAssertEqual(viewModel.chipTitle(for: .tag), "Tag")

        viewModel.selectTag("food")
        XCTAssertEqual(viewModel.chipTitle(for: .tag), "Tag: food")
    }

    func testPinListItemsFollowVisiblePinsAndAreSortedByTitle() {
        let pins = [
            GlobePin(id: "tokyo", latitude: 35.6764, longitude: 139.65),
            GlobePin(id: "paris", latitude: 48.8566, longitude: 2.3522),
            GlobePin(id: "lisbon", latitude: 38.7223, longitude: -9.1393)
        ]
        let viewModel = HomeViewModel(pins: pins)

        XCTAssertEqual(viewModel.pinListItems.map(\.title), ["Lisbon", "Paris", "Tokyo"])

        viewModel.searchText = "to"
        XCTAssertEqual(viewModel.pinListItems.map(\.id), ["tokyo"])
    }

    func testPinListItemsPreferMetadataTitles() {
        let pins = [
            GlobePin(id: "pin-1", latitude: 35.6764, longitude: 139.65),
            GlobePin(id: "pin-2", latitude: 48.8566, longitude: 2.3522)
        ]
        let viewModel = HomeViewModel(
            pins: pins,
            placeSearchMetadataByPinID: [
                "pin-1": .init(title: "Tokyo", subtitle: "Japan"),
                "pin-2": .init(title: "Paris", subtitle: "France")
            ]
        )

        XCTAssertEqual(viewModel.pinListItems.map(\.title), ["Paris", "Tokyo"])
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
        XCTAssertNil(viewModel.errorBanner)
    }

    func testSelectedPlaceStoryFailureSetsErrorBannerWhenRepositoryThrows() {
        let placeID = UUID(uuidString: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")!
        let viewModel = HomeViewModel(
            pins: [GlobePin(id: "paris-pin", latitude: 48.8566, longitude: 2.3522)],
            pinIDToPlaceID: ["paris-pin": placeID],
            placeRepository: FailingPlaceRepository(),
            visitRepository: StubVisitRepository(visitsByPlaceID: [:])
        )

        viewModel.handlePinSelected("paris-pin")

        XCTAssertNil(viewModel.selectedPlaceStoryViewModel)
        XCTAssertEqual(viewModel.errorBanner?.title, "Something went wrong")
    }

    func testHandlePinSelectedClearsExistingErrorBanner() {
        let placeID = UUID(uuidString: "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb")!
        let viewModel = HomeViewModel(
            pins: [GlobePin(id: "pin", latitude: 0, longitude: 0)],
            pinIDToPlaceID: ["pin": placeID],
            placeRepository: FailingPlaceRepository(),
            visitRepository: StubVisitRepository(visitsByPlaceID: [:])
        )

        viewModel.handlePinSelected("pin")
        _ = viewModel.selectedPlaceStoryViewModel
        XCTAssertNotNil(viewModel.errorBanner)

        viewModel.handlePinSelected("pin")
        XCTAssertNil(viewModel.errorBanner)
    }

    func testRegisterCreatedVisitAddsPinMetadataAndSelectsIt() {
        let viewModel = HomeViewModel(pins: [])
        let placeID = UUID(uuidString: "cccccccc-cccc-cccc-cccc-cccccccccccc")!
        let visitID = UUID(uuidString: "dddddddd-dddd-dddd-dddd-dddddddddddd")!
        let timestamp = Date(timeIntervalSince1970: 1_700_000_000)
        let place = Place(
            id: placeID,
            name: "Berlin",
            country: "Germany",
            latitude: 52.52,
            longitude: 13.405,
            createdAt: timestamp,
            updatedAt: timestamp
        )
        let visit = Visit(
            id: visitID,
            placeID: placeID,
            tripID: nil,
            startDate: timestamp,
            endDate: timestamp,
            summary: "Berlin Weekend",
            notes: "Museum Island + Mitte cafes",
            createdAt: timestamp,
            updatedAt: timestamp
        )

        viewModel.registerCreatedVisit(.init(place: place, visit: visit))

        XCTAssertEqual(viewModel.pins.count, 1)
        XCTAssertEqual(viewModel.visiblePins.count, 1)
        XCTAssertEqual(viewModel.pinListItems.first?.title, "Berlin")
        XCTAssertEqual(viewModel.selectedPlaceID, placeID.uuidString.lowercased())
    }

    func testSearchTextPopulatesSearchResultsFromRepository() {
        let placeID = UUID(uuidString: "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee")!
        let viewModel = HomeViewModel(
            searchRepository: StubSearchRepository(resultsByQuery: [
                "tokyo": [SearchResult(kind: .place, id: placeID, title: "Tokyo", subtitle: "Japan")]
            ])
        )

        viewModel.searchText = "tokyo"

        XCTAssertEqual(viewModel.searchResults.count, 1)
        XCTAssertEqual(viewModel.searchResults.first?.title, "Tokyo")
    }

    func testSelectingPlaceSearchResultFocusesMappedPin() {
        let placeID = UUID(uuidString: "ffffffff-ffff-ffff-ffff-ffffffffffff")!
        let viewModel = HomeViewModel(
            pins: [GlobePin(id: "tokyo-pin", latitude: 35.6764, longitude: 139.65)],
            pinIDToPlaceID: ["tokyo-pin": placeID]
        )

        viewModel.handleSearchResultSelected(.init(kind: .place, id: placeID, title: "Tokyo", subtitle: "Japan"))

        XCTAssertEqual(viewModel.selectedPlaceID, "tokyo-pin")
        XCTAssertTrue(viewModel.searchResults.isEmpty)
    }

    func testSelectingTripSearchResultAppliesTripFilterAndClearsSearchResults() {
        let tripID = UUID(uuidString: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")!
        let viewModel = HomeViewModel(
            pins: [
                GlobePin(id: "tokyo", latitude: 35.6764, longitude: 139.65),
                GlobePin(id: "paris", latitude: 48.8566, longitude: 2.3522)
            ],
            placeIDsByTripID: [tripID.uuidString.lowercased(): ["tokyo"]]
        )

        viewModel.searchText = "japan"
        viewModel.handleSearchResultSelected(.init(kind: .trip, id: tripID, title: "Japan 2025", subtitle: nil))

        XCTAssertEqual(viewModel.selectedTripID, tripID.uuidString.lowercased())
        XCTAssertTrue(viewModel.selectedFilters.contains(.trip))
        XCTAssertEqual(viewModel.visiblePins.map(\.id), ["tokyo"])
        XCTAssertTrue(viewModel.searchResults.isEmpty)
    }

    func testSelectingTagSearchResultAppliesTagFilterAndClearsSearchResults() {
        let tagID = UUID(uuidString: "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb")!
        let viewModel = HomeViewModel(
            pins: [
                GlobePin(id: "tokyo", latitude: 35.6764, longitude: 139.65),
                GlobePin(id: "paris", latitude: 48.8566, longitude: 2.3522)
            ],
            placeIDsByTagID: [tagID.uuidString.lowercased(): ["paris"]]
        )

        viewModel.searchText = "city"
        viewModel.handleSearchResultSelected(.init(kind: .tag, id: tagID, title: "City", subtitle: nil))

        XCTAssertEqual(viewModel.selectedTagID, tagID.uuidString.lowercased())
        XCTAssertTrue(viewModel.selectedFilters.contains(.tag))
        XCTAssertEqual(viewModel.visiblePins.map(\.id), ["paris"])
        XCTAssertTrue(viewModel.searchResults.isEmpty)
    }

    func testSearchRepositoryFailureSetsErrorBanner() {
        let viewModel = HomeViewModel(searchRepository: FailingSearchRepository())

        viewModel.searchText = "tokyo"

        XCTAssertEqual(viewModel.searchResults, [])
        XCTAssertEqual(viewModel.errorBanner?.title, "Something went wrong")
    }

    func testHandleDeepLinkPlaceSelectsPin() {
        let viewModel = HomeViewModel()

        viewModel.handleDeepLink(.place(id: "TOKYO"))

        XCTAssertEqual(viewModel.selectedPlaceID, "tokyo")
    }

    func testHandleDeepLinkTripAppliesTripFilter() {
        let tripID = "trip-2025"
        let viewModel = HomeViewModel(
            pins: [
                GlobePin(id: "tokyo", latitude: 35.6764, longitude: 139.65),
                GlobePin(id: "paris", latitude: 48.8566, longitude: 2.3522)
            ],
            placeIDsByTripID: [tripID: ["tokyo"]]
        )

        viewModel.handleDeepLink(.trip(id: "TRIP-2025"))

        XCTAssertEqual(viewModel.selectedTripID, tripID)
        XCTAssertEqual(viewModel.visiblePins.map(\.id), ["tokyo"])
    }

    func testHandleDeepLinkVisitStoresPendingVisitIdentifier() {
        let viewModel = HomeViewModel()

        viewModel.handleDeepLink(.visit(id: "VISIT-42"))

        XCTAssertEqual(viewModel.consumePendingVisitDeepLinkID(), "visit-42")
        XCTAssertNil(viewModel.consumePendingVisitDeepLinkID())
    }

    func testMakeTripsListViewModelReturnsRepositoryBackedViewModelWhenDependenciesExist() throws {
        let viewModel = HomeViewModel(
            tripRepository: StubTripRepository(trips: []),
            visitRepository: StubVisitRepository(visitsByPlaceID: [:])
        )

        let tripsViewModel = try viewModel.makeTripsListViewModel()

        XCTAssertNotNil(tripsViewModel)
    }

    func testMakeTripsListViewModelThrowsWithoutTripRepository() {
        let viewModel = HomeViewModel(visitRepository: StubVisitRepository(visitsByPlaceID: [:]))

        XCTAssertThrowsError(try viewModel.makeTripsListViewModel()) { error in
            XCTAssertEqual(error as? TJAppError, .invalidInput(message: "Trips are unavailable until repositories are connected."))
        }
    }

    func testHandleTripsUnavailableSetsInvalidInputBanner() {
        let viewModel = HomeViewModel()

        viewModel.handleTripsUnavailable()

        XCTAssertEqual(viewModel.errorBanner?.title, "Check your input")
        XCTAssertEqual(viewModel.errorBanner?.message, "Trips are unavailable until repositories are connected.")
    }

    func testMakeAddVisitFlowViewModelForwardsMediaRepositoryForSaveFlow() {
        let placeRepository = StubPlaceRepository(placeByID: [:])
        let visitRepository = StubVisitRepository(visitsByPlaceID: [:])
        let mediaRepository = RecordingMediaRepository(mediaByVisitID: [:])
        let timestamp = Date(timeIntervalSince1970: 1_700_000_123)

        let homeViewModel = HomeViewModel(
            placeRepository: placeRepository,
            visitRepository: visitRepository,
            mediaRepository: mediaRepository
        )

        let addVisitViewModel = homeViewModel.makeAddVisitFlowViewModel(now: { timestamp })
        addVisitViewModel.updateLocationQuery("Kyoto")
        addVisitViewModel.updateSelectedMediaPayloads([
            MediaImportPayload(localIdentifier: "ph://asset-1", fileURL: nil, width: nil, height: nil)
        ])

        let result = addVisitViewModel.saveVisit()

        XCTAssertNotNil(result)
        XCTAssertEqual(mediaRepository.importedPayloads.count, 1)
        XCTAssertEqual(mediaRepository.importedPayloads.first?.localIdentifier, "ph://asset-1")
    }
}

private struct FailingPlaceRepository: PlaceRepository {
    struct FailingError: Error {}

    func upsertPlace(_ place: Place) throws {
        throw FailingError()
    }

    func fetchPlacesWithVisitCounts() throws -> [(place: Place, visitCount: Int)] {
        throw FailingError()
    }

    func fetchPlace(id: UUID) throws -> Place? {
        throw FailingError()
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

private struct StubTripRepository: TripRepository {
    let trips: [Trip]

    func createTrip(_ trip: Trip) throws {}

    func updateTrip(_ trip: Trip) throws {}

    func fetchTrips() throws -> [Trip] {
        trips
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

private struct StubSearchRepository: SearchRepository {
    let resultsByQuery: [String: [SearchResult]]

    func search(_ query: String, limit: Int) throws -> [SearchResult] {
        Array((resultsByQuery[query] ?? []).prefix(limit))
    }
}

private struct FailingSearchRepository: SearchRepository {
    struct SearchFailure: Error {}

    func search(_ query: String, limit: Int) throws -> [SearchResult] {
        throw SearchFailure()
    }
}

private final class RecordingMediaRepository: MediaRepository {
    let mediaByVisitID: [UUID: [Media]]
    private(set) var importedPayloads: [MediaImportPayload] = []

    init(mediaByVisitID: [UUID: [Media]]) {
        self.mediaByVisitID = mediaByVisitID
    }

    func addMedia(_ media: Media) throws {}

    func importMedia(from payload: MediaImportPayload, forVisit visitID: UUID, importedAt: Date) throws -> Media {
        importedPayloads.append(payload)
        return Media(id: UUID(), visitID: visitID, localIdentifier: payload.localIdentifier, fileURL: payload.fileURL, width: payload.width, height: payload.height, createdAt: importedAt, updatedAt: importedAt)
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

private final class RecordingHapticsEngine: HapticsEngine {
    private(set) var events: [HapticEvent] = []

    func trigger(_ event: HapticEvent) {
        events.append(event)
    }
}
