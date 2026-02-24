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

    public init(kind: Kind, id: UUID, updatedAt: Date, payload: Data) {
        self.kind = kind
        self.id = id
        self.updatedAt = updatedAt
        self.payload = payload
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
