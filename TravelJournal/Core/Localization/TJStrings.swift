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
}
