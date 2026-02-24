import Foundation
import Combine
import TravelJournalCore
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

    @Published public var searchText: String = "" {
        didSet {
            applyFilters()
            refreshSearchResults()
        }
    }
    @Published public private(set) var selectedFilters: Set<FilterChip> = []
    @Published public private(set) var selectedPlaceID: String?
    @Published public private(set) var pins: [GlobePin]
    @Published public private(set) var selectedTagID: String?
    @Published public private(set) var selectedTripID: String?
    @Published public private(set) var selectedYear: Int?
    @Published public private(set) var visiblePins: [GlobePin]
    @Published public private(set) var errorBanner: ErrorBannerModel?
    @Published public private(set) var searchResults: [SearchResult] = []
    @Published public private(set) var pendingVisitDeepLinkID: String?

    public struct PinListItem: Identifiable, Equatable {
        public let id: String
        public let title: String

        public init(id: String, title: String) {
            self.id = id
            self.title = title
        }
    }

    public struct PlaceSearchMetadata: Equatable {
        public let title: String
        public let subtitle: String?

        public init(title: String, subtitle: String? = nil) {
            self.title = title
            self.subtitle = subtitle
        }
    }

    private var placeIDsByTagID: [String: Set<String>]
    private var placeIDsByTripID: [String: Set<String>]
    private var placeIDsByYear: [Int: Set<String>]
    private var placeSearchMetadataByPinID: [String: PlaceSearchMetadata]
    private var pinIDToPlaceID: [String: UUID]
    private let placeRepository: PlaceRepository?
    private let visitRepository: VisitRepository?
    private let tripRepository: TripRepository?
    private let spotRepository: SpotRepository?
    private let mediaRepository: MediaRepository?
    private let searchRepository: SearchRepository?
    private let hapticsClient: HapticsClient

    public init(
        pins: [GlobePin] = HomeViewModel.defaultPins,
        placeIDsByTagID: [String: Set<String>] = [:],
        placeIDsByTripID: [String: Set<String>] = [:],
        placeIDsByYear: [Int: Set<String>] = [:],
        placeSearchMetadataByPinID: [String: PlaceSearchMetadata] = [:],
        pinIDToPlaceID: [String: UUID] = [:],
        placeRepository: PlaceRepository? = nil,
        visitRepository: VisitRepository? = nil,
        tripRepository: TripRepository? = nil,
        spotRepository: SpotRepository? = nil,
        mediaRepository: MediaRepository? = nil,
        searchRepository: SearchRepository? = nil,
        hapticsClient: HapticsClient = HapticsClient()
    ) {
        self.pins = pins
        self.visiblePins = pins
        self.placeIDsByTagID = placeIDsByTagID
        self.placeIDsByTripID = placeIDsByTripID
        self.placeIDsByYear = placeIDsByYear
        self.placeSearchMetadataByPinID = placeSearchMetadataByPinID
        self.pinIDToPlaceID = pinIDToPlaceID
        self.placeRepository = placeRepository
        self.visitRepository = visitRepository
        self.tripRepository = tripRepository
        self.spotRepository = spotRepository
        self.mediaRepository = mediaRepository
        self.searchRepository = searchRepository
        self.hapticsClient = hapticsClient
    }

    public func toggleFilter(_ filter: FilterChip) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
            clearSelection(for: filter)
        } else {
            selectedFilters.insert(filter)
            seedDefaultSelectionIfNeeded(for: filter)
        }

        applyFilters()
    }

    public func handlePinSelected(_ placeID: String) {
        selectedPlaceID = placeID
        searchResults = []
        errorBanner = nil
        hapticsClient.selection()
    }

    public func handleSearchResultSelected(_ result: SearchResult) {
        switch result.kind {
        case .place:
            if let pinID = pinIDToPlaceID.first(where: { $0.value == result.id })?.key {
                handlePinSelected(pinID)
                return
            }
        case .trip:
            selectTrip(result.id.uuidString.lowercased())
            searchResults = []
            errorBanner = nil
            return
        case .tag:
            selectTag(result.id.uuidString.lowercased())
            searchResults = []
            errorBanner = nil
            return
        case .visit, .spot:
            break
        }

        if searchText.localizedCaseInsensitiveContains(result.title) == false {
            searchText = result.title
        }
    }

    public func handleDeepLink(_ deepLink: AppDeepLink) {
        switch deepLink {
        case .place(let id):
            handlePinSelected(id.lowercased())
        case .trip(let id):
            selectTrip(id.lowercased())
            searchResults = []
            errorBanner = nil
        case .visit(let id):
            pendingVisitDeepLinkID = id.lowercased()
            searchResults = []
            errorBanner = nil
        }
    }

    public func consumePendingVisitDeepLinkID() -> String? {
        defer { pendingVisitDeepLinkID = nil }
        return pendingVisitDeepLinkID
    }

    public func clearSelectedPlace() {
        selectedPlaceID = nil
        errorBanner = nil
    }

    public func clearErrorBanner() {
        errorBanner = nil
    }

    public func handleTripsUnavailable() {
        errorBanner = ErrorPresentationMapper.banner(for: .invalidInput(message: "Trips are unavailable until repositories are connected."))
    }

    public func makeAddVisitFlowViewModel(now: @escaping () -> Date = Date.init) -> AddVisitFlowViewModel {
        AddVisitFlowViewModel(
            placeRepository: placeRepository,
            visitRepository: visitRepository,
            mediaRepository: mediaRepository,
            now: now
        )
    }

    public func makeTripsListViewModel() throws -> TripsListViewModel {
        guard let tripRepository, let visitRepository else {
            throw TJAppError.invalidInput(message: "Trips are unavailable until repositories are connected.")
        }

        return TripsListViewModel(tripRepository: tripRepository, visitRepository: visitRepository)
    }

    public func registerCreatedVisit(_ result: AddVisitSaveResult) {
        let pinID = result.place.id.uuidString.lowercased()

        pinIDToPlaceID[pinID] = result.place.id
        placeSearchMetadataByPinID[pinID] = PlaceSearchMetadata(
            title: result.place.name,
            subtitle: result.place.country
        )

        if pins.contains(where: { $0.id == pinID }) == false {
            let pin = GlobePin(
                id: pinID,
                latitude: result.place.latitude,
                longitude: result.place.longitude
            )
            pins.append(pin)
        }

        let year = Calendar.current.component(.year, from: result.visit.startDate)
        placeIDsByYear[year, default: []].insert(pinID)

        selectedPlaceID = pinID
        applyFilters()
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

    public func chipTitle(for filter: FilterChip) -> String {
        switch filter {
        case .year:
            if let selectedYear {
                return "Year: \(selectedYear)"
            }
        case .trip:
            if let selectedTripID {
                return "Trip: \(selectedTripID)"
            }
        case .tag:
            if let selectedTagID {
                return "Tag: \(selectedTagID)"
            }
        }

        return filter.rawValue
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

    private func seedDefaultSelectionIfNeeded(for filter: FilterChip) {
        switch filter {
        case .year:
            if selectedYear == nil {
                selectedYear = placeIDsByYear.keys.sorted().first
            }
        case .trip:
            if selectedTripID == nil {
                selectedTripID = placeIDsByTripID.keys.sorted().first
            }
        case .tag:
            if selectedTagID == nil {
                selectedTagID = placeIDsByTagID.keys.sorted().first
            }
        }
    }

    private func refreshSearchResults() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query.isEmpty == false else {
            searchResults = []
            return
        }

        guard let searchRepository else {
            searchResults = []
            return
        }

        do {
            searchResults = try searchRepository.search(query, limit: 8)
            errorBanner = nil
        } catch {
            searchResults = []
            errorBanner = ErrorPresentationMapper.banner(for: .databaseFailure)
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

        let normalizedSearch = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        visiblePins = pins.filter { pin in
            guard allowedPlaceIDs.contains(pin.id) else { return false }
            guard normalizedSearch.isEmpty == false else { return true }

            if pin.id.lowercased().contains(normalizedSearch) {
                return true
            }

            guard let metadata = placeSearchMetadataByPinID[pin.id] else {
                return false
            }

            if metadata.title.lowercased().contains(normalizedSearch) {
                return true
            }

            return metadata.subtitle?.lowercased().contains(normalizedSearch) ?? false
        }
    }

    public var selectedPlaceStoryViewModel: PlaceStoryViewModel? {
        guard let selectedPlaceID else { return nil }

        if let model = try? repositoryBackedPlaceStory(for: selectedPlaceID) {
            errorBanner = nil
            return model
        } else if let model = fallbackPlaceStory(for: selectedPlaceID) {
            errorBanner = nil
            return model
        } else {
            errorBanner = ErrorPresentationMapper.banner(for: .databaseFailure)
            return nil
        }
    }

    private func fallbackPlaceStory(for selectedPlaceID: String) -> PlaceStoryViewModel? {
        guard pinIDToPlaceID[selectedPlaceID] == nil || placeRepository == nil || visitRepository == nil else {
            return nil
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

    private func repositoryBackedPlaceStory(for pinID: String) throws -> PlaceStoryViewModel {
        guard
            let placeRepository,
            let visitRepository,
            let placeID = pinIDToPlaceID[pinID]
        else {
            throw TJAppError.invalidInput(message: "Missing place mapping for selected pin.")
        }

        guard let place = try placeRepository.fetchPlace(id: placeID) else {
            throw TJAppError.invalidInput(message: "Selected place no longer exists.")
        }

        let visits = try visitRepository.fetchVisits(forPlace: place.id)
        let rows = try visits.map { visit in
            let spots = try (spotRepository?.fetchSpots(forVisit: visit.id) ?? [])
                .map { spot in
                    VisitSpotRow(
                        id: spot.id.uuidString.lowercased(),
                        name: spot.name,
                        category: spot.category ?? "Spot",
                        ratingText: Self.ratingText(for: spot.rating),
                        note: spot.note
                    )
                }
            let photoCount = try mediaRepository?.fetchMedia(forVisit: visit.id).count ?? 0
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

    public var pinListItems: [PinListItem] {
        visiblePins
            .map { pin in
                let title = placeSearchMetadataByPinID[pin.id]?.title ?? pin.id.capitalized
                return PinListItem(id: pin.id, title: title)
            }
            .sorted { lhs, rhs in
                lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
    }

    static let defaultPins: [GlobePin] = [
        GlobePin(id: "paris", latitude: 48.8566, longitude: 2.3522),
        GlobePin(id: "tokyo", latitude: 35.6764, longitude: 139.6500),
        GlobePin(id: "lisbon", latitude: 38.7223, longitude: -9.1393)
    ]
}
