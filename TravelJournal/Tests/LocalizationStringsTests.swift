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
        XCTAssertFalse(TJStrings.Home.defaultSpotCategory.isEmpty)
        XCTAssertFalse(TJStrings.Home.visitTitle.isEmpty)
        XCTAssertFalse(TJStrings.Home.fallbackRecentVisitTitle.isEmpty)
        XCTAssertFalse(TJStrings.Home.fallbackPlaceStorySummary.isEmpty)
        XCTAssertFalse(TJStrings.Home.tripsUnavailableMessage.isEmpty)
    }

    func testAddVisitStepCounterFormatsExpectedShape() {
        let value = TJStrings.AddVisit.stepCounter(stepIndex: 2, total: 3, title: TJStrings.AddVisit.stepDatesTitle)
        XCTAssertEqual(value, "Step 2/3 · Dates")
    }

    func testPhotosSelectedCountFormatsPrefixAndCount() {
        let value = TJStrings.AddVisit.photosSelectedCount(10)
        XCTAssertEqual(value, "Photos selected: 10")
    }

    func testTripsVisitCountPluralization() {
        XCTAssertEqual(TJStrings.Trips.visitCount(1), "1 visit")
        XCTAssertEqual(TJStrings.Trips.visitCount(3), "3 visits")
        XCTAssertEqual(TJStrings.Trips.banner(title: "Error", message: "Failed to load"), "Error: Failed to load")
    }

    func testAddVisitErrorAndStepTokensAreStable() {
        XCTAssertEqual(TJStrings.AddVisit.stepLocationTitle, "Location")
        XCTAssertEqual(TJStrings.AddVisit.stepDatesTitle, "Dates")
        XCTAssertEqual(TJStrings.AddVisit.stepContentTitle, "Content")
        XCTAssertEqual(TJStrings.AddVisit.currentLocationUnavailable, "Current location is unavailable on this device.")
        XCTAssertEqual(TJStrings.AddVisit.missingLocationError, "Please enter a location before saving.")
        XCTAssertEqual(TJStrings.AddVisit.invalidDateRangeError, "End date must be on or after start date.")
        XCTAssertEqual(TJStrings.AddVisit.persistenceFailedError, "We couldn't save this visit. Please try again.")
    }

    func testSettingsHelperFormatting() {
        XCTAssertEqual(TJStrings.Settings.lastSuccessfulSync("formatted"), "Last successful sync: formatted")
        XCTAssertEqual(TJStrings.Settings.syncFailed("network error"), "Sync failed: network error")
    }

    func testHomeAndVisitDetailHelperFormatting() {
        XCTAssertEqual(TJStrings.Home.yearFilterTitle(2026), "Year: 2026")
        XCTAssertEqual(TJStrings.Home.tripFilterTitle("japan-2025"), "Trip: japan-2025")
        XCTAssertEqual(TJStrings.Home.tagFilterTitle("food"), "Tag: food")
        XCTAssertEqual(TJStrings.Home.searchResultAccessibilityLabel(title: "Tokyo", subtitle: "Japan"), "Tokyo, Japan")
        XCTAssertEqual(TJStrings.Home.searchResultAccessibilityLabel(title: "Tokyo", subtitle: nil), "Tokyo")
        XCTAssertEqual(TJStrings.VisitDetail.photosSectionTitle(4), "Photos (4)")
    }

    func testEditVisitAndPlaceStoryTokensAreStable() {
        XCTAssertEqual(TJStrings.EditVisit.title, "Edit Visit")
        XCTAssertEqual(TJStrings.EditVisit.save, "Save")
        XCTAssertEqual(TJStrings.EditVisit.invalidDateRangeError, "End date must be on or after start date.")
        XCTAssertEqual(TJStrings.PlaceStory.visits, "Visits")
        XCTAssertEqual(TJStrings.PlaceStory.miniGlobePreview, "Mini globe preview")
        XCTAssertEqual(TJStrings.PlaceStory.visitCount(1), "1 visit")
        XCTAssertEqual(TJStrings.PlaceStory.visitCount(2), "2 visits")
    }

    func testSpotsEditorAndDeveloperToolsTokensAreStable() {
        XCTAssertEqual(TJStrings.SpotsEditor.title, "Manage Spots")
        XCTAssertEqual(TJStrings.SpotsEditor.addSpotButton, "Add Spot")
        XCTAssertEqual(TJStrings.SpotsEditor.defaultCategory, "spot")
        XCTAssertEqual(TJStrings.SpotsEditor.invalidSpotID, "Invalid spot id")
        XCTAssertEqual(TJStrings.SpotsEditor.spotReferenceInvalid, "Spot reference is invalid.")
        XCTAssertEqual(TJStrings.SpotsEditor.spotNotFound, "Spot not found")
        XCTAssertEqual(TJStrings.SpotsEditor.selectedSpotMissing, "The selected spot no longer exists.")
        XCTAssertEqual(TJStrings.SpotsEditor.failedToLoadSpots("x"), "Failed to load spots: x")
        XCTAssertEqual(TJStrings.SpotsEditor.failedToAddSpot("x"), "Failed to add spot: x")
        XCTAssertEqual(TJStrings.SpotsEditor.failedToUpdateSpot("x"), "Failed to update spot: x")
        XCTAssertEqual(TJStrings.SpotsEditor.failedToDeleteSpot("x"), "Failed to delete spot: x")

        XCTAssertEqual(TJStrings.DeveloperTools.loadDemoData, "Load Demo Data")
        XCTAssertEqual(TJStrings.DeveloperTools.clearThumbnailCache, "Clear Thumbnail Cache")
        XCTAssertEqual(TJStrings.DeveloperTools.demoDataAlreadyLoaded, "Demo data already loaded")
        XCTAssertEqual(TJStrings.DeveloperTools.thumbnailCacheUnavailable, "Thumbnail cache unavailable")
        XCTAssertEqual(TJStrings.DeveloperTools.thumbnailCacheUnavailableSummary, "Thumbnail cache: unavailable")
        XCTAssertEqual(TJStrings.DeveloperTools.clearedThumbnailCache, "Cleared thumbnail cache")
        XCTAssertEqual(TJStrings.DeveloperTools.unavailableDemoSeederError, "Demo seeding is unavailable in this build context")
        XCTAssertEqual(TJStrings.DeveloperTools.loadedDemoData(places: 5, visits: 7), "Loaded 5 places and 7 visits")
        XCTAssertEqual(TJStrings.DeveloperTools.failedToLoadDemoData("x"), "Failed to load demo data: x")
        XCTAssertEqual(TJStrings.DeveloperTools.failedToClearThumbnailCache("x"), "Failed to clear thumbnail cache: x")
        XCTAssertEqual(TJStrings.DeveloperTools.thumbnailCacheSummary(files: 2, bytesText: "2 KB"), "Thumbnail cache: 2 files (2 KB)")
    }

    func testErrorPresentationTokensAreStable() {
        XCTAssertEqual(TJStrings.ErrorPresentation.databaseTitle, "Something went wrong")
        XCTAssertEqual(TJStrings.ErrorPresentation.databaseMessage, "We couldn’t save your data. Please try again.")
        XCTAssertEqual(TJStrings.ErrorPresentation.databaseAction, "Retry")
        XCTAssertEqual(TJStrings.ErrorPresentation.mediaImportTitle, "Import failed")
        XCTAssertEqual(TJStrings.ErrorPresentation.mediaImportMessage, "We couldn’t import one or more photos.")
        XCTAssertEqual(TJStrings.ErrorPresentation.mediaImportAction, "Try Again")
        XCTAssertEqual(TJStrings.ErrorPresentation.invalidInputTitle, "Check your input")
        XCTAssertEqual(TJStrings.ErrorPresentation.unknownTitle, "Unexpected error")
        XCTAssertEqual(TJStrings.ErrorPresentation.unknownMessage, "Please try again in a moment.")
        XCTAssertEqual(TJStrings.ErrorPresentation.unknownAction, "Dismiss")
    }

    func testGlobeFallbackTokenIsStable() {
        XCTAssertEqual(TJStrings.Globe.sceneKitUnavailable, "SceneKit unavailable on this platform")
    }

    func testAccessibilityTokensAreStable() {
        XCTAssertEqual(TJStrings.Accessibility.homeSearchField, "Search places, trips, spots, or tags")
        XCTAssertEqual(TJStrings.Accessibility.homeGlobe, "Travel globe with visited place pins")
        XCTAssertEqual(TJStrings.Accessibility.homePinsListButton, "Open list of visible pins")
        XCTAssertEqual(TJStrings.Accessibility.homeSettingsButton, "Open settings")
        XCTAssertEqual(TJStrings.Accessibility.homeTripsButton, "Open trips list")
        XCTAssertEqual(TJStrings.Accessibility.homeAddVisitButton, "Add a new visit")
        XCTAssertEqual(TJStrings.Accessibility.tripsList, "Trips list")
        XCTAssertEqual(TJStrings.Accessibility.tripsErrorBanner, "Trips loading error")
        XCTAssertEqual(TJStrings.Accessibility.settingsSyncToggle, "Enable iCloud sync")
        XCTAssertEqual(TJStrings.Accessibility.settingsSyncDescription, "Sync feature description")
        XCTAssertEqual(TJStrings.Accessibility.settingsSyncNowButton, "Run sync now")
        XCTAssertEqual(TJStrings.Accessibility.settingsSyncNowStatus, "Latest sync status")
        XCTAssertEqual(TJStrings.Accessibility.visitSummaryTitle, "Visit summary")
        XCTAssertEqual(TJStrings.Accessibility.visitPhotosTitle, "Visit photos")
        XCTAssertEqual(TJStrings.Accessibility.visitNotesTitle, "Visit notes")
        XCTAssertEqual(TJStrings.Accessibility.visitSpotsTitle, "Visit spots")
        XCTAssertEqual(TJStrings.Accessibility.visitRecommendationsTitle, "Visit recommendations")

        XCTAssertEqual(
            TJStrings.Accessibility.tripsRow(title: "Japan 2025", dateRange: "Jan 2 – Jan 12, 2025", visitCount: "4 visits"),
            "Trip Japan 2025, Jan 2 – Jan 12, 2025, 4 visits"
        )
        XCTAssertEqual(TJStrings.Accessibility.pinListRow("Tokyo"), "Select place Tokyo")
        XCTAssertEqual(TJStrings.Accessibility.filterChip("Tag", isSelected: false), "Tag filter")
        XCTAssertEqual(TJStrings.Accessibility.filterChip("Tag", isSelected: true), "Tag filter selected")
        XCTAssertEqual(TJStrings.Accessibility.selectedPlace("paris"), "Selected place paris")
    }
}
