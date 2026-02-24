import XCTest
@testable import TravelJournalData
@testable import TravelJournalDomain

final class TripAndSpotRepositoryTests: XCTestCase {
    func testTripRepositoryCreateUpdateAndFetch() throws {
        let manager = try DatabaseManager(path: ":memory:")
        let tripRepository = GRDBTripRepository(dbQueue: manager.dbQueue)

        let now = Date(timeIntervalSince1970: 1_707_000_000)
        let tripID = UUID()

        var trip = Trip(
            id: tripID,
            name: "Japan 2025",
            startDate: now,
            endDate: now.addingTimeInterval(7 * 86_400),
            coverMediaID: nil,
            createdAt: now,
            updatedAt: now
        )

        try tripRepository.createTrip(trip)

        let fetched = try tripRepository.fetchTrip(id: tripID)
        XCTAssertEqual(fetched?.name, "Japan 2025")

        trip.name = "Japan Spring 2025"
        trip.updatedAt = now.addingTimeInterval(120)
        try tripRepository.updateTrip(trip)

        let all = try tripRepository.fetchTrips()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.name, "Japan Spring 2025")
    }

    func testSpotRepositoryCRUD() throws {
        let manager = try DatabaseManager(path: ":memory:")
        let placeRepository = GRDBPlaceRepository(dbQueue: manager.dbQueue)
        let visitRepository = GRDBVisitRepository(dbQueue: manager.dbQueue)
        let spotRepository = GRDBSpotRepository(dbQueue: manager.dbQueue)

        let now = Date(timeIntervalSince1970: 1_707_100_000)
        let placeID = UUID()
        let visitID = UUID()

        let place = Place(id: placeID, name: "Seoul", country: "Korea", latitude: 37.5665, longitude: 126.9780, createdAt: now, updatedAt: now)
        try placeRepository.upsertPlace(place)

        let visit = Visit(
            id: visitID,
            placeID: placeID,
            tripID: nil,
            startDate: now,
            endDate: now.addingTimeInterval(86_400),
            summary: nil,
            notes: nil,
            createdAt: now,
            updatedAt: now
        )
        try visitRepository.createVisit(visit)

        let spotID = UUID()
        var spot = Spot(
            id: spotID,
            visitID: visitID,
            name: "Gwangjang Market",
            category: "food",
            latitude: 37.5704,
            longitude: 126.9998,
            address: "88 Changgyeonggung-ro",
            rating: 5,
            note: "Great bindaetteok",
            createdAt: now,
            updatedAt: now
        )

        try spotRepository.addSpot(spot)

        var spots = try spotRepository.fetchSpots(forVisit: visitID)
        XCTAssertEqual(spots.count, 1)
        XCTAssertEqual(spots.first?.name, "Gwangjang Market")

        spot.note = "Try kalguksu too"
        spot.updatedAt = now.addingTimeInterval(90)
        try spotRepository.updateSpot(spot)

        spots = try spotRepository.fetchSpots(forVisit: visitID)
        XCTAssertEqual(spots.first?.note, "Try kalguksu too")

        try spotRepository.deleteSpot(id: spotID)
        spots = try spotRepository.fetchSpots(forVisit: visitID)
        XCTAssertTrue(spots.isEmpty)
    }
}
