import Foundation

public enum SyncBatchMerging {
    /// Merges local and remote records by (kind,id), applying last-write-wins on `updatedAt`.
    /// If timestamps are equal, remote wins to keep pull reconciliation deterministic.
    public static func mergeLastWriteWins(
        local: SyncBatch,
        remote: SyncBatch
    ) -> SyncBatch {
        var mergedByIdentity: [RecordIdentity: SyncRecordEnvelope] = [:]

        for record in local.records {
            mergedByIdentity[RecordIdentity(record)] = record
        }

        for record in remote.records {
            let identity = RecordIdentity(record)
            if let current = mergedByIdentity[identity] {
                mergedByIdentity[identity] = resolve(current: current, incoming: record)
            } else {
                mergedByIdentity[identity] = record
            }
        }

        let ordered = mergedByIdentity.values.sorted(by: sortOrder)
        return SyncBatch(records: ordered)
    }

    private static func resolve(
        current: SyncRecordEnvelope,
        incoming: SyncRecordEnvelope
    ) -> SyncRecordEnvelope {
        if incoming.updatedAt >= current.updatedAt {
            return incoming
        }

        return current
    }

    private static func sortOrder(
        lhs: SyncRecordEnvelope,
        rhs: SyncRecordEnvelope
    ) -> Bool {
        if lhs.kind != rhs.kind {
            return lhs.kind.rawValue < rhs.kind.rawValue
        }

        if lhs.updatedAt != rhs.updatedAt {
            return lhs.updatedAt < rhs.updatedAt
        }

        return lhs.id.uuidString < rhs.id.uuidString
    }
}

private struct RecordIdentity: Hashable {
    let kind: SyncRecordEnvelope.Kind
    let id: UUID

    init(_ envelope: SyncRecordEnvelope) {
        kind = envelope.kind
        id = envelope.id
    }
}
