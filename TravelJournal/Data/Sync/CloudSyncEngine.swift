import Foundation
import TravelJournalCore

public struct SyncRecordEnvelope: Equatable, Sendable {
    public enum Kind: String, Equatable, Sendable {
        case place
        case trip
        case visit
        case spot
        case media
        case tag
    }

    public let kind: Kind
    public let id: UUID
    public let updatedAt: Date
    public let payload: Data
    public let isDeleted: Bool

    public init(kind: Kind, id: UUID, updatedAt: Date, payload: Data, isDeleted: Bool = false) {
        self.kind = kind
        self.id = id
        self.updatedAt = updatedAt
        self.payload = payload
        self.isDeleted = isDeleted
    }
}

public struct SyncBatch: Equatable, Sendable {
    public let records: [SyncRecordEnvelope]

    public init(records: [SyncRecordEnvelope]) {
        self.records = records
    }

    public static let empty = SyncBatch(records: [])
}

public protocol CloudSyncEngine: Sendable {
    func push(localChanges: SyncBatch) async throws
    func pullChanges(since: Date?) async throws -> SyncBatch
}

public enum CloudSyncEngineFactory {
    public static func makeDefault() -> CloudSyncEngine {
        NoopCloudSyncEngine()
    }

    public static func makeInMemoryShared() -> CloudSyncEngine {
        InMemoryCloudSyncEngine()
    }
}

public struct NoopCloudSyncEngine: CloudSyncEngine {
    public init() {}

    public func push(localChanges: SyncBatch) async throws {
        _ = localChanges
    }

    public func pullChanges(since: Date?) async throws -> SyncBatch {
        _ = since
        return .empty
    }
}

public actor InMemoryCloudSyncStorage {
    private struct Entry: Sendable {
        let record: SyncRecordEnvelope
        let committedAt: Date
    }

    private var recordsByKey: [String: Entry] = [:]

    public init() {}

    public func merge(_ batch: SyncBatch, committedAt: Date) {
        for record in batch.records {
            let key = Self.makeKey(kind: record.kind, id: record.id)
            if let existing = recordsByKey[key] {
                if existing.record.updatedAt > record.updatedAt { continue }
                if existing.record.updatedAt == record.updatedAt {
                    // deterministic tie-breaker prefers tombstones first on equal timestamps,
                    // then keeps payload that is lexicographically last.
                    if existing.record.isDeleted != record.isDeleted {
                        if existing.record.isDeleted { continue }
                    } else if existing.record.payload.lexicographicallyPrecedes(record.payload) == false {
                        continue
                    }
                }
            }

            recordsByKey[key] = Entry(record: record, committedAt: committedAt)
        }
    }

    public func changes(since cursor: Date?) -> SyncBatch {
        let filtered = recordsByKey.values
            .filter { entry in
                guard let cursor else { return true }
                return entry.committedAt > cursor
            }
            .sorted { lhs, rhs in
                if lhs.committedAt == rhs.committedAt {
                    return lhs.record.id.uuidString < rhs.record.id.uuidString
                }
                return lhs.committedAt < rhs.committedAt
            }
            .map(\.record)

        return SyncBatch(records: filtered)
    }

    private static func makeKey(kind: SyncRecordEnvelope.Kind, id: UUID) -> String {
        "\(kind.rawValue):\(id.uuidString.lowercased())"
    }
}

public struct InMemoryCloudSyncEngine: CloudSyncEngine {
    private let storage: InMemoryCloudSyncStorage
    private let now: @Sendable () -> Date

    public init(storage: InMemoryCloudSyncStorage = InMemoryCloudSyncStorage(), now: @escaping @Sendable () -> Date = Date.init) {
        self.storage = storage
        self.now = now
    }

    public func push(localChanges: SyncBatch) async throws {
        await storage.merge(localChanges, committedAt: now())
    }

    public func pullChanges(since: Date?) async throws -> SyncBatch {
        await storage.changes(since: since)
    }
}
