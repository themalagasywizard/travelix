import XCTest
@testable import TravelJournalData
@testable import TravelJournalDomain
@testable import TravelJournalUI

@MainActor
final class TripsListViewModelTests: XCTestCase {
    func testLoadTripsBuildsRowsWithVisitCounts() {
        let tripAID = UUID()
        let tripBID = UUID()
        let now = Date(timeIntervalSince1970: 1_708_000_000)

        let tripRepository = MockTripRepository(trips: [
            Trip(id: tripAID, name: "Japan 2025", startDate: now, endDate: now.addingTimeInterval(5 * 86_400), coverMediaID: nil, createdAt: now, updatedAt: now),
            Trip(id: tripBID, name: "Lisbon Weekend", startDate: nil, endDate: nil, coverMediaID: nil, createdAt: now, updatedAt: now)
        ])
        let visitRepository = MockVisitRepository(visitsByTripID: [
            tripAID: [Self.makeVisit(tripID: tripAID), Self.makeVisit(tripID: tripAID)],
            tripBID: [Self.makeVisit(tripID: tripBID)]
        ])

        let viewModel = TripsListViewModel(tripRepository: tripRepository, visitRepository: visitRepository)

        viewModel.loadTrips()

        XCTAssertEqual(viewModel.rows.count, 2)
        XCTAssertEqual(viewModel.rows[0].title, "Japan 2025")
        XCTAssertEqual(viewModel.rows[0].visitCountText, "2 visits")
        XCTAssertEqual(viewModel.rows[1].title, "Lisbon Weekend")
        XCTAssertEqual(viewModel.rows[1].visitCountText, "1 visit")
        XCTAssertEqual(viewModel.rows[1].dateRangeText, "Dates TBD")
        XCTAssertNil(viewModel.errorBanner)
    }

    func testLoadTripsFailurePublishesErrorBanner() {
        let tripRepository = ThrowingTripRepository()
        let visitRepository = MockVisitRepository(visitsByTripID: [:])
        let viewModel = TripsListViewModel(tripRepository: tripRepository, visitRepository: visitRepository)

        viewModel.loadTrips()

        XCTAssertTrue(viewModel.rows.isEmpty)
        XCTAssertEqual(viewModel.errorBanner?.title, "Something went wrong")
    }

    private static func makeVisit(tripID: UUID) -> Visit {
        let now = Date(timeIntervalSince1970: 1_708_100_000)
        return Visit(
            id: UUID(),
            placeID: UUID(),
            tripID: tripID,
            startDate: now,
            endDate: now,
            summary: nil,
            notes: nil,
            createdAt: now,
            updatedAt: now
        )
    }
}

private struct MockTripRepository: TripRepository {
    let trips: [Trip]

    func createTrip(_ trip: Trip) throws {}
    func updateTrip(_ trip: Trip) throws {}
    func fetchTrips() throws -> [Trip] { trips }
    func fetchTrip(id: UUID) throws -> Trip? { trips.first(where: { $0.id == id }) }
}

private struct ThrowingTripRepository: TripRepository {
    func createTrip(_ trip: Trip) throws {}
    func updateTrip(_ trip: Trip) throws {}
    func fetchTrips() throws -> [Trip] { throw NSError(domain: "TripsListViewModelTests", code: 1) }
    func fetchTrip(id: UUID) throws -> Trip? { nil }
}

private struct MockVisitRepository: VisitRepository {
    let visitsByTripID: [UUID: [Visit]]

    func createVisit(_ visit: Visit) throws {}
    func updateVisit(_ visit: Visit) throws {}
    func deleteVisit(id: UUID) throws {}
    func fetchVisits(forPlace placeID: UUID) throws -> [Visit] { [] }
    func fetchVisits(forTrip tripID: UUID) throws -> [Visit] { visitsByTripID[tripID] ?? [] }
    func fetchVisit(id: UUID) throws -> Visit? { nil }
}
