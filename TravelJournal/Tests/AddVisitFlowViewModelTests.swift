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

        XCTAssertEqual(viewModel.draft.locationQuery, "Tokyo")
        XCTAssertEqual(viewModel.draft.startDate, start)
        XCTAssertEqual(viewModel.draft.endDate, end)
        XCTAssertEqual(viewModel.draft.note, "Sakura everywhere")
        XCTAssertEqual(viewModel.draft.photoItemCount, 12)
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
