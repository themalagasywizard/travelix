import XCTest
@testable import TravelJournalCore

final class LocalizationStringsTests: XCTestCase {
    func testHomeStringsAreNonEmpty() {
        XCTAssertFalse(TJStrings.Home.searchPlaceholder.isEmpty)
        XCTAssertFalse(TJStrings.Home.visiblePinsTitle.isEmpty)
        XCTAssertFalse(TJStrings.Home.pinsList.isEmpty)
        XCTAssertFalse(TJStrings.Home.yearFilter.isEmpty)
        XCTAssertFalse(TJStrings.Home.tripFilter.isEmpty)
        XCTAssertFalse(TJStrings.Home.tagFilter.isEmpty)
        XCTAssertFalse(TJStrings.Home.unknownCountry.isEmpty)
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

    func testHomeAndVisitDetailHelperFormatting() {
        XCTAssertEqual(TJStrings.Home.yearFilterTitle(2026), "Year: 2026")
        XCTAssertEqual(TJStrings.Home.tripFilterTitle("japan-2025"), "Trip: japan-2025")
        XCTAssertEqual(TJStrings.Home.tagFilterTitle("food"), "Tag: food")
        XCTAssertEqual(TJStrings.VisitDetail.photosSectionTitle(4), "Photos (4)")
    }

    func testEditVisitAndPlaceStoryTokensAreStable() {
        XCTAssertEqual(TJStrings.EditVisit.title, "Edit Visit")
        XCTAssertEqual(TJStrings.EditVisit.save, "Save")
        XCTAssertEqual(TJStrings.PlaceStory.visits, "Visits")
        XCTAssertEqual(TJStrings.PlaceStory.miniGlobePreview, "Mini globe preview")
    }

    func testSpotsEditorAndDeveloperToolsTokensAreStable() {
        XCTAssertEqual(TJStrings.SpotsEditor.title, "Manage Spots")
        XCTAssertEqual(TJStrings.SpotsEditor.addSpotButton, "Add Spot")
        XCTAssertEqual(TJStrings.DeveloperTools.loadDemoData, "Load Demo Data")
        XCTAssertEqual(TJStrings.DeveloperTools.clearThumbnailCache, "Clear Thumbnail Cache")
    }

    func testGlobeFallbackTokenIsStable() {
        XCTAssertEqual(TJStrings.Globe.sceneKitUnavailable, "SceneKit unavailable on this platform")
    }
}
