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

    public init(pins: [GlobePin] = HomeViewModel.defaultPins) {
        self.pins = pins
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

    static let defaultPins: [GlobePin] = [
        GlobePin(id: "paris", latitude: 48.8566, longitude: 2.3522),
        GlobePin(id: "tokyo", latitude: 35.6764, longitude: 139.6500),
        GlobePin(id: "lisbon", latitude: 38.7223, longitude: -9.1393)
    ]
}
