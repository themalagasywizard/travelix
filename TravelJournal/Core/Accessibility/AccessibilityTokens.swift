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
