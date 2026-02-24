import Foundation
import XCTest
@testable import TravelJournalData

final class SyncOrchestratorTests: XCTestCase {
    func testRunOncePushesPendingAndMarksAsPushed() async throws {
        let pending = SyncBatch(records: [
            SyncRecordEnvelope(kind: .visit, id: UUID(), updatedAt: Date(timeIntervalSince1970: 10), payload: Data("v1".utf8))
        ])
        let cloud = CloudSyncEngineSpy(pullResult: .empty)
        let local = LocalSyncStoreSpy(pending: pending)
        let cursor = InMemorySyncCursorStore(lastPulledAt: nil)
        let orchestrator = SyncOrchestrator(cloudSyncEngine: cloud, localStore: local, cursorStore: cursor)

        let report = try await orchestrator.runOnce()

        XCTAssertEqual(cloud.pushedBatches, [pending])
        XCTAssertEqual(local.markedPushedBatches, [pending])
        XCTAssertEqual(report.pushedCount, 1)
        XCTAssertEqual(report.pulledCount, 0)
        XCTAssertNil(report.updatedCursor)
    }

    func testRunOncePullsAndAppliesAndAdvancesCursorToLatestPulledTimestamp() async throws {
        let pulled = SyncBatch(records: [
            SyncRecordEnvelope(kind: .place, id: UUID(), updatedAt: Date(timeIntervalSince1970: 50), payload: Data("p1".utf8)),
            SyncRecordEnvelope(kind: .visit, id: UUID(), updatedAt: Date(timeIntervalSince1970: 120), payload: Data("v1".utf8))
        ])
        let cloud = CloudSyncEngineSpy(pullResult: pulled)
        let local = LocalSyncStoreSpy(pending: .empty)
        let initialCursor = Date(timeIntervalSince1970: 20)
        let cursor = InMemorySyncCursorStore(lastPulledAt: initialCursor)
        let orchestrator = SyncOrchestrator(cloudSyncEngine: cloud, localStore: local, cursorStore: cursor)

        let report = try await orchestrator.runOnce()

        XCTAssertEqual(cloud.pulledSinceArguments, [initialCursor])
        XCTAssertEqual(local.appliedPulledBatches, [pulled])
        XCTAssertEqual(cursor.lastPulledAt(), Date(timeIntervalSince1970: 120))
        XCTAssertEqual(report.pushedCount, 0)
        XCTAssertEqual(report.pulledCount, 2)
        XCTAssertEqual(report.appliedCount, 2)
        XCTAssertEqual(report.updatedCursor, Date(timeIntervalSince1970: 120))
    }

    func testRunOnceDoesNotTouchCursorWhenNoPulledRecords() async throws {
        let cloud = CloudSyncEngineSpy(pullResult: .empty)
        let local = LocalSyncStoreSpy(pending: .empty)
        let initialCursor = Date(timeIntervalSince1970: 88)
        let cursor = InMemorySyncCursorStore(lastPulledAt: initialCursor)
        let orchestrator = SyncOrchestrator(cloudSyncEngine: cloud, localStore: local, cursorStore: cursor)

        _ = try await orchestrator.runOnce()

        XCTAssertEqual(cursor.lastPulledAt(), initialCursor)
        XCTAssertEqual(local.appliedPulledBatches.count, 0)
    }

    func testRunOnceDoesNotApplyEchoedRecordsThatWereJustPushed() async throws {
        let echoedRecord = SyncRecordEnvelope(
            kind: .visit,
            id: UUID(),
            updatedAt: Date(timeIntervalSince1970: 10),
            payload: Data("self".utf8)
        )

        let pending = SyncBatch(records: [echoedRecord])
        let cloud = CloudSyncEngineSpy(pullResult: pending)
        let local = LocalSyncStoreSpy(pending: pending)
        let cursor = InMemorySyncCursorStore(lastPulledAt: nil)
        let orchestrator = SyncOrchestrator(cloudSyncEngine: cloud, localStore: local, cursorStore: cursor)

        let report = try await orchestrator.runOnce()

        XCTAssertEqual(local.appliedPulledBatches.count, 0)
        XCTAssertEqual(report.pulledCount, 1)
        XCTAssertEqual(report.appliedCount, 0)
        XCTAssertEqual(cursor.lastPulledAt(), Date(timeIntervalSince1970: 10))
    }

    func testRunOnceAppliesOnlyNonEchoedSubsetWhenPullContainsMixedRecords() async throws {
        let sharedID = UUID()
        let pushedRecord = SyncRecordEnvelope(
            kind: .trip,
            id: sharedID,
            updatedAt: Date(timeIntervalSince1970: 100),
            payload: Data("mine".utf8)
        )
        let remoteRecord = SyncRecordEnvelope(
            kind: .trip,
            id: sharedID,
            updatedAt: Date(timeIntervalSince1970: 101),
            payload: Data("remote".utf8)
        )

        let pending = SyncBatch(records: [pushedRecord])
        let pulled = SyncBatch(records: [pushedRecord, remoteRecord])
        let cloud = CloudSyncEngineSpy(pullResult: pulled)
        let local = LocalSyncStoreSpy(pending: pending)
        let cursor = InMemorySyncCursorStore(lastPulledAt: nil)
        let orchestrator = SyncOrchestrator(cloudSyncEngine: cloud, localStore: local, cursorStore: cursor)

        let report = try await orchestrator.runOnce()

        XCTAssertEqual(local.appliedPulledBatches, [SyncBatch(records: [remoteRecord])])
        XCTAssertEqual(report.pulledCount, 2)
        XCTAssertEqual(report.appliedCount, 1)
        XCTAssertEqual(cursor.lastPulledAt(), Date(timeIntervalSince1970: 101))
    }

    func testRunOnceDropsStalePulledRecordWhenPendingPushIsNewerForSameIdentity() async throws {
        let sharedID = UUID()
        let pendingRecord = SyncRecordEnvelope(
            kind: .visit,
            id: sharedID,
            updatedAt: Date(timeIntervalSince1970: 200),
            payload: Data("local-newer".utf8)
        )
        let stalePulledRecord = SyncRecordEnvelope(
            kind: .visit,
            id: sharedID,
            updatedAt: Date(timeIntervalSince1970: 150),
            payload: Data("remote-stale".utf8)
        )

        let pending = SyncBatch(records: [pendingRecord])
        let pulled = SyncBatch(records: [stalePulledRecord])
        let cloud = CloudSyncEngineSpy(pullResult: pulled)
        let local = LocalSyncStoreSpy(pending: pending)
        let cursor = InMemorySyncCursorStore(lastPulledAt: nil)
        let orchestrator = SyncOrchestrator(cloudSyncEngine: cloud, localStore: local, cursorStore: cursor)

        let report = try await orchestrator.runOnce()

        XCTAssertEqual(local.appliedPulledBatches.count, 0)
        XCTAssertEqual(report.pulledCount, 1)
        XCTAssertEqual(report.appliedCount, 0)
        XCTAssertEqual(cursor.lastPulledAt(), Date(timeIntervalSince1970: 150))
    }

    func testRunOnceKeepsPulledRecordOnTimestampTieForSameIdentity() async throws {
        let sharedID = UUID()
        let timestamp = Date(timeIntervalSince1970: 400)
        let pendingRecord = SyncRecordEnvelope(
            kind: .spot,
            id: sharedID,
            updatedAt: timestamp,
            payload: Data("local".utf8)
        )
        let pulledTieRecord = SyncRecordEnvelope(
            kind: .spot,
            id: sharedID,
            updatedAt: timestamp,
            payload: Data("remote".utf8)
        )

        let pending = SyncBatch(records: [pendingRecord])
        let pulled = SyncBatch(records: [pulledTieRecord])
        let cloud = CloudSyncEngineSpy(pullResult: pulled)
        let local = LocalSyncStoreSpy(pending: pending)
        let cursor = InMemorySyncCursorStore(lastPulledAt: nil)
        let orchestrator = SyncOrchestrator(cloudSyncEngine: cloud, localStore: local, cursorStore: cursor)

        let report = try await orchestrator.runOnce()

        XCTAssertEqual(local.appliedPulledBatches, [SyncBatch(records: [pulledTieRecord])])
        XCTAssertEqual(report.appliedCount, 1)
        XCTAssertEqual(cursor.lastPulledAt(), timestamp)
    }
}

private final class CloudSyncEngineSpy: CloudSyncEngine, @unchecked Sendable {
    private(set) var pushedBatches: [SyncBatch] = []
    private(set) var pulledSinceArguments: [Date?] = []
    private let pullResult: SyncBatch

    init(pullResult: SyncBatch) {
        self.pullResult = pullResult
    }

    func push(localChanges: SyncBatch) async throws {
        pushedBatches.append(localChanges)
    }

    func pullChanges(since: Date?) async throws -> SyncBatch {
        pulledSinceArguments.append(since)
        return pullResult
    }
}

private final class LocalSyncStoreSpy: LocalSyncChangeStore, @unchecked Sendable {
    private let pending: SyncBatch
    private(set) var markedPushedBatches: [SyncBatch] = []
    private(set) var appliedPulledBatches: [SyncBatch] = []

    init(pending: SyncBatch) {
        self.pending = pending
    }

    func pendingPushBatch() async throws -> SyncBatch {
        pending
    }

    func markBatchAsPushed(_ batch: SyncBatch) async throws {
        markedPushedBatches.append(batch)
    }

    func applyPulledBatch(_ batch: SyncBatch) async throws {
        appliedPulledBatches.append(batch)
    }
}

private final class InMemorySyncCursorStore: SyncCursorStoring, @unchecked Sendable {
    private var cursor: Date?

    init(lastPulledAt: Date?) {
        cursor = lastPulledAt
    }

    func lastPulledAt() -> Date? {
        cursor
    }

    func save(lastPulledAt: Date?) {
        cursor = lastPulledAt
    }
}
