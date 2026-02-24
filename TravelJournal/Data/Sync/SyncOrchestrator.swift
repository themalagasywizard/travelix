import Foundation

public struct SyncRunReport: Equatable, Sendable {
    public let pushedCount: Int
    public let pulledCount: Int
    public let appliedCount: Int
    public let updatedCursor: Date?

    public init(
        pushedCount: Int,
        pulledCount: Int,
        appliedCount: Int,
        updatedCursor: Date?
    ) {
        self.pushedCount = pushedCount
        self.pulledCount = pulledCount
        self.appliedCount = appliedCount
        self.updatedCursor = updatedCursor
    }
}

public protocol LocalSyncChangeStore: Sendable {
    func pendingPushBatch() async throws -> SyncBatch
    func markBatchAsPushed(_ batch: SyncBatch) async throws
    func applyPulledBatch(_ batch: SyncBatch) async throws
}

public struct SyncOrchestrator: Sendable {
    private let cloudSyncEngine: CloudSyncEngine
    private let localStore: LocalSyncChangeStore
    private let cursorStore: SyncCursorStoring

    public init(
        cloudSyncEngine: CloudSyncEngine,
        localStore: LocalSyncChangeStore,
        cursorStore: SyncCursorStoring
    ) {
        self.cloudSyncEngine = cloudSyncEngine
        self.localStore = localStore
        self.cursorStore = cursorStore
    }

    @discardableResult
    public func runOnce() async throws -> SyncRunReport {
        let pending = try await localStore.pendingPushBatch()
        if pending.records.isEmpty == false {
            try await cloudSyncEngine.push(localChanges: pending)
            try await localStore.markBatchAsPushed(pending)
        }

        let currentCursor = cursorStore.lastPulledAt()
        let pulled = try await cloudSyncEngine.pullChanges(since: currentCursor)
        if pulled.records.isEmpty == false {
            try await localStore.applyPulledBatch(pulled)
            cursorStore.save(lastPulledAt: latestTimestamp(in: pulled.records) ?? currentCursor)
        }

        return SyncRunReport(
            pushedCount: pending.records.count,
            pulledCount: pulled.records.count,
            appliedCount: pulled.records.count,
            updatedCursor: pulled.records.isEmpty ? currentCursor : (latestTimestamp(in: pulled.records) ?? currentCursor)
        )
    }

    private func latestTimestamp(in records: [SyncRecordEnvelope]) -> Date? {
        records.map(\.updatedAt).max()
    }
}
