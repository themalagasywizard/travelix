import XCTest
@testable import TravelJournalCore
@testable import TravelJournalData
@testable import TravelJournalDomain

final class OfflineVisitValidatorTests: XCTestCase {
    func testValidateVisitReportsMissingThumbnails() throws {
        let manager = try DatabaseManager(path: ":memory:")
        let placeRepository = GRDBPlaceRepository(dbQueue: manager.dbQueue)
        let visitRepository = GRDBVisitRepository(dbQueue: manager.dbQueue)
        let mediaRepository = GRDBMediaRepository(dbQueue: manager.dbQueue)

        let root = FileManager.default.temporaryDirectory.appendingPathComponent("traveljournal-offline-validation-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let thumbnailCache = try DefaultThumbnailCache(rootDirectory: root)

        let now = Date(timeIntervalSince1970: 1_707_400_000)
        let placeID = UUID()
        let visitID = UUID()

        try placeRepository.upsertPlace(
            Place(
                id: placeID,
                name: "Berlin",
                country: "Germany",
                latitude: 52.52,
                longitude: 13.405,
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

        let mediaA = try mediaRepository.importMedia(
            from: MediaImportPayload(localIdentifier: "ph://a", fileURL: "file:///tmp/a.jpg", width: 1000, height: 800),
            forVisit: visitID,
            importedAt: now
        )
        let mediaB = try mediaRepository.importMedia(
            from: MediaImportPayload(localIdentifier: "ph://b", fileURL: "file:///tmp/b.jpg", width: 1000, height: 800),
            forVisit: visitID,
            importedAt: now
        )

        try thumbnailCache.store(Data([0x01]), for: ThumbnailRequest(mediaID: mediaA.id, pixelSize: 512))
        try thumbnailCache.store(Data([0x02]), for: ThumbnailRequest(mediaID: mediaA.id, pixelSize: 1024))
        try thumbnailCache.store(Data([0x03]), for: ThumbnailRequest(mediaID: mediaB.id, pixelSize: 512))

        let validator = OfflineVisitValidator(mediaRepository: mediaRepository, thumbnailCache: thumbnailCache)
        let report = try validator.validateVisit(visitID, requiredThumbnailSizes: [512, 1024])

        XCTAssertFalse(report.isOfflineReady)
        XCTAssertEqual(report.totalMediaCount, 2)
        XCTAssertEqual(report.fullyCachedMediaCount, 1)
        XCTAssertEqual(report.missingThumbnailRequests, [ThumbnailRequest(mediaID: mediaB.id, pixelSize: 1024)])
    }

    func testValidateVisitPassesWhenAllThumbnailsExist() throws {
        let manager = try DatabaseManager(path: ":memory:")
        let placeRepository = GRDBPlaceRepository(dbQueue: manager.dbQueue)
        let visitRepository = GRDBVisitRepository(dbQueue: manager.dbQueue)
        let mediaRepository = GRDBMediaRepository(dbQueue: manager.dbQueue)

        let root = FileManager.default.temporaryDirectory.appendingPathComponent("traveljournal-offline-validation-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let thumbnailCache = try DefaultThumbnailCache(rootDirectory: root)

        let now = Date(timeIntervalSince1970: 1_707_400_100)
        let placeID = UUID()
        let visitID = UUID()

        try placeRepository.upsertPlace(
            Place(
                id: placeID,
                name: "Prague",
                country: "Czechia",
                latitude: 50.0755,
                longitude: 14.4378,
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

        let media = try mediaRepository.importMedia(
            from: MediaImportPayload(localIdentifier: "ph://p1", fileURL: "file:///tmp/p1.jpg", width: 1000, height: 800),
            forVisit: visitID,
            importedAt: now
        )

        try thumbnailCache.store(Data([0x01]), for: ThumbnailRequest(mediaID: media.id, pixelSize: 512))

        let validator = OfflineVisitValidator(mediaRepository: mediaRepository, thumbnailCache: thumbnailCache)
        let report = try validator.validateVisit(visitID)

        XCTAssertTrue(report.isOfflineReady)
        XCTAssertEqual(report.totalMediaCount, 1)
        XCTAssertEqual(report.fullyCachedMediaCount, 1)
        XCTAssertTrue(report.missingThumbnailRequests.isEmpty)
    }
}
