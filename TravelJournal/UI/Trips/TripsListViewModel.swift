import Foundation
import TravelJournalCore
import TravelJournalData
import TravelJournalDomain

public struct TripListRow: Identifiable, Equatable {
    public let id: UUID
    public let title: String
    public let dateRangeText: String
    public let visitCountText: String

    public init(id: UUID, title: String, dateRangeText: String, visitCountText: String) {
        self.id = id
        self.title = title
        self.dateRangeText = dateRangeText
        self.visitCountText = visitCountText
    }
}

@MainActor
public final class TripsListViewModel: ObservableObject {
    @Published public private(set) var rows: [TripListRow] = []
    @Published public private(set) var errorBanner: ErrorBannerModel?

    private let tripRepository: TripRepository
    private let visitRepository: VisitRepository

    public init(tripRepository: TripRepository, visitRepository: VisitRepository) {
        self.tripRepository = tripRepository
        self.visitRepository = visitRepository
    }

    public func loadTrips() {
        do {
            let trips = try tripRepository.fetchTrips()
            rows = try trips.map { trip in
                let visitCount = try visitRepository.fetchVisits(forTrip: trip.id).count
                return TripListRow(
                    id: trip.id,
                    title: trip.name,
                    dateRangeText: Self.dateRangeText(startDate: trip.startDate, endDate: trip.endDate),
                    visitCountText: "\(visitCount) visit\(visitCount == 1 ? "" : "s")"
                )
            }
            errorBanner = nil
        } catch {
            rows = []
            errorBanner = ErrorPresentationMapper.banner(for: .databaseFailure)
        }
    }

    private static func dateRangeText(startDate: Date?, endDate: Date?) -> String {
        switch (startDate, endDate) {
        case let (start?, end?):
            return dateIntervalFormatter.string(from: start, to: end)
        case let (start?, nil):
            return singleDateFormatter.string(from: start)
        case let (nil, end?):
            return singleDateFormatter.string(from: end)
        case (nil, nil):
            return "Dates TBD"
        }
    }

    private static let dateIntervalFormatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static let singleDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
