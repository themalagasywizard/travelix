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
    }
}
