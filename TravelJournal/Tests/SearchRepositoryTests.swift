import XCTest
@testable import TravelJournalData
@testable import TravelJournalDomain

final class SearchRepositoryTests: XCTestCase {
    func testSearchFindsPlaceVisitSpotAndTag() throws {
        let manager = try DatabaseManager(path: ":memory:")
        let placeRepository = GRDBPlaceRepository(dbQueue: manager.dbQueue)
        let visitRepository = GRDBVisitRepository(dbQueue: manager.dbQueue)
        let spotRepository = GRDBSpotRepository(dbQueue: manager.dbQueue)
        let tagRepository = GRDBTagRepository(dbQueue: manager.dbQueue)
        let searchRepository = GRDBSearchRepository(dbQueue: manager.dbQueue)

        let now = Date(timeIntervalSince1970: 1_707_500_000)
        let placeID = UUID()
        let visitID = UUID()

        try placeRepository.upsertPlace(
            Place(
                id: placeID,
                name: "Tokyo",
                country: "Japan",
                latitude: 35.6764,
                longitude: 139.65,
                createdAt: now,
                updatedAt: now
            )
        )

        try visitRepository.createVisit(
            Visit(
                id: visitID,
                placeID: placeID,
                tripID: nil,
                startDate: now,
                endDate: now.addingTimeInterval(86_400),
                summary: "Sushi night",
                notes: "Booked counterside seats",
                createdAt: now,
                updatedAt: now
            )
        )

        try spotRepository.addSpot(
            Spot(
                id: UUID(),
                visitID: visitID,
                name: "Tsukiji Walk",
                category: "food",
                latitude: nil,
                longitude: nil,
                address: nil,
                rating: 5,
                note: "Great sushi stalls",
                createdAt: now,
                updatedAt: now
            )
        )

        let tag = try tagRepository.createTag(named: "foodie")
        try tagRepository.assignTag(tagID: tag.id, toVisit: visitID)

        XCTAssertEqual(try searchRepository.search("tok", limit: 10).first?.kind, .place)
        XCTAssertEqual(try searchRepository.search("sushi", limit: 10).first?.kind, .visit)
        XCTAssertEqual(try searchRepository.search("stalls", limit: 10).first?.kind, .spot)
        XCTAssertEqual(try searchRepository.search("foodie", limit: 10).first?.kind, .tag)
    }

    func testSearchLimitIsAppliedDeterministically() throws {
        let manager = try DatabaseManager(path: ":memory:")
        let placeRepository = GRDBPlaceRepository(dbQueue: manager.dbQueue)
        let searchRepository = GRDBSearchRepository(dbQueue: manager.dbQueue)
        let now = Date(timeIntervalSince1970: 1_707_500_100)

        try placeRepository.upsertPlace(
            Place(
                id: UUID(),
                name: "Berlin",
                country: "Germany",
                latitude: 52.52,
                longitude: 13.405,
                createdAt: now,
                updatedAt: now
            )
        )
        try placeRepository.upsertPlace(
            Place(
                id: UUID(),
                name: "Bern",
                country: "Switzerland",
                latitude: 46.948,
                longitude: 7.4474,
                createdAt: now,
                updatedAt: now
            )
        )

        let results = try searchRepository.search("ber", limit: 1)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.kind, .place)
        XCTAssertEqual(results.first?.title, "Berlin")
    }
}
