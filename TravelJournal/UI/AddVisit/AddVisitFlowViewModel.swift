import Foundation
import Combine
import TravelJournalCore
import TravelJournalData
import TravelJournalDomain

public struct AddVisitResolvedLocation: Equatable {
    public let displayName: String
    public let country: String?
    public let latitude: Double
    public let longitude: Double

    public init(
        displayName: String,
        country: String? = nil,
        latitude: Double,
        longitude: Double
    ) {
        self.displayName = displayName
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }
}

public protocol AddVisitCurrentLocationProviding {
    func resolveCurrentLocation() async throws -> AddVisitResolvedLocation
}

public enum AddVisitCurrentLocationError: LocalizedError {
    case unavailable

    public var errorDescription: String? {
        switch self {
        case .unavailable:
            return TJStrings.AddVisit.currentLocationUnavailable
        }
    }
}

public struct AddVisitNoopCurrentLocationProvider: AddVisitCurrentLocationProviding {
    public init() {}

    public func resolveCurrentLocation() async throws -> AddVisitResolvedLocation {
        throw AddVisitCurrentLocationError.unavailable
    }
}

public struct AddVisitDraft: Equatable {
    public var locationQuery: String
    public var startDate: Date
    public var endDate: Date
    public var note: String
    public var photoItemCount: Int
    public var mediaImportPayloads: [MediaImportPayload]

    public init(
        locationQuery: String = "",
        startDate: Date = Date(),
        endDate: Date = Date(),
        note: String = "",
        photoItemCount: Int = 0,
        mediaImportPayloads: [MediaImportPayload] = []
    ) {
        self.locationQuery = locationQuery
        self.startDate = startDate
        self.endDate = endDate
        self.note = note
        self.photoItemCount = photoItemCount
        self.mediaImportPayloads = mediaImportPayloads
    }
}

public struct AddVisitSaveResult: Equatable {
    public let place: Place
    public let visit: Visit

    public init(place: Place, visit: Visit) {
        self.place = place
        self.visit = visit
    }
}

@MainActor
public final class AddVisitFlowViewModel: ObservableObject {
    public enum Step: Int, CaseIterable {
        case location
        case dates
        case content

        public var title: String {
            switch self {
            case .location: return TJStrings.AddVisit.stepLocationTitle
            case .dates: return TJStrings.AddVisit.stepDatesTitle
            case .content: return TJStrings.AddVisit.stepContentTitle
            }
        }
    }

    public enum SaveError: LocalizedError, Equatable {
        case missingLocation
        case invalidDateRange
        case persistenceFailed

        public var errorDescription: String? {
            switch self {
            case .missingLocation:
                return TJStrings.AddVisit.missingLocationError
            case .invalidDateRange:
                return TJStrings.AddVisit.invalidDateRangeError
            case .persistenceFailed:
                return TJStrings.AddVisit.persistenceFailedError
            }
        }
    }

    @Published public private(set) var currentStep: Step = .location
    @Published public private(set) var draft: AddVisitDraft
    @Published public private(set) var saveResult: AddVisitSaveResult?
    @Published public private(set) var saveError: SaveError?
    @Published public private(set) var errorBanner: ErrorBannerModel?
    @Published public private(set) var isResolvingCurrentLocation: Bool = false

    private let placeRepository: PlaceRepository?
    private let visitRepository: VisitRepository?
    private let mediaRepository: MediaRepository?
    private let locationProvider: AddVisitCurrentLocationProviding?
    private let hapticsClient: HapticsClient
    private let now: () -> Date
    private var resolvedLocation: AddVisitResolvedLocation?

    public init(
        draft: AddVisitDraft = .init(),
        placeRepository: PlaceRepository? = nil,
        visitRepository: VisitRepository? = nil,
        mediaRepository: MediaRepository? = nil,
        locationProvider: AddVisitCurrentLocationProviding? = nil,
        hapticsClient: HapticsClient = HapticsClient(),
        now: @escaping () -> Date = Date.init
    ) {
        self.draft = draft
        self.placeRepository = placeRepository
        self.visitRepository = visitRepository
        self.mediaRepository = mediaRepository
        self.locationProvider = locationProvider
        self.hapticsClient = hapticsClient
        self.now = now
    }

    public func updateLocationQuery(_ query: String) {
        draft.locationQuery = query
        resolvedLocation = nil
    }

    public func useCurrentLocation() async {
        guard let locationProvider else {
            errorBanner = ErrorPresentationMapper.banner(
                for: .invalidInput(message: AddVisitCurrentLocationError.unavailable.errorDescription ?? TJStrings.AddVisit.currentLocationUnavailable)
            )
            hapticsClient.notifyWarning()
            return
        }

        isResolvingCurrentLocation = true
        defer { isResolvingCurrentLocation = false }

        do {
            let location = try await locationProvider.resolveCurrentLocation()
            resolvedLocation = location
            draft.locationQuery = location.displayName
            errorBanner = nil
        } catch {
            errorBanner = ErrorPresentationMapper.banner(
                for: .invalidInput(message: error.localizedDescription)
            )
            hapticsClient.notifyWarning()
        }
    }

    public func updateDates(start: Date, end: Date) {
        draft.startDate = start
        draft.endDate = end
    }

    public func updateContent(note: String, photoItemCount: Int) {
        draft.note = note
        draft.photoItemCount = max(0, photoItemCount)
    }

    public func updateSelectedMediaPayloads(_ payloads: [MediaImportPayload]) {
        draft.mediaImportPayloads = payloads
        draft.photoItemCount = payloads.count
    }

    public func goNext() {
        guard let next = Step(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = next
    }

    public func goBack() {
        guard let previous = Step(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = previous
    }

    @discardableResult
    public func saveVisit() -> AddVisitSaveResult? {
        saveError = nil
        saveResult = nil
        errorBanner = nil

        let trimmedLocation = draft.locationQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedLocation.isEmpty == false else {
            saveError = .missingLocation
            errorBanner = ErrorPresentationMapper.banner(for: .invalidInput(message: SaveError.missingLocation.errorDescription ?? TJStrings.AddVisit.missingLocationError))
            hapticsClient.notifyWarning()
            return nil
        }

        guard draft.endDate >= draft.startDate else {
            saveError = .invalidDateRange
            errorBanner = ErrorPresentationMapper.banner(for: .invalidInput(message: SaveError.invalidDateRange.errorDescription ?? TJStrings.AddVisit.invalidDateRangeError))
            hapticsClient.notifyWarning()
            return nil
        }

        let timestamp = now()
        let place = Place(
            id: UUID(),
            name: trimmedLocation,
            country: resolvedLocation?.country,
            latitude: resolvedLocation?.latitude ?? 0,
            longitude: resolvedLocation?.longitude ?? 0,
            createdAt: timestamp,
            updatedAt: timestamp
        )

        let trimmedNotes = draft.note.trimmingCharacters(in: .whitespacesAndNewlines)
        let summary = trimmedNotes.isEmpty ? nil : String(trimmedNotes.prefix(120))
        let visit = Visit(
            id: UUID(),
            placeID: place.id,
            tripID: nil,
            startDate: draft.startDate,
            endDate: draft.endDate,
            summary: summary,
            notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
            createdAt: timestamp,
            updatedAt: timestamp
        )

        do {
            try placeRepository?.upsertPlace(place)
            try visitRepository?.createVisit(visit)
            try draft.mediaImportPayloads.forEach { payload in
                _ = try mediaRepository?.importMedia(from: payload, forVisit: visit.id, importedAt: timestamp)
            }

            let result = AddVisitSaveResult(place: place, visit: visit)
            saveResult = result
            hapticsClient.notifySuccess()
            return result
        } catch {
            saveError = .persistenceFailed
            errorBanner = ErrorPresentationMapper.banner(for: .databaseFailure)
            hapticsClient.notifyError()
            return nil
        }
    }

    public var canGoBack: Bool {
        currentStep != .location
    }

    public var isLastStep: Bool {
        currentStep == .content
    }
}
