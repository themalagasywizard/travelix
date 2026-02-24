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
        public static let homeSearchField = TJStrings.Accessibility.homeSearchField
        public static let homeGlobe = TJStrings.Accessibility.homeGlobe
        public static let homePinsListButton = TJStrings.Accessibility.homePinsListButton
        public static let homeSettingsButton = TJStrings.Accessibility.homeSettingsButton
        public static let homeTripsButton = TJStrings.Accessibility.homeTripsButton
        public static let homeAddVisitButton = TJStrings.Accessibility.homeAddVisitButton

        public static let tripsList = TJStrings.Accessibility.tripsList
        public static func tripsRow(title: String, dateRange: String, visitCount: String) -> String {
            TJStrings.Accessibility.tripsRow(title: title, dateRange: dateRange, visitCount: visitCount)
        }
        public static let tripsErrorBanner = TJStrings.Accessibility.tripsErrorBanner

        public static let settingsSyncToggle = TJStrings.Accessibility.settingsSyncToggle
        public static let settingsSyncDescription = TJStrings.Accessibility.settingsSyncDescription
        public static let settingsSyncNowButton = TJStrings.Accessibility.settingsSyncNowButton
        public static let settingsSyncNowStatus = TJStrings.Accessibility.settingsSyncNowStatus

        public static func pinListRow(_ placeID: String) -> String {
            TJStrings.Accessibility.pinListRow(placeID)
        }

        public static func filterChip(_ name: String, isSelected: Bool) -> String {
            TJStrings.Accessibility.filterChip(name, isSelected: isSelected)
        }

        public static func selectedPlace(_ placeID: String) -> String {
            TJStrings.Accessibility.selectedPlace(placeID)
        }

        public static let visitSummaryTitle = TJStrings.Accessibility.visitSummaryTitle
        public static let visitPhotosTitle = TJStrings.Accessibility.visitPhotosTitle
        public static let visitNotesTitle = TJStrings.Accessibility.visitNotesTitle
        public static let visitSpotsTitle = TJStrings.Accessibility.visitSpotsTitle
        public static let visitRecommendationsTitle = TJStrings.Accessibility.visitRecommendationsTitle
    }
}
