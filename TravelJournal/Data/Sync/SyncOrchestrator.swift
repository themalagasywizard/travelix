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
        let normalizedPulledRecords = normalizePulledRecordsByIdentity(pulled.records)
        let applyableRecords = stripEchoedPushes(from: normalizedPulledRecords, pendingPushRecords: pending.records)
        if applyableRecords.isEmpty == false {
            try await localStore.applyPulledBatch(SyncBatch(records: applyableRecords))
        }

        if pulled.records.isEmpty == false {
            cursorStore.save(lastPulledAt: latestTimestamp(in: pulled.records) ?? currentCursor)
        }

        return SyncRunReport(
            pushedCount: pending.records.count,
            pulledCount: pulled.records.count,
            appliedCount: applyableRecords.count,
            updatedCursor: pulled.records.isEmpty ? currentCursor : (latestTimestamp(in: pulled.records) ?? currentCursor)
        )
    }

    private func normalizePulledRecordsByIdentity(
        _ records: [SyncRecordEnvelope]
    ) -> [SyncRecordEnvelope] {
        guard records.count > 1 else {
            return records
        }

        var latestByIdentity: [String: SyncRecordEnvelope] = [:]
        latestByIdentity.reserveCapacity(records.count)

        for record in records {
            let identity = "\(record.kind.rawValue)::\(record.id.uuidString)"
            if let existing = latestByIdentity[identity] {
                let resolved = SyncConflictResolver.resolveLastWriteWins(
                    local: SyncConflictValue(value: existing, updatedAt: existing.updatedAt),
                    remote: SyncConflictValue(value: record, updatedAt: record.updatedAt)
                )
                latestByIdentity[identity] = resolved.value
            } else {
                latestByIdentity[identity] = record
            }
        }

        return latestByIdentity.values.sorted { lhs, rhs in
            if lhs.updatedAt != rhs.updatedAt {
                return lhs.updatedAt < rhs.updatedAt
            }

            if lhs.kind != rhs.kind {
                return lhs.kind.rawValue < rhs.kind.rawValue
            }

            return lhs.id.uuidString < rhs.id.uuidString
        }
    }

    private func stripEchoedPushes(
        from pulledRecords: [SyncRecordEnvelope],
        pendingPushRecords: [SyncRecordEnvelope]
    ) -> [SyncRecordEnvelope] {
        guard pendingPushRecords.isEmpty == false, pulledRecords.isEmpty == false else {
            return pulledRecords
        }

        var unmatchedPending = pendingPushRecords
        var filtered: [SyncRecordEnvelope] = []
        filtered.reserveCapacity(pulledRecords.count)

        for pulled in pulledRecords {
            if let index = unmatchedPending.firstIndex(where: { $0 == pulled }) {
                unmatchedPending.remove(at: index)
                continue
            }

            if shouldDropPulledRecordAsStaleConflict(pulled, pendingPushRecords: pendingPushRecords) {
                continue
            }

            filtered.append(pulled)
        }

        return filtered
    }

    private func shouldDropPulledRecordAsStaleConflict(
        _ pulled: SyncRecordEnvelope,
        pendingPushRecords: [SyncRecordEnvelope]
    ) -> Bool {
        guard let pending = pendingPushRecords.first(where: { $0.kind == pulled.kind && $0.id == pulled.id }) else {
            return false
        }

        let resolved = SyncConflictResolver.resolveLastWriteWins(
            local: SyncConflictValue(value: pending, updatedAt: pending.updatedAt),
            remote: SyncConflictValue(value: pulled, updatedAt: pulled.updatedAt)
        )

        return resolved.value == pending
    }

    private func latestTimestamp(in records: [SyncRecordEnvelope]) -> Date? {
        records.map(\.updatedAt).max()
    }
}
