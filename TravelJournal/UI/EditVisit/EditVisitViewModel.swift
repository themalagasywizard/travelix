import Foundation
import Combine
import TravelJournalCore
import TravelJournalData
import TravelJournalDomain

@MainActor
public final class EditVisitViewModel: ObservableObject {
    @Published public private(set) var visitID: String
    @Published public var locationName: String
    @Published public var startDate: Date
    @Published public var endDate: Date
    @Published public var summary: String
    @Published public var notes: String
    @Published public private(set) var saveErrorBanner: ErrorBannerModel?

    private var persistedVisitContext: PersistedVisitContext?
    private let hapticsClient: HapticsClient

    private struct PersistedVisitContext {
        let visitID: UUID
        let placeID: UUID
        let tripID: UUID?
        let createdAt: Date
        let repository: VisitRepository
    }

    public init(
        visitID: String,
        locationName: String,
        startDate: Date,
        endDate: Date,
        summary: String,
        notes: String,
        hapticsClient: HapticsClient = HapticsClient()
    ) {
        self.visitID = visitID
        self.locationName = locationName
        self.startDate = startDate
        self.endDate = endDate
        self.summary = summary
        self.notes = notes
        self.persistedVisitContext = nil
        self.hapticsClient = hapticsClient
    }

    public convenience init(
        visit: Visit,
        locationName: String,
        repository: VisitRepository,
        hapticsClient: HapticsClient = HapticsClient()
    ) {
        self.init(
            visitID: visit.id.uuidString.lowercased(),
            locationName: locationName,
            startDate: visit.startDate,
            endDate: visit.endDate,
            summary: visit.summary ?? "",
            notes: visit.notes ?? "",
            hapticsClient: hapticsClient
        )

        self.persistedVisitContext = PersistedVisitContext(
            visitID: visit.id,
            placeID: visit.placeID,
            tripID: visit.tripID,
            createdAt: visit.createdAt,
            repository: repository
        )
    }

    public func applyEdits(
        locationName: String,
        startDate: Date,
        endDate: Date,
        summary: String,
        notes: String
    ) {
        self.locationName = locationName
        self.startDate = startDate
        self.endDate = endDate
        self.summary = summary
        self.notes = notes
        saveErrorBanner = nil
    }

    public var hasValidDateRange: Bool {
        endDate >= startDate
    }

    public var dateValidationBanner: ErrorBannerModel? {
        guard hasValidDateRange == false else { return nil }
        return ErrorPresentationMapper.banner(
            for: .invalidInput(message: TJStrings.EditVisit.invalidDateRangeError)
        )
    }

    @discardableResult
    public func saveChanges() -> Bool {
        guard hasValidDateRange else {
            hapticsClient.notifyWarning()
            return false
        }
        guard let persistedVisitContext else {
            saveErrorBanner = nil
            hapticsClient.notifySuccess()
            return true
        }

        let now = Date()
        let updatedVisit = Visit(
            id: persistedVisitContext.visitID,
            placeID: persistedVisitContext.placeID,
            tripID: persistedVisitContext.tripID,
            startDate: startDate,
            endDate: endDate,
            summary: summary.isEmpty ? nil : summary,
            notes: notes.isEmpty ? nil : notes,
            createdAt: persistedVisitContext.createdAt,
            updatedAt: now
        )

        do {
            try persistedVisitContext.repository.updateVisit(updatedVisit)
            saveErrorBanner = nil
            hapticsClient.notifySuccess()
            return true
        } catch {
            saveErrorBanner = ErrorPresentationMapper.banner(for: .databaseFailure)
            hapticsClient.notifyError()
            return false
        }
    }
}
