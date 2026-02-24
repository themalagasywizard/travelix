import Foundation
import Combine
import TravelJournalData
import TravelJournalDomain

public struct AddVisitDraft: Equatable {
    public var locationQuery: String
    public var startDate: Date
    public var endDate: Date
    public var note: String
    public var photoItemCount: Int

    public init(
        locationQuery: String = "",
        startDate: Date = Date(),
        endDate: Date = Date(),
        note: String = "",
        photoItemCount: Int = 0
    ) {
        self.locationQuery = locationQuery
        self.startDate = startDate
        self.endDate = endDate
        self.note = note
        self.photoItemCount = photoItemCount
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
            case .location: return "Location"
            case .dates: return "Dates"
            case .content: return "Content"
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
                return "Please enter a location before saving."
            case .invalidDateRange:
                return "End date must be on or after start date."
            case .persistenceFailed:
                return "We couldn't save this visit. Please try again."
            }
        }
    }

    @Published public private(set) var currentStep: Step = .location
    @Published public private(set) var draft: AddVisitDraft
    @Published public private(set) var saveResult: AddVisitSaveResult?
    @Published public private(set) var saveError: SaveError?

    private let placeRepository: PlaceRepository?
    private let visitRepository: VisitRepository?
    private let now: () -> Date

    public init(
        draft: AddVisitDraft = .init(),
        placeRepository: PlaceRepository? = nil,
        visitRepository: VisitRepository? = nil,
        now: @escaping () -> Date = Date.init
    ) {
        self.draft = draft
        self.placeRepository = placeRepository
        self.visitRepository = visitRepository
        self.now = now
    }

    public func updateLocationQuery(_ query: String) {
        draft.locationQuery = query
    }

    public func updateDates(start: Date, end: Date) {
        draft.startDate = start
        draft.endDate = end
    }

    public func updateContent(note: String, photoItemCount: Int) {
        draft.note = note
        draft.photoItemCount = max(0, photoItemCount)
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

        let trimmedLocation = draft.locationQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedLocation.isEmpty == false else {
            saveError = .missingLocation
            return nil
        }

        guard draft.endDate >= draft.startDate else {
            saveError = .invalidDateRange
            return nil
        }

        let timestamp = now()
        let place = Place(
            id: UUID(),
            name: trimmedLocation,
            country: nil,
            latitude: 0,
            longitude: 0,
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
            let result = AddVisitSaveResult(place: place, visit: visit)
            saveResult = result
            return result
        } catch {
            saveError = .persistenceFailed
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
