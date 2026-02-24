import XCTest
@testable import TravelJournalUI
@testable import TravelJournalCore
@testable import TravelJournalData
@testable import TravelJournalDomain

@MainActor
final class EditVisitViewModelTests: XCTestCase {
    func testApplyEditsUpdatesFields() {
        let originalStart = Date(timeIntervalSince1970: 1_700_000_000)
        let originalEnd = Date(timeIntervalSince1970: 1_700_086_400)
        let vm = EditVisitViewModel(
            visitID: "visit-1",
            locationName: "Paris",
            startDate: originalStart,
            endDate: originalEnd,
            summary: "Initial",
            notes: "Initial notes"
        )

        let newStart = Date(timeIntervalSince1970: 1_701_000_000)
        let newEnd = Date(timeIntervalSince1970: 1_701_086_400)
        vm.applyEdits(
            locationName: "Tokyo",
            startDate: newStart,
            endDate: newEnd,
            summary: "Updated",
            notes: "Updated notes"
        )

        XCTAssertEqual(vm.locationName, "Tokyo")
        XCTAssertEqual(vm.startDate, newStart)
        XCTAssertEqual(vm.endDate, newEnd)
        XCTAssertEqual(vm.summary, "Updated")
        XCTAssertEqual(vm.notes, "Updated notes")
    }

    func testHasValidDateRange() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let earlier = Date(timeIntervalSince1970: 1_699_000_000)

        let vm = EditVisitViewModel(
            visitID: "visit-2",
            locationName: "Lisbon",
            startDate: start,
            endDate: earlier,
            summary: "Bad dates",
            notes: ""
        )

        XCTAssertFalse(vm.hasValidDateRange)
        XCTAssertEqual(
            vm.dateValidationBanner,
            ErrorPresentationMapper.banner(for: .invalidInput(message: "End date must be on or after start date."))
        )

        vm.endDate = start
        XCTAssertTrue(vm.hasValidDateRange)
        XCTAssertNil(vm.dateValidationBanner)
    }

    func testSaveChangesUpdatesVisitThroughRepository() {
        let repository = RecordingVisitRepository()
        let visitID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        let placeID = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
        let createdAt = Date(timeIntervalSince1970: 1_700_000_000)
        let visit = Visit(
            id: visitID,
            placeID: placeID,
            tripID: nil,
            startDate: Date(timeIntervalSince1970: 1_700_000_000),
            endDate: Date(timeIntervalSince1970: 1_700_086_400),
            summary: "Original",
            notes: "Original notes",
            createdAt: createdAt,
            updatedAt: createdAt
        )

        let vm = EditVisitViewModel(visit: visit, locationName: "Paris", repository: repository)
        vm.summary = "Updated"
        vm.notes = ""

        let result = vm.saveChanges()

        XCTAssertTrue(result)
        XCTAssertNil(vm.saveErrorBanner)
        XCTAssertEqual(repository.updatedVisits.count, 1)
        XCTAssertEqual(repository.updatedVisits.first?.id, visitID)
        XCTAssertEqual(repository.updatedVisits.first?.placeID, placeID)
        XCTAssertEqual(repository.updatedVisits.first?.summary, "Updated")
        XCTAssertNil(repository.updatedVisits.first?.notes)
    }

    func testSaveChangesShowsDatabaseBannerWhenRepositoryFails() {
        let repository = RecordingVisitRepository(shouldFailOnUpdate: true)
        let visit = Visit(
            id: UUID(uuidString: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")!,
            placeID: UUID(uuidString: "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb")!,
            tripID: nil,
            startDate: Date(timeIntervalSince1970: 1_700_000_000),
            endDate: Date(timeIntervalSince1970: 1_700_086_400),
            summary: "Original",
            notes: "Original notes",
            createdAt: Date(timeIntervalSince1970: 1_700_000_000),
            updatedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )

        let vm = EditVisitViewModel(visit: visit, locationName: "Paris", repository: repository)

        let result = vm.saveChanges()

        XCTAssertFalse(result)
        XCTAssertEqual(vm.saveErrorBanner, ErrorPresentationMapper.banner(for: .databaseFailure))
    }
}

private final class RecordingVisitRepository: VisitRepository {
    enum RecordingError: Error {
        case forcedFailure
    }

    private(set) var updatedVisits: [Visit] = []
    private let shouldFailOnUpdate: Bool

    init(shouldFailOnUpdate: Bool = false) {
        self.shouldFailOnUpdate = shouldFailOnUpdate
    }

    func createVisit(_ visit: Visit) throws {}

    func updateVisit(_ visit: Visit) throws {
        if shouldFailOnUpdate {
            throw RecordingError.forcedFailure
        }
        updatedVisits.append(visit)
    }

    func deleteVisit(id: UUID) throws {}

    func fetchVisits(forPlace placeID: UUID) throws -> [Visit] { [] }

    func fetchVisits(forTrip tripID: UUID) throws -> [Visit] { [] }
}
