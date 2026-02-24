import XCTest
@testable import TravelJournalUI
@testable import TravelJournalCore

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
}
