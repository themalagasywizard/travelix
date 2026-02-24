import XCTest
@testable import TravelJournalData
@testable import TravelJournalDomain

final class MediaRepositoryTests: XCTestCase {
    func testMediaRepositoryCRUD() throws {
        let manager = try DatabaseManager(path: ":memory:")
        let placeRepository = GRDBPlaceRepository(dbQueue: manager.dbQueue)
        let visitRepository = GRDBVisitRepository(dbQueue: manager.dbQueue)
        let mediaRepository = GRDBMediaRepository(dbQueue: manager.dbQueue)

        let now = Date(timeIntervalSince1970: 1_707_200_000)
        let placeID = UUID()
        let visitID = UUID()

        let place = Place(id: placeID, name: "Rome", country: "Italy", latitude: 41.9028, longitude: 12.4964, createdAt: now, updatedAt: now)
        try placeRepository.upsertPlace(place)

        let visit = Visit(
            id: visitID,
            placeID: placeID,
            tripID: nil,
            startDate: now,
            endDate: now.addingTimeInterval(86_400),
            summary: "Roman weekend",
            notes: nil,
            createdAt: now,
            updatedAt: now
        )
        try visitRepository.createVisit(visit)

        let mediaID = UUID()
        var media = Media(
            id: mediaID,
            visitID: visitID,
            localIdentifier: "ph://asset-1",
            fileURL: "file:///tmp/rome.jpg",
            width: 2000,
            height: 1500,
            createdAt: now,
            updatedAt: now
        )

        try mediaRepository.addMedia(media)

        var fetched = try mediaRepository.fetchMedia(forVisit: visitID)
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.localIdentifier, "ph://asset-1")

        media.fileURL = "file:///tmp/rome-updated.jpg"
        media.updatedAt = now.addingTimeInterval(120)
        try mediaRepository.updateMedia(media)

        let fetchedSingle = try mediaRepository.fetchMedia(id: mediaID)
        XCTAssertEqual(fetchedSingle?.fileURL, "file:///tmp/rome-updated.jpg")

        try mediaRepository.deleteMedia(id: mediaID)
        fetched = try mediaRepository.fetchMedia(forVisit: visitID)
        XCTAssertTrue(fetched.isEmpty)
    }

    func testImportMediaCreatesRecordFromPayload() throws {
        let manager = try DatabaseManager(path: ":memory:")
        let placeRepository = GRDBPlaceRepository(dbQueue: manager.dbQueue)
        let visitRepository = GRDBVisitRepository(dbQueue: manager.dbQueue)
        let mediaRepository = GRDBMediaRepository(dbQueue: manager.dbQueue)

        let now = Date(timeIntervalSince1970: 1_707_300_000)
        let placeID = UUID()
        let visitID = UUID()

        try placeRepository.upsertPlace(
            Place(
                id: placeID,
                name: "Kyoto",
                country: "Japan",
                latitude: 35.0116,
                longitude: 135.7681,
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
                summary: nil,
                notes: nil,
                createdAt: now,
                updatedAt: now
            )
        )

        let imported = try mediaRepository.importMedia(
            from: MediaImportPayload(
                localIdentifier: "ph://asset-kyoto-1",
                fileURL: "file:///tmp/kyoto-1.jpg",
                width: 3024,
                height: 4032
            ),
            forVisit: visitID,
            importedAt: now.addingTimeInterval(30)
        )

        let fetched = try mediaRepository.fetchMedia(id: imported.id)
        XCTAssertEqual(fetched?.visitID, visitID)
        XCTAssertEqual(fetched?.localIdentifier, "ph://asset-kyoto-1")
        XCTAssertEqual(fetched?.fileURL, "file:///tmp/kyoto-1.jpg")
        XCTAssertEqual(fetched?.width, 3024)
        XCTAssertEqual(fetched?.height, 4032)
    }
}
