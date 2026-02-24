import Foundation
import XCTest
@testable import TravelJournalData

final class CloudSyncEngineTests: XCTestCase {
    func testNoopEnginePushDoesNotThrow() async throws {
        let engine = NoopCloudSyncEngine()
        let record = SyncRecordEnvelope(
            kind: .visit,
            id: UUID(),
            updatedAt: Date(timeIntervalSince1970: 123),
            payload: Data("visit".utf8)
        )

        try await engine.push(localChanges: SyncBatch(records: [record]))
    }

    func testNoopEnginePullReturnsEmptyBatch() async throws {
        let engine = NoopCloudSyncEngine()

        let pulled = try await engine.pullChanges(since: Date(timeIntervalSince1970: 100))

        XCTAssertEqual(pulled, .empty)
    }
}
