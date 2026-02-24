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
    @Published public private(set) var selectedTripID: String?
    @Published public private(set) var selectedYear: Int?
    @Published public private(set) var visiblePins: [GlobePin]

    private let placeIDsByTagID: [String: Set<String>]
    private let placeIDsByTripID: [String: Set<String>]
    private let placeIDsByYear: [Int: Set<String>]

    public init(
        pins: [GlobePin] = HomeViewModel.defaultPins,
        placeIDsByTagID: [String: Set<String>] = [:],
        placeIDsByTripID: [String: Set<String>] = [:],
        placeIDsByYear: [Int: Set<String>] = [:]
    ) {
        self.pins = pins
        self.visiblePins = pins
        self.placeIDsByTagID = placeIDsByTagID
        self.placeIDsByTripID = placeIDsByTripID
        self.placeIDsByYear = placeIDsByYear
    }

    public func toggleFilter(_ filter: FilterChip) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
            clearSelection(for: filter)
        } else {
            selectedFilters.insert(filter)
        }

        applyFilters()
    }

    public func handlePinSelected(_ placeID: String) {
        selectedPlaceID = placeID
    }

    public func clearSelectedPlace() {
        selectedPlaceID = nil
    }

    public func selectTag(_ tagID: String?) {
        selectedTagID = tagID
        selectedFilters.insert(.tag)
        applyFilters()
    }

    public func selectTrip(_ tripID: String?) {
        selectedTripID = tripID
        selectedFilters.insert(.trip)
        applyFilters()
    }

    public func selectYear(_ year: Int?) {
        selectedYear = year
        selectedFilters.insert(.year)
        applyFilters()
    }

    private func clearSelection(for filter: FilterChip) {
        switch filter {
        case .year:
            selectedYear = nil
        case .trip:
            selectedTripID = nil
        case .tag:
            selectedTagID = nil
        }
    }

    private func applyFilters() {
        var allowedPlaceIDs = Set(pins.map(\.id))

        if selectedFilters.contains(.tag),
           let selectedTagID,
           let placeIDs = placeIDsByTagID[selectedTagID] {
            allowedPlaceIDs.formIntersection(placeIDs)
        }

        if selectedFilters.contains(.trip),
           let selectedTripID,
           let placeIDs = placeIDsByTripID[selectedTripID] {
            allowedPlaceIDs.formIntersection(placeIDs)
        }

        if selectedFilters.contains(.year),
           let selectedYear,
           let placeIDs = placeIDsByYear[selectedYear] {
            allowedPlaceIDs.formIntersection(placeIDs)
        }

        visiblePins = pins.filter { allowedPlaceIDs.contains($0.id) }
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
