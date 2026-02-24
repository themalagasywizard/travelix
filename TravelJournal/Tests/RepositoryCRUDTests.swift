import XCTest
@testable import TravelJournalData
@testable import TravelJournalDomain

final class RepositoryCRUDTests: XCTestCase {
    func testPlaceRepositoryUpsertFetchAndVisitCounts() throws {
        let manager = try DatabaseManager(path: ":memory:")
        let placeRepository = GRDBPlaceRepository(dbQueue: manager.dbQueue)
        let visitRepository = GRDBVisitRepository(dbQueue: manager.dbQueue)

        let now = Date(timeIntervalSince1970: 1_706_000_000)
        let parisID = UUID()
        let tokyoID = UUID()

        let paris = Place(id: parisID, name: "Paris", country: "France", latitude: 48.8566, longitude: 2.3522, createdAt: now, updatedAt: now)
        let tokyo = Place(id: tokyoID, name: "Tokyo", country: "Japan", latitude: 35.6764, longitude: 139.6500, createdAt: now, updatedAt: now)

        try placeRepository.upsertPlace(paris)
        try placeRepository.upsertPlace(tokyo)

        let visit = Visit(
            id: UUID(),
            placeID: parisID,
            tripID: nil,
            startDate: now,
            endDate: now.addingTimeInterval(3600),
            summary: "Weekend",
            notes: "Great food",
            createdAt: now,
            updatedAt: now
        )
        try visitRepository.createVisit(visit)

        let fetchedParis = try placeRepository.fetchPlace(id: parisID)
        XCTAssertEqual(fetchedParis?.name, "Paris")

        let rows = try placeRepository.fetchPlacesWithVisitCounts()
        XCTAssertEqual(rows.count, 2)

        let parisCount = rows.first(where: { $0.place.id == parisID })?.visitCount
        let tokyoCount = rows.first(where: { $0.place.id == tokyoID })?.visitCount
        XCTAssertEqual(parisCount, 1)
        XCTAssertEqual(tokyoCount, 0)
    }

    func testVisitRepositoryCRUDAndFetchByPlace() throws {
        let manager = try DatabaseManager(path: ":memory:")
        let placeRepository = GRDBPlaceRepository(dbQueue: manager.dbQueue)
        let visitRepository = GRDBVisitRepository(dbQueue: manager.dbQueue)

        let now = Date(timeIntervalSince1970: 1_706_500_000)
        let placeID = UUID()

        let place = Place(id: placeID, name: "Lisbon", country: "Portugal", latitude: 38.7223, longitude: -9.1393, createdAt: now, updatedAt: now)
        try placeRepository.upsertPlace(place)

        let visitID = UUID()
        var visit = Visit(
            id: visitID,
            placeID: placeID,
            tripID: nil,
            startDate: now,
            endDate: now.addingTimeInterval(86_400),
            summary: "Initial",
            notes: "Note 1",
            createdAt: now,
            updatedAt: now
        )

        try visitRepository.createVisit(visit)
        var visits = try visitRepository.fetchVisits(forPlace: placeID)
        XCTAssertEqual(visits.count, 1)
        XCTAssertEqual(visits.first?.summary, "Initial")

        visit.summary = "Updated"
        visit.notes = "Note 2"
        visit.updatedAt = now.addingTimeInterval(100)
        try visitRepository.updateVisit(visit)

        visits = try visitRepository.fetchVisits(forPlace: placeID)
        XCTAssertEqual(visits.first?.summary, "Updated")
        XCTAssertEqual(visits.first?.notes, "Note 2")

        try visitRepository.deleteVisit(id: visitID)
        visits = try visitRepository.fetchVisits(forPlace: placeID)
        XCTAssertTrue(visits.isEmpty)
    }
}
