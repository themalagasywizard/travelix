import Foundation
import Combine
import TravelJournalCore
import TravelJournalData
import TravelJournalDomain

@MainActor
public final class VisitSpotsEditorViewModel: ObservableObject {
    @Published public private(set) var spots: [VisitSpotRow] = []
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var errorBanner: ErrorBannerModel?

    private let visitID: UUID
    private let repository: SpotRepository

    public init(visitID: UUID, repository: SpotRepository) {
        self.visitID = visitID
        self.repository = repository
    }

    public func loadSpots() {
        do {
            let loaded = try repository.fetchSpots(forVisit: visitID)
            spots = loaded.map(Self.mapSpot)
            errorMessage = nil
            errorBanner = nil
        } catch {
            setError(message: TJStrings.SpotsEditor.failedToLoadSpots(error.localizedDescription), appError: .databaseFailure)
        }
    }

    public func addSpot(name: String, category: String, note: String?) {
        let now = Date()
        let spot = Spot(
            id: UUID(),
            visitID: visitID,
            name: name,
            category: category,
            latitude: nil,
            longitude: nil,
            address: nil,
            rating: nil,
            note: note,
            createdAt: now,
            updatedAt: now
        )

        do {
            try repository.addSpot(spot)
            loadSpots()
        } catch {
            setError(message: TJStrings.SpotsEditor.failedToAddSpot(error.localizedDescription), appError: .databaseFailure)
        }
    }

    public func updateSpot(id: String, name: String, category: String, note: String?) {
        guard let uuid = UUID(uuidString: id) else {
            setError(message: TJStrings.SpotsEditor.invalidSpotID, appError: .invalidInput(message: TJStrings.SpotsEditor.spotReferenceInvalid))
            return
        }

        do {
            let existing = try repository.fetchSpots(forVisit: visitID).first(where: { $0.id == uuid })
            guard var spot = existing else {
                setError(message: TJStrings.SpotsEditor.spotNotFound, appError: .invalidInput(message: TJStrings.SpotsEditor.selectedSpotMissing))
                return
            }

            spot.name = name
            spot.category = category
            spot.note = note
            spot.updatedAt = Date()

            try repository.updateSpot(spot)
            loadSpots()
        } catch {
            setError(message: TJStrings.SpotsEditor.failedToUpdateSpot(error.localizedDescription), appError: .databaseFailure)
        }
    }

    public func deleteSpot(id: String) {
        guard let uuid = UUID(uuidString: id) else {
            setError(message: TJStrings.SpotsEditor.invalidSpotID, appError: .invalidInput(message: TJStrings.SpotsEditor.spotReferenceInvalid))
            return
        }

        do {
            try repository.deleteSpot(id: uuid)
            loadSpots()
        } catch {
            setError(message: TJStrings.SpotsEditor.failedToDeleteSpot(error.localizedDescription), appError: .databaseFailure)
        }
    }

    private func setError(message: String, appError: TJAppError) {
        errorMessage = message
        errorBanner = ErrorPresentationMapper.banner(for: appError)
    }

    private static func mapSpot(_ spot: Spot) -> VisitSpotRow {
        VisitSpotRow(
            id: spot.id.uuidString,
            name: spot.name,
            category: spot.category ?? TJStrings.SpotsEditor.defaultCategory,
            ratingText: spot.rating.map(TJStrings.SpotsEditor.ratingOutOfFive),
            note: spot.note
        )
    }
}
