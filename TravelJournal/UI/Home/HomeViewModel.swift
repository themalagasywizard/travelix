import Foundation
import Combine

@MainActor
public final class HomeViewModel: ObservableObject {
    public enum FilterChip: String, CaseIterable, Identifiable {
        case year = "Year"
        case trip = "Trip"
        case tag = "Tag"

        public var id: String { rawValue }
    }

    @Published public var searchText: String = ""
    @Published public private(set) var selectedFilters: Set<FilterChip> = []
    @Published public private(set) var selectedPlaceID: String?
    @Published public private(set) var pins: [GlobePin]
    @Published public private(set) var selectedTagID: String?
    @Published public private(set) var visiblePins: [GlobePin]

    private let placeIDsByTagID: [String: Set<String>]

    public init(
        pins: [GlobePin] = HomeViewModel.defaultPins,
        placeIDsByTagID: [String: Set<String>] = [:]
    ) {
        self.pins = pins
        self.visiblePins = pins
        self.placeIDsByTagID = placeIDsByTagID
    }

    public func toggleFilter(_ filter: FilterChip) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
    }

    public func handlePinSelected(_ placeID: String) {
        selectedPlaceID = placeID
    }

    public func clearSelectedPlace() {
        selectedPlaceID = nil
    }

    public func selectTag(_ tagID: String?) {
        selectedTagID = tagID
        applyFilters()
    }

    private func applyFilters() {
        guard let selectedTagID,
              let placeIDs = placeIDsByTagID[selectedTagID]
        else {
            visiblePins = pins
            return
        }

        visiblePins = pins.filter { placeIDs.contains($0.id) }
    }

    public var selectedPlaceStoryViewModel: PlaceStoryViewModel? {
        guard let selectedPlaceID else { return nil }

        let placeName = selectedPlaceID.capitalized
        return PlaceStoryViewModel(
            placeName: placeName,
            countryName: "Unknown Country",
            visits: [
                .init(
                    id: "sample-\(selectedPlaceID)",
                    title: "Recent Visit",
                    dateRangeText: "Dates TBD",
                    summary: "Seeded summary placeholder until repository wiring is connected."
                )
            ]
        )
    }

    static let defaultPins: [GlobePin] = [
        GlobePin(id: "paris", latitude: 48.8566, longitude: 2.3522),
        GlobePin(id: "tokyo", latitude: 35.6764, longitude: 139.6500),
        GlobePin(id: "lisbon", latitude: 38.7223, longitude: -9.1393)
    ]
}
