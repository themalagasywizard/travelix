import XCTest
@testable import TravelJournalCore

final class LocalizationStringsTests: XCTestCase {
    func testHomeStringsAreNonEmpty() {
        XCTAssertFalse(TJStrings.Home.searchPlaceholder.isEmpty)
        XCTAssertFalse(TJStrings.Home.visiblePinsTitle.isEmpty)
        XCTAssertFalse(TJStrings.Home.pinsList.isEmpty)
    }

    func testAddVisitStepCounterFormatsExpectedShape() {
        let value = TJStrings.AddVisit.stepCounter(stepIndex: 2, total: 3, title: "Dates")
        XCTAssertEqual(value, "Step 2/3 · Dates")
    }

    func testPhotosSelectedCountFormatsPrefixAndCount() {
        let value = TJStrings.AddVisit.photosSelectedCount(10)
        XCTAssertEqual(value, "Photos selected: 10")
    }

    func testTripsVisitCountPluralization() {
        XCTAssertEqual(TJStrings.Trips.visitCount(1), "1 visit")
        XCTAssertEqual(TJStrings.Trips.visitCount(3), "3 visits")
    }

    func testSettingsHelperFormatting() {
        XCTAssertEqual(TJStrings.Settings.lastSuccessfulSync("formatted"), "Last successful sync: formatted")
        XCTAssertEqual(TJStrings.Settings.syncFailed("network error"), "Sync failed: network error")
    }
}
