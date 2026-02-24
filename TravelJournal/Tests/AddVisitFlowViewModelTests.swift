import XCTest
@testable import TravelJournalUI
@testable import TravelJournalCore
@testable import TravelJournalData
@testable import TravelJournalDomain

@MainActor
final class AddVisitFlowViewModelTests: XCTestCase {
    func testStepNavigationBounds() {
        let viewModel = AddVisitFlowViewModel()

        XCTAssertEqual(viewModel.currentStep, .location)
        XCTAssertFalse(viewModel.canGoBack)

        viewModel.goBack()
        XCTAssertEqual(viewModel.currentStep, .location)

        viewModel.goNext()
        XCTAssertEqual(viewModel.currentStep, .dates)
        XCTAssertTrue(viewModel.canGoBack)

        viewModel.goNext()
        XCTAssertEqual(viewModel.currentStep, .content)
        XCTAssertTrue(viewModel.isLastStep)

        viewModel.goNext()
        XCTAssertEqual(viewModel.currentStep, .content)
    }

    func testDraftUpdates() {
        let viewModel = AddVisitFlowViewModel()
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let end = Date(timeIntervalSince1970: 1_700_086_400)

        viewModel.updateLocationQuery("Tokyo")
        viewModel.updateDates(start: start, end: end)
        viewModel.updateContent(note: "Sakura everywhere", photoItemCount: 12)
        viewModel.updateSelectedMediaPayloads([
            MediaImportPayload(localIdentifier: "asset-1", fileURL: nil, width: 1000, height: 800),
            MediaImportPayload(localIdentifier: "asset-2", fileURL: nil, width: 1200, height: 900)
        ])

        XCTAssertEqual(viewModel.draft.locationQuery, "Tokyo")
        XCTAssertEqual(viewModel.draft.startDate, start)
        XCTAssertEqual(viewModel.draft.endDate, end)
        XCTAssertEqual(viewModel.draft.note, "Sakura everywhere")
        XCTAssertEqual(viewModel.draft.photoItemCount, 2)
        XCTAssertEqual(viewModel.draft.mediaImportPayloads.count, 2)
    }

    func testUseCurrentLocationUpdatesDraftQuery() async {
        let provider = SuccessfulCurrentLocationProvider(
            resolvedLocation: AddVisitResolvedLocation(
                displayName: "Lisbon",
                country: "Portugal",
                latitude: 38.7223,
                longitude: -9.1393
            )
        )

        let viewModel = AddVisitFlowViewModel(locationProvider: provider)
        await viewModel.useCurrentLocation()

        XCTAssertEqual(viewModel.draft.locationQuery, "Lisbon")
        XCTAssertNil(viewModel.errorBanner)
        XCTAssertFalse(viewModel.isResolvingCurrentLocation)
    }

    func testUseCurrentLocationFailureMapsBanner() async {
        let viewModel = AddVisitFlowViewModel(locationProvider: FailingCurrentLocationProvider())

        await viewModel.useCurrentLocation()

        XCTAssertEqual(
            viewModel.errorBanner,
            ErrorPresentationMapper.banner(for: .invalidInput(message: "Location permission denied."))
        )
        XCTAssertFalse(viewModel.isResolvingCurrentLocation)
    }

    func testSaveVisitSuccessTriggersSuccessHaptic() {
        let engine = RecordingHapticsEngine()
        let viewModel = AddVisitFlowViewModel(
            draft: AddVisitDraft(locationQuery: "Lisbon"),
            placeRepository: InMemoryPlaceRepository(),
            visitRepository: InMemoryVisitRepository(),
            hapticsClient: HapticsClient(engine: engine)
        )

        _ = viewModel.saveVisit()

        XCTAssertEqual(engine.events, [.success])
    }

    func testSaveVisitValidationFailureTriggersWarningHaptic() {
        let engine = RecordingHapticsEngine()
        let viewModel = AddVisitFlowViewModel(
            draft: AddVisitDraft(locationQuery: "   "),
            hapticsClient: HapticsClient(engine: engine)
        )

        _ = viewModel.saveVisit()

        XCTAssertEqual(engine.events, [.warning])
    }

    func testSaveVisitPersistenceFailureTriggersErrorHaptic() {
        let engine = RecordingHapticsEngine()
        let viewModel = AddVisitFlowViewModel(
            draft: AddVisitDraft(locationQuery: "Rome"),
            placeRepository: FailingPlaceRepository(),
            visitRepository: InMemoryVisitRepository(),
            hapticsClient: HapticsClient(engine: engine)
        )

        _ = viewModel.saveVisit()

        XCTAssertEqual(engine.events, [.error])
    }

    func testSaveVisitPersistsPlaceAndVisit() {
        let placeRepository = InMemoryPlaceRepository()
        let visitRepository = InMemoryVisitRepository()
        let timestamp = Date(timeIntervalSince1970: 1_700_000_111)

        let viewModel = AddVisitFlowViewModel(
            draft: AddVisitDraft(
                locationQuery: "Lisbon",
                startDate: Date(timeIntervalSince1970: 1_700_010_000),
                endDate: Date(timeIntervalSince1970: 1_700_020_000),
                note: "Pastéis every morning"
            ),
            placeRepository: placeRepository,
            visitRepository: visitRepository,
            now: { timestamp }
        )

        let result = viewModel.saveVisit()

        XCTAssertNotNil(result)
        XCTAssertEqual(placeRepository.upsertedPlaces.count, 1)
        XCTAssertEqual(visitRepository.createdVisits.count, 1)
        XCTAssertEqual(result?.place.name, "Lisbon")
        XCTAssertEqual(result?.visit.notes, "Pastéis every morning")
        XCTAssertEqual(result?.visit.placeID, result?.place.id)
        XCTAssertEqual(result?.visit.createdAt, timestamp)
        XCTAssertNil(viewModel.saveError)
        XCTAssertNil(viewModel.errorBanner)
    }

    func testSaveVisitUsesResolvedCurrentLocationCoordinates() async {
        let placeRepository = InMemoryPlaceRepository()
        let visitRepository = InMemoryVisitRepository()
        let viewModel = AddVisitFlowViewModel(
            draft: AddVisitDraft(
                locationQuery: "",
                startDate: Date(timeIntervalSince1970: 1_700_010_000),
                endDate: Date(timeIntervalSince1970: 1_700_020_000),
                note: "Ride tram 28"
            ),
            placeRepository: placeRepository,
            visitRepository: visitRepository,
            locationProvider: SuccessfulCurrentLocationProvider(
                resolvedLocation: AddVisitResolvedLocation(
                    displayName: "Lisbon",
                    country: "Portugal",
                    latitude: 38.7223,
                    longitude: -9.1393
                )
            )
        )

        await viewModel.useCurrentLocation()
        _ = viewModel.saveVisit()

        XCTAssertEqual(placeRepository.upsertedPlaces.first?.name, "Lisbon")
        XCTAssertEqual(placeRepository.upsertedPlaces.first?.country, "Portugal")
        XCTAssertEqual(placeRepository.upsertedPlaces.first?.latitude, 38.7223)
        XCTAssertEqual(placeRepository.upsertedPlaces.first?.longitude, -9.1393)
    }

    func testSaveVisitImportsSelectedMediaPayloads() {
        let placeRepository = InMemoryPlaceRepository()
        let visitRepository = InMemoryVisitRepository()
        let mediaRepository = InMemoryMediaRepository()
        let timestamp = Date(timeIntervalSince1970: 1_700_001_000)

        let viewModel = AddVisitFlowViewModel(
            draft: AddVisitDraft(
                locationQuery: "Osaka",
                startDate: Date(timeIntervalSince1970: 1_700_010_000),
                endDate: Date(timeIntervalSince1970: 1_700_020_000),
                note: "Food crawl",
                mediaImportPayloads: [
                    MediaImportPayload(localIdentifier: "ph://1", fileURL: nil, width: 3024, height: 4032),
                    MediaImportPayload(localIdentifier: nil, fileURL: "file:///tmp/demo.jpg", width: 1600, height: 900)
                ]
            ),
            placeRepository: placeRepository,
            visitRepository: visitRepository,
            mediaRepository: mediaRepository,
            now: { timestamp }
        )

        let result = viewModel.saveVisit()

        XCTAssertNotNil(result)
        XCTAssertEqual(mediaRepository.importedPayloads.count, 2)
        XCTAssertEqual(mediaRepository.importedVisitIDs, [result?.visit.id, result?.visit.id])
        XCTAssertNil(viewModel.saveError)
        XCTAssertNil(viewModel.errorBanner)
    }

    func testSaveVisitValidationErrors() {
        let viewModel = AddVisitFlowViewModel(
            draft: AddVisitDraft(locationQuery: "   ")
        )

        XCTAssertNil(viewModel.saveVisit())
        XCTAssertEqual(viewModel.saveError, .missingLocation)
        XCTAssertEqual(
            viewModel.errorBanner,
            ErrorPresentationMapper.banner(for: .invalidInput(message: AddVisitFlowViewModel.SaveError.missingLocation.errorDescription ?? "Please enter a location before saving."))
        )

        let invalidDates = AddVisitFlowViewModel(
            draft: AddVisitDraft(
                locationQuery: "Paris",
                startDate: Date(timeIntervalSince1970: 500),
                endDate: Date(timeIntervalSince1970: 100)
            )
        )

        XCTAssertNil(invalidDates.saveVisit())
        XCTAssertEqual(invalidDates.saveError, .invalidDateRange)
        XCTAssertEqual(
            invalidDates.errorBanner,
            ErrorPresentationMapper.banner(for: .invalidInput(message: AddVisitFlowViewModel.SaveError.invalidDateRange.errorDescription ?? "End date must be on or after start date."))
        )
    }

    func testSaveVisitPersistenceFailureMapsDatabaseBanner() {
        let viewModel = AddVisitFlowViewModel(
            draft: AddVisitDraft(locationQuery: "Rome"),
            placeRepository: FailingPlaceRepository(),
            visitRepository: InMemoryVisitRepository()
        )

        XCTAssertNil(viewModel.saveVisit())
        XCTAssertEqual(viewModel.saveError, .persistenceFailed)
        XCTAssertEqual(viewModel.errorBanner, ErrorPresentationMapper.banner(for: .databaseFailure))
    }

    func testSaveVisitMediaImportFailureMapsDatabaseBanner() {
        let viewModel = AddVisitFlowViewModel(
            draft: AddVisitDraft(
                locationQuery: "Seoul",
                mediaImportPayloads: [MediaImportPayload(localIdentifier: "ph://broken", fileURL: nil, width: 100, height: 100)]
            ),
            placeRepository: InMemoryPlaceRepository(),
            visitRepository: InMemoryVisitRepository(),
            mediaRepository: FailingMediaRepository()
        )

        XCTAssertNil(viewModel.saveVisit())
        XCTAssertEqual(viewModel.saveError, .persistenceFailed)
        XCTAssertEqual(viewModel.errorBanner, ErrorPresentationMapper.banner(for: .databaseFailure))
    }
}

private final class InMemoryPlaceRepository: PlaceRepository {
    private(set) var upsertedPlaces: [Place] = []

    func upsertPlace(_ place: Place) throws {
        upsertedPlaces.append(place)
    }

    func fetchPlacesWithVisitCounts() throws -> [(place: Place, visitCount: Int)] {
        upsertedPlaces.map { ($0, 0) }
    }

    func fetchPlace(id: UUID) throws -> Place? {
        upsertedPlaces.first { $0.id == id }
    }
}

private final class FailingPlaceRepository: PlaceRepository {
    func upsertPlace(_ place: Place) throws {
        throw NSError(domain: "AddVisitFlowViewModelTests", code: 1)
    }

    func fetchPlacesWithVisitCounts() throws -> [(place: Place, visitCount: Int)] {
        []
    }

    func fetchPlace(id: UUID) throws -> Place? {
        nil
    }
}

private final class InMemoryVisitRepository: VisitRepository {
    private(set) var createdVisits: [Visit] = []

    func createVisit(_ visit: Visit) throws {
        createdVisits.append(visit)
    }

    func updateVisit(_ visit: Visit) throws {}

    func deleteVisit(id: UUID) throws {}

    func fetchVisits(forPlace placeID: UUID) throws -> [Visit] {
        createdVisits.filter { $0.placeID == placeID }
    }

    func fetchVisits(forTrip tripID: UUID) throws -> [Visit] {
        []
    }
}

private final class InMemoryMediaRepository: MediaRepository {
    private(set) var importedPayloads: [MediaImportPayload] = []
    private(set) var importedVisitIDs: [UUID] = []

    func addMedia(_ media: Media) throws {}

    @discardableResult
    func importMedia(from payload: MediaImportPayload, forVisit visitID: UUID, importedAt: Date) throws -> Media {
        importedPayloads.append(payload)
        importedVisitIDs.append(visitID)
        return Media(
            id: UUID(),
            visitID: visitID,
            localIdentifier: payload.localIdentifier,
            fileURL: payload.fileURL,
            width: payload.width,
            height: payload.height,
            createdAt: importedAt,
            updatedAt: importedAt
        )
    }

    func updateMedia(_ media: Media) throws {}

    func deleteMedia(id: UUID) throws {}

    func fetchMedia(forVisit visitID: UUID) throws -> [Media] { [] }

    func fetchMedia(id: UUID) throws -> Media? { nil }
}

private struct SuccessfulCurrentLocationProvider: AddVisitCurrentLocationProviding {
    let resolvedLocation: AddVisitResolvedLocation

    func resolveCurrentLocation() async throws -> AddVisitResolvedLocation {
        resolvedLocation
    }
}

private struct FailingCurrentLocationProvider: AddVisitCurrentLocationProviding {
    func resolveCurrentLocation() async throws -> AddVisitResolvedLocation {
        throw NSError(domain: "AddVisitFlowViewModelTests", code: 42, userInfo: [NSLocalizedDescriptionKey: "Location permission denied."])
    }
}

private final class FailingMediaRepository: MediaRepository {
    func addMedia(_ media: Media) throws {}

    @discardableResult
    func importMedia(from payload: MediaImportPayload, forVisit visitID: UUID, importedAt: Date) throws -> Media {
        throw NSError(domain: "AddVisitFlowViewModelTests", code: 2)
    }

    func updateMedia(_ media: Media) throws {}

    func deleteMedia(id: UUID) throws {}

    func fetchMedia(forVisit visitID: UUID) throws -> [Media] { [] }

    func fetchMedia(id: UUID) throws -> Media? { nil }
}

private final class RecordingHapticsEngine: HapticsEngine {
    private(set) var events: [HapticEvent] = []

    func trigger(_ event: HapticEvent) {
        events.append(event)
    }
}
