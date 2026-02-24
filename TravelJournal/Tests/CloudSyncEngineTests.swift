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
