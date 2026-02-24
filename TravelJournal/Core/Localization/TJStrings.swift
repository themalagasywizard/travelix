import Foundation

/// Centralized user-facing strings for v1 English copy.
///
/// This keeps UI literals in one place so migration to `Localizable.strings`
/// is straightforward when additional locales are introduced.
public enum TJStrings {
    public enum Home {
        public static let selectedPrefix = "Selected"
        public static let dismiss = "Dismiss"
        public static let visiblePinsTitle = "Visible Pins"
        public static let searchPlaceholder = "Search places, trips, spots, tags"
        public static let pinsList = "Pins List"
        public static let yearFilter = "Year"
        public static let tripFilter = "Trip"
        public static let tagFilter = "Tag"
        public static let unknownCountry = "Unknown Country"
        public static let defaultSpotCategory = "Spot"
        public static let visitTitle = "Visit"
        public static let fallbackRecentVisitTitle = "Recent Visit"
        public static let fallbackPlaceStorySummary = "Seeded summary placeholder until repository wiring is connected."
        public static let tripsUnavailableMessage = "Trips are unavailable until repositories are connected."
        public static let missingPlaceMappingError = "Missing place mapping for selected pin."
        public static let selectedPlaceMissingError = "Selected place no longer exists."

        public static func yearFilterTitle(_ value: Int) -> String {
            "\(yearFilter): \(value)"
        }

        public static func tripFilterTitle(_ value: String) -> String {
            "\(tripFilter): \(value)"
        }

        public static func tagFilterTitle(_ value: String) -> String {
            "\(tagFilter): \(value)"
        }

        public static func searchResultAccessibilityLabel(title: String, subtitle: String?) -> String {
            guard let subtitle, subtitle.isEmpty == false else {
                return title
            }
            return "\(title), \(subtitle)"
        }

        public static func selectedPlaceBadge(_ placeID: String) -> String {
            "\(selectedPrefix): \(placeID)"
        }

        public static func ratingOutOfFive(_ rating: Int) -> String {
            "\(rating)/5"
        }
    }

    public enum AddVisit {
        public static let title = "Add Visit"
        public static let wherePrompt = "Where did you go?"
        public static let locationPlaceholder = "Search city or place"
        public static let useCurrentLocation = "Use current location"
        public static let startDate = "Start date"
        public static let endDate = "End date"
        public static let quickNotes = "Quick notes"
        public static let selectPhotos = "Select photos"
        public static let photosSelectedPrefix = "Photos selected"
        public static let back = "Back"
        public static let save = "Save"
        public static let next = "Next"
        public static let stepLocationTitle = "Location"
        public static let stepDatesTitle = "Dates"
        public static let stepContentTitle = "Content"
        public static let currentLocationUnavailable = "Current location is unavailable on this device."
        public static let missingLocationError = "Please enter a location before saving."
        public static let invalidDateRangeError = "End date must be on or after start date."
        public static let persistenceFailedError = "We couldn't save this visit. Please try again."

        public static func stepCounter(stepIndex: Int, total: Int, title: String) -> String {
            "Step \(stepIndex)/\(total) · \(title)"
        }

        public static func photosSelectedCount(_ count: Int) -> String {
            "\(photosSelectedPrefix): \(count)"
        }
    }

    public enum Trips {
        public static let title = "Trips"
        public static let datesTBD = "Dates TBD"

        public static func visitCount(_ count: Int) -> String {
            "\(count) visit\(count == 1 ? "" : "s")"
        }

        public static func banner(title: String, message: String) -> String {
            "\(title): \(message)"
        }
    }

    public enum PlaceStory {
        public static let miniGlobePreview = "Mini globe preview"
        public static let visits = "Visits"

        public static func visitCount(_ count: Int) -> String {
            "\(count) visit\(count == 1 ? "" : "s")"
        }
    }

    public enum EditVisit {
        public static let title = "Edit Visit"
        public static let cancel = "Cancel"
        public static let save = "Save"
        public static let locationSection = "Location"
        public static let locationField = "Location"
        public static let datesSection = "Dates"
        public static let startDate = "Start"
        public static let endDate = "End"
        public static let summarySection = "Summary"
        public static let oneLineSummary = "One-line summary"
        public static let notesSection = "Notes"
        public static let invalidDateRangeError = "End date must be on or after start date."
    }

    public enum SpotsEditor {
        public static let title = "Manage Spots"
        public static let addSpotSection = "Add spot"
        public static let nameField = "Name"
        public static let categoryField = "Category"
        public static let noteField = "Note"
        public static let addSpotButton = "Add Spot"
        public static let savedSpotsSection = "Saved spots"
        public static let noSpotsYet = "No spots yet"
        public static let errorSection = "Error"
        public static let defaultCategory = "spot"
        public static let invalidSpotID = "Invalid spot id"
        public static let spotReferenceInvalid = "Spot reference is invalid."
        public static let spotNotFound = "Spot not found"
        public static let selectedSpotMissing = "The selected spot no longer exists."

        public static func ratingOutOfFive(_ rating: Int) -> String {
            "\(rating)/5"
        }

        public static func failedToLoadSpots(_ message: String) -> String {
            "Failed to load spots: \(message)"
        }

        public static func failedToAddSpot(_ message: String) -> String {
            "Failed to add spot: \(message)"
        }

        public static func failedToUpdateSpot(_ message: String) -> String {
            "Failed to update spot: \(message)"
        }

        public static func failedToDeleteSpot(_ message: String) -> String {
            "Failed to delete spot: \(message)"
        }
    }

    public enum DeveloperTools {
        public static let loadDemoData = "Load Demo Data"
        public static let clearThumbnailCache = "Clear Thumbnail Cache"
        public static let demoDataAlreadyLoaded = "Demo data already loaded"
        public static let thumbnailCacheUnavailable = "Thumbnail cache unavailable"
        public static let thumbnailCacheUnavailableSummary = "Thumbnail cache: unavailable"
        public static let clearedThumbnailCache = "Cleared thumbnail cache"
        public static let unavailableDemoSeederError = "Demo seeding is unavailable in this build context"

        public static func loadedDemoData(places: Int, visits: Int) -> String {
            "Loaded \(places) places and \(visits) visits"
        }

        public static func failedToLoadDemoData(_ message: String) -> String {
            "Failed to load demo data: \(message)"
        }

        public static func failedToClearThumbnailCache(_ message: String) -> String {
            "Failed to clear thumbnail cache: \(message)"
        }

        public static func thumbnailCacheSummary(files: Int, bytesText: String) -> String {
            "Thumbnail cache: \(files) files (\(bytesText))"
        }
    }

    public enum Settings {
        public static let title = "Settings"
        public static let syncSectionTitle = "Sync"
        public static let developerSectionTitle = "Developer"
        public static let enableICloudSync = "Enable iCloud Sync"
        public static let syncDescription = "Off by default. When enabled, Travel Journal will sync records using your private iCloud database."
        public static let syncNow = "Sync Now"
        public static let syncFinished = "Sync finished"
        public static let enableSyncToRunNow = "Enable iCloud Sync to run a sync now"
        public static let syncFailedPrefix = "Sync failed"
        public static let lastSuccessfulPrefix = "Last successful sync"

        public static func syncFailed(_ message: String) -> String {
            "\(syncFailedPrefix): \(message)"
        }

        public static func lastSuccessfulSync(_ value: String) -> String {
            "\(lastSuccessfulPrefix): \(value)"
        }
    }

    public enum VisitDetail {
        public static let summary = "Summary"
        public static let notes = "Notes"
        public static let spots = "Spots"
        public static let recommendations = "Recommendations"
        public static let noSummaryYet = "No summary yet"
        public static let noNotesYet = "No notes yet"
        public static let noSpotsAdded = "No spots added"
        public static let manageSpots = "Manage Spots"
        public static let noRecommendationsYet = "No recommendations yet"

        public static func photosSectionTitle(_ count: Int) -> String {
            "Photos (\(count))"
        }
    }

    public enum ErrorPresentation {
        public static let databaseTitle = "Something went wrong"
        public static let databaseMessage = "We couldn’t save your data. Please try again."
        public static let databaseAction = "Retry"
        public static let mediaImportTitle = "Import failed"
        public static let mediaImportMessage = "We couldn’t import one or more photos."
        public static let mediaImportAction = "Try Again"
        public static let invalidInputTitle = "Check your input"
        public static let unknownTitle = "Unexpected error"
        public static let unknownMessage = "Please try again in a moment."
        public static let unknownAction = "Dismiss"
    }

    public enum Globe {
        public static let sceneKitUnavailable = "SceneKit unavailable on this platform"
    }

    public enum Accessibility {
        public static let homeSearchField = "Search places, trips, spots, or tags"
        public static let homeGlobe = "Travel globe with visited place pins"
        public static let homePinsListButton = "Open list of visible pins"
        public static let homeSettingsButton = "Open settings"
        public static let homeTripsButton = "Open trips list"
        public static let homeAddVisitButton = "Add a new visit"

        public static let tripsList = "Trips list"
        public static let tripsErrorBanner = "Trips loading error"

        public static let settingsSyncToggle = "Enable iCloud sync"
        public static let settingsSyncDescription = "Sync feature description"
        public static let settingsSyncNowButton = "Run sync now"
        public static let settingsSyncNowStatus = "Latest sync status"

        public static let visitSummaryTitle = "Visit summary"
        public static let visitPhotosTitle = "Visit photos"
        public static let visitNotesTitle = "Visit notes"
        public static let visitSpotsTitle = "Visit spots"
        public static let visitRecommendationsTitle = "Visit recommendations"

        public static func tripsRow(title: String, dateRange: String, visitCount: String) -> String {
            "Trip \(title), \(dateRange), \(visitCount)"
        }

        public static func pinListRow(_ placeID: String) -> String {
            "Select place \(placeID)"
        }

        public static func filterChip(_ name: String, isSelected: Bool) -> String {
            isSelected ? "\(name) filter selected" : "\(name) filter"
        }

        public static func selectedPlace(_ placeID: String) -> String {
            "Selected place \(placeID)"
        }
    }
}
