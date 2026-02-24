import Foundation
import XCTest
@testable import TravelJournalData

final class SyncBatchMergingTests: XCTestCase {
    func testMergePrefersRemoteWhenNewerForSameRecordIdentity() {
        let id = UUID()
        let local = SyncRecordEnvelope(
            kind: .visit,
            id: id,
            updatedAt: Date(timeIntervalSince1970: 100),
            payload: Data("local".utf8)
        )
        let remote = SyncRecordEnvelope(
            kind: .visit,
            id: id,
            updatedAt: Date(timeIntervalSince1970: 200),
            payload: Data("remote".utf8)
        )

        let merged = SyncBatchMerging.mergeLastWriteWins(
            local: SyncBatch(records: [local]),
            remote: SyncBatch(records: [remote])
        )

        XCTAssertEqual(merged.records, [remote])
    }

    func testMergePrefersRemoteWhenTimestampsEqual() {
        let id = UUID()
        let timestamp = Date(timeIntervalSince1970: 300)

        let local = SyncRecordEnvelope(
            kind: .place,
            id: id,
            updatedAt: timestamp,
            payload: Data("local".utf8)
        )
        let remote = SyncRecordEnvelope(
            kind: .place,
            id: id,
            updatedAt: timestamp,
            payload: Data("remote".utf8)
        )

        let merged = SyncBatchMerging.mergeLastWriteWins(
            local: SyncBatch(records: [local]),
            remote: SyncBatch(records: [remote])
        )

        XCTAssertEqual(merged.records, [remote])
    }

    func testMergeKeepsDistinctRecordsAndSortsDeterministically() {
        let place = SyncRecordEnvelope(
            kind: .place,
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            updatedAt: Date(timeIntervalSince1970: 200),
            payload: Data("place".utf8)
        )
        let visit = SyncRecordEnvelope(
            kind: .visit,
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            updatedAt: Date(timeIntervalSince1970: 100),
            payload: Data("visit".utf8)
        )

        let merged = SyncBatchMerging.mergeLastWriteWins(
            local: SyncBatch(records: [visit]),
            remote: SyncBatch(records: [place])
        )

        XCTAssertEqual(merged.records, [place, visit])
    }
}
