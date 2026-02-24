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

    func testInMemorySharedEngineReplicatesBetweenPeers() async throws {
        let storage = InMemoryCloudSyncStorage()
        let clock = TestClock(times: [100, 120])
        let engineA = InMemoryCloudSyncEngine(storage: storage, now: clock.next)
        let engineB = InMemoryCloudSyncEngine(storage: storage, now: clock.next)

        let placeID = UUID()
        let record = SyncRecordEnvelope(
            kind: .place,
            id: placeID,
            updatedAt: Date(timeIntervalSince1970: 42),
            payload: Data("paris".utf8)
        )

        try await engineA.push(localChanges: SyncBatch(records: [record]))

        let pulled = try await engineB.pullChanges(since: nil)

        XCTAssertEqual(pulled.records, [record])
    }

    func testInMemorySharedEngineRespectsCursorAndDeterministicMerge() async throws {
        let storage = InMemoryCloudSyncStorage()
        let clock = TestClock(times: [100, 120, 130])
        let engineA = InMemoryCloudSyncEngine(storage: storage, now: clock.next)
        let engineB = InMemoryCloudSyncEngine(storage: storage, now: clock.next)

        let sharedID = UUID()

        let oldRecord = SyncRecordEnvelope(
            kind: .visit,
            id: sharedID,
            updatedAt: Date(timeIntervalSince1970: 10),
            payload: Data("old".utf8)
        )
        let newerRecord = SyncRecordEnvelope(
            kind: .visit,
            id: sharedID,
            updatedAt: Date(timeIntervalSince1970: 20),
            payload: Data("new".utf8)
        )
        let sameTimestampButLowerPayload = SyncRecordEnvelope(
            kind: .visit,
            id: sharedID,
            updatedAt: Date(timeIntervalSince1970: 20),
            payload: Data("aaa".utf8)
        )

        try await engineA.push(localChanges: SyncBatch(records: [oldRecord]))
        try await engineB.push(localChanges: SyncBatch(records: [newerRecord]))
        try await engineA.push(localChanges: SyncBatch(records: [sameTimestampButLowerPayload]))

        let pulledSinceInitialPush = try await engineB.pullChanges(since: Date(timeIntervalSince1970: 100))

        XCTAssertEqual(pulledSinceInitialPush.records, [newerRecord])
    }

    func testInMemorySharedEnginePrefersTombstoneForEqualTimestamps() async throws {
        let storage = InMemoryCloudSyncStorage()
        let clock = TestClock(times: [100, 110])
        let engineA = InMemoryCloudSyncEngine(storage: storage, now: clock.next)
        let engineB = InMemoryCloudSyncEngine(storage: storage, now: clock.next)

        let sharedID = UUID()
        let liveRecord = SyncRecordEnvelope(
            kind: .spot,
            id: sharedID,
            updatedAt: Date(timeIntervalSince1970: 200),
            payload: Data("live".utf8),
            isDeleted: false
        )
        let tombstoneRecord = SyncRecordEnvelope(
            kind: .spot,
            id: sharedID,
            updatedAt: Date(timeIntervalSince1970: 200),
            payload: Data(),
            isDeleted: true
        )

        try await engineA.push(localChanges: SyncBatch(records: [liveRecord]))
        try await engineB.push(localChanges: SyncBatch(records: [tombstoneRecord]))

        let pulled = try await engineA.pullChanges(since: nil)

        XCTAssertEqual(pulled.records, [tombstoneRecord])
    }

    func testCloudKitBackedEngineEncodesUploadsAndPassesCursorOnPull() async throws {
        let transport = RecordingCloudKitRecordTransport()
        let engine = CloudKitBackedSyncEngine(transport: transport)

        let record = SyncRecordEnvelope(
            kind: .trip,
            id: UUID(),
            updatedAt: Date(timeIntervalSince1970: 500),
            payload: Data("rome".utf8)
        )

        try await engine.push(localChanges: SyncBatch(records: [record]))
        _ = try await engine.pullChanges(since: Date(timeIntervalSince1970: 222))

        let uploads = await transport.uploadedRecords()
        XCTAssertEqual(uploads.count, 1)
        XCTAssertEqual(uploads.first?.recordType, CloudKitSyncSchema.recordType(for: .trip))
        XCTAssertEqual(uploads.first?.recordName, CloudKitSyncSchema.recordName(for: .trip, id: record.id))

        let requestedCursor = await transport.lastRequestedCursor()
        XCTAssertEqual(requestedCursor, Date(timeIntervalSince1970: 222))
    }

    func testCloudKitBackedEngineDecodesPulledRecordsAndDropsUnknownOnes() async throws {
        let knownID = UUID()
        let transport = RecordingCloudKitRecordTransport(
            fetchedRecords: [
                .init(
                    recordType: CloudKitSyncSchema.recordType(for: .place),
                    recordName: CloudKitSyncSchema.recordName(for: .place, id: knownID),
                    updatedAt: Date(timeIntervalSince1970: 700),
                    payload: Data("paris".utf8),
                    isDeleted: false
                ),
                .init(
                    recordType: "UnknownType",
                    recordName: "not-a-uuid",
                    updatedAt: Date(timeIntervalSince1970: 710),
                    payload: Data(),
                    isDeleted: false
                )
            ]
        )

        let engine = CloudKitBackedSyncEngine(transport: transport)
        let pulled = try await engine.pullChanges(since: nil)

        XCTAssertEqual(pulled.records.count, 1)
        XCTAssertEqual(pulled.records.first?.kind, .place)
        XCTAssertEqual(pulled.records.first?.id, knownID)
        XCTAssertEqual(pulled.records.first?.payload, Data("paris".utf8))
    }
}

private actor RecordingCloudKitRecordTransport: CloudKitRecordTransport {
    private var uploaded: [CloudKitSyncRecordCodec.EncodedRecord] = []
    private var requestedCursors: [Date?] = []
    private let fetchedRecords: [CloudKitSyncRecordCodec.EncodedRecord]

    init(fetchedRecords: [CloudKitSyncRecordCodec.EncodedRecord] = []) {
        self.fetchedRecords = fetchedRecords
    }

    func upload(records: [CloudKitSyncRecordCodec.EncodedRecord]) async throws {
        uploaded.append(contentsOf: records)
    }

    func fetchChanges(since: Date?) async throws -> [CloudKitSyncRecordCodec.EncodedRecord] {
        requestedCursors.append(since)
        return fetchedRecords
    }

    func uploadedRecords() -> [CloudKitSyncRecordCodec.EncodedRecord] {
        uploaded
    }

    func lastRequestedCursor() -> Date? {
        requestedCursors.last ?? nil
    }
}

private final class TestClock: @unchecked Sendable {
    private var times: [TimeInterval]
    private let lock = NSLock()

    init(times: [TimeInterval]) {
        self.times = times
    }

    func next() -> Date {
        lock.lock()
        defer { lock.unlock() }
        if times.isEmpty {
            return Date(timeIntervalSince1970: 9_999)
        }
        let value = times.removeFirst()
        return Date(timeIntervalSince1970: value)
    }
}
