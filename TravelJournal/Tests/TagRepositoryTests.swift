import XCTest
@testable import TravelJournalData
@testable import TravelJournalDomain

final class TagRepositoryTests: XCTestCase {
    func testCreateAssignFetchAndRemoveTag() throws {
        let manager = try DatabaseManager(path: ":memory:")
        let placeRepository = GRDBPlaceRepository(dbQueue: manager.dbQueue)
        let visitRepository = GRDBVisitRepository(dbQueue: manager.dbQueue)
        let tagRepository = GRDBTagRepository(dbQueue: manager.dbQueue)

        let now = Date(timeIntervalSince1970: 1_706_600_000)
        let placeID = UUID()
        let visitID = UUID()

        try placeRepository.upsertPlace(
            Place(
                id: placeID,
                name: "Osaka",
                country: "Japan",
                latitude: 34.6937,
                longitude: 135.5023,
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
                summary: "Food tour",
                notes: nil,
                createdAt: now,
                updatedAt: now
            )
        )

        let tag = try tagRepository.createTag(named: "food")
        try tagRepository.assignTag(tagID: tag.id, toVisit: visitID)

        let tagsForVisit = try tagRepository.fetchTags(forVisit: visitID)
        XCTAssertEqual(tagsForVisit.map(\.name), ["food"])

        let placeIDsForTag = try tagRepository.fetchPlaceIDs(tagID: tag.id)
        XCTAssertEqual(placeIDsForTag, [placeID])

        try tagRepository.removeTag(tagID: tag.id, fromVisit: visitID)
        XCTAssertTrue(try tagRepository.fetchTags(forVisit: visitID).isEmpty)
    }

    func testCreateTagDeduplicatesByName() throws {
        let manager = try DatabaseManager(path: ":memory:")
        let tagRepository = GRDBTagRepository(dbQueue: manager.dbQueue)

        let first = try tagRepository.createTag(named: "beach")
        let second = try tagRepository.createTag(named: "beach")

        XCTAssertEqual(first.id, second.id)
        XCTAssertEqual(try tagRepository.fetchTags().count, 1)
    }
}
