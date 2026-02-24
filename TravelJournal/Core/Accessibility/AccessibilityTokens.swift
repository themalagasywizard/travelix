import Foundation

public enum TJAccessibility {
    public enum Identifier {
        public static let homeSearchField = "home.search.field"
        public static let homeFilterChipPrefix = "home.filter.chip."
        public static let homeSelectedPlaceBadge = "home.selected.place.badge"
        public static let homeErrorBanner = "home.error.banner"
        public static let homePinsListButton = "home.pins.list.button"
        public static let homePinsList = "home.pins.list"
        public static let homePinsListRowPrefix = "home.pins.list.row."
        public static let homeSettingsButton = "home.settings.button"
        public static let homeTripsButton = "home.trips.button"
        public static let homeAddVisitButton = "home.add.visit.button"
        public static let homeSearchResultRowPrefix = "home.search.result.row."

        public static let tripsList = "trips.list"
        public static let tripsRowPrefix = "trips.row."
        public static let tripsErrorBanner = "trips.error.banner"

        public static let settingsSyncToggle = "settings.sync.toggle"
        public static let settingsSyncDescription = "settings.sync.description"
        public static let settingsSyncNowButton = "settings.sync.now.button"
        public static let settingsSyncNowStatus = "settings.sync.now.status"

        public static let visitHeader = "visit.header"
        public static let visitSummarySection = "visit.summary.section"
        public static let visitPhotosSection = "visit.photos.section"
        public static let visitNotesSection = "visit.notes.section"
        public static let visitSpotsSection = "visit.spots.section"
        public static let visitRecommendationsSection = "visit.recommendations.section"
    }

    public enum Label {
        public static let homeSearchField = "Search places, trips, spots, or tags"
        public static let homeGlobe = "Travel globe with visited place pins"
        public static let homePinsListButton = "Open list of visible pins"
        public static let homeSettingsButton = "Open settings"
        public static let homeTripsButton = "Open trips list"
        public static let homeAddVisitButton = "Add a new visit"

        public static let tripsList = "Trips list"
        public static func tripsRow(title: String, dateRange: String, visitCount: String) -> String {
            "Trip \(title), \(dateRange), \(visitCount)"
        }
        public static let tripsErrorBanner = "Trips loading error"

        public static let settingsSyncToggle = "Enable iCloud sync"
        public static let settingsSyncDescription = "Sync feature description"
        public static let settingsSyncNowButton = "Run sync now"
        public static let settingsSyncNowStatus = "Latest sync status"

        public static func pinListRow(_ placeID: String) -> String {
            "Select place \(placeID)"
        }

        public static func filterChip(_ name: String, isSelected: Bool) -> String {
            isSelected ? "\(name) filter selected" : "\(name) filter"
        }

        public static func selectedPlace(_ placeID: String) -> String {
            "Selected place \(placeID)"
        }

        public static let visitSummaryTitle = "Visit summary"
        public static let visitPhotosTitle = "Visit photos"
        public static let visitNotesTitle = "Visit notes"
        public static let visitSpotsTitle = "Visit spots"
        public static let visitRecommendationsTitle = "Visit recommendations"
    }
}
