import Foundation
import Combine
import TravelJournalData
import TravelJournalDomain

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
    private let pinIDToPlaceID: [String: UUID]
    private let placeRepository: PlaceRepository?
    private let visitRepository: VisitRepository?
    private let spotRepository: SpotRepository?
    private let mediaRepository: MediaRepository?

    public init(
        pins: [GlobePin] = HomeViewModel.defaultPins,
        placeIDsByTagID: [String: Set<String>] = [:],
        placeIDsByTripID: [String: Set<String>] = [:],
        placeIDsByYear: [Int: Set<String>] = [:],
        pinIDToPlaceID: [String: UUID] = [:],
        placeRepository: PlaceRepository? = nil,
        visitRepository: VisitRepository? = nil,
        spotRepository: SpotRepository? = nil,
        mediaRepository: MediaRepository? = nil
    ) {
        self.pins = pins
        self.visiblePins = pins
        self.placeIDsByTagID = placeIDsByTagID
        self.placeIDsByTripID = placeIDsByTripID
        self.placeIDsByYear = placeIDsByYear
        self.pinIDToPlaceID = pinIDToPlaceID
        self.placeRepository = placeRepository
        self.visitRepository = visitRepository
        self.spotRepository = spotRepository
        self.mediaRepository = mediaRepository
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

        if let model = repositoryBackedPlaceStory(for: selectedPlaceID) {
            return model
        }

        return PlaceStoryViewModel(
            placeName: selectedPlaceID.capitalized,
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

    private func repositoryBackedPlaceStory(for pinID: String) -> PlaceStoryViewModel? {
        guard
            let placeRepository,
            let visitRepository,
            let placeID = pinIDToPlaceID[pinID],
            let place = try? placeRepository.fetchPlace(id: placeID),
            let place
        else {
            return nil
        }

        let visits = (try? visitRepository.fetchVisits(forPlace: place.id)) ?? []
        let rows = visits.map { visit in
            let spots = ((try? spotRepository?.fetchSpots(forVisit: visit.id)) ?? [])
                .map { spot in
                    VisitSpotRow(
                        id: spot.id.uuidString.lowercased(),
                        name: spot.name,
                        category: spot.category ?? "Spot",
                        ratingText: Self.ratingText(for: spot.rating),
                        note: spot.note
                    )
                }
            let photoCount = (try? mediaRepository?.fetchMedia(forVisit: visit.id).count) ?? 0
            return PlaceStoryVisitRow(
                id: visit.id.uuidString.lowercased(),
                title: visit.summary?.isEmpty == false ? (visit.summary ?? "") : "Visit",
                dateRangeText: Self.dateRangeFormatter.string(from: visit.startDate, to: visit.endDate),
                summary: visit.summary,
                notes: visit.notes,
                photoCount: photoCount,
                spots: spots,
                recommendations: Self.recommendations(from: visit.notes)
            )
        }

        return PlaceStoryViewModel(
            placeName: place.name,
            countryName: place.country ?? "Unknown Country",
            visits: rows
        )
    }

    private static let dateRangeFormatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static func ratingText(for rating: Int?) -> String? {
        guard let rating else { return nil }
        return "\(rating)/5"
    }

    private static func recommendations(from notes: String?) -> [String] {
        guard let notes else { return [] }

        let normalized = notes
            .replacingOccurrences(of: "\r\n", with: "\n")
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }

        if normalized.count > 1 {
            return Array(normalized.prefix(3))
        }

        let sentenceChunks = notes
            .split(separator: ".")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }

        return Array(sentenceChunks.prefix(2))
    }

    static let defaultPins: [GlobePin] = [
        GlobePin(id: "paris", latitude: 48.8566, longitude: 2.3522),
        GlobePin(id: "tokyo", latitude: 35.6764, longitude: 139.6500),
        GlobePin(id: "lisbon", latitude: 38.7223, longitude: -9.1393)
    ]
}
