import Foundation

public enum CloudKitSyncSchema {
    public static let updatedAtField = "updatedAt"
    public static let payloadField = "payload"
    public static let isDeletedField = "isDeleted"

    public static func recordType(for kind: SyncRecordEnvelope.Kind) -> String {
        switch kind {
        case .place: return "TJPlace"
        case .trip: return "TJTrip"
        case .visit: return "TJVisit"
        case .spot: return "TJSpot"
        case .media: return "TJMedia"
        case .tag: return "TJTag"
        }
    }

    public static func kind(for recordType: String) -> SyncRecordEnvelope.Kind? {
        switch recordType {
        case "TJPlace": return .place
        case "TJTrip": return .trip
        case "TJVisit": return .visit
        case "TJSpot": return .spot
        case "TJMedia": return .media
        case "TJTag": return .tag
        default: return nil
        }
    }

    public static func recordName(for kind: SyncRecordEnvelope.Kind, id: UUID) -> String {
        "\(kind.rawValue)-\(id.uuidString.lowercased())"
    }

    public static func parseRecordName(_ recordName: String) -> (kind: SyncRecordEnvelope.Kind, id: UUID)? {
        let components = recordName.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true)
        guard components.count == 2 else { return nil }
        guard let kind = SyncRecordEnvelope.Kind(rawValue: String(components[0])) else { return nil }
        guard let id = UUID(uuidString: String(components[1])) else { return nil }
        return (kind, id)
    }
}

public struct CloudKitSyncRecordCodec {
    public struct EncodedRecord: Equatable, Sendable {
        public let recordType: String
        public let recordName: String
        public let updatedAt: Date
        public let payload: Data
        public let isDeleted: Bool

        public init(recordType: String, recordName: String, updatedAt: Date, payload: Data, isDeleted: Bool) {
            self.recordType = recordType
            self.recordName = recordName
            self.updatedAt = updatedAt
            self.payload = payload
            self.isDeleted = isDeleted
        }
    }

    public init() {}

    public func encode(_ envelope: SyncRecordEnvelope) -> EncodedRecord {
        EncodedRecord(
            recordType: CloudKitSyncSchema.recordType(for: envelope.kind),
            recordName: CloudKitSyncSchema.recordName(for: envelope.kind, id: envelope.id),
            updatedAt: envelope.updatedAt,
            payload: envelope.payload,
            isDeleted: envelope.isDeleted
        )
    }

    public func decode(_ encoded: EncodedRecord) -> SyncRecordEnvelope? {
        if let parsed = CloudKitSyncSchema.parseRecordName(encoded.recordName) {
            // Record name is the canonical source of kind/id to keep identity deterministic.
            return SyncRecordEnvelope(
                kind: parsed.kind,
                id: parsed.id,
                updatedAt: encoded.updatedAt,
                payload: encoded.payload,
                isDeleted: encoded.isDeleted
            )
        }

        // Fallback to record type mapping in case record names were generated externally.
        guard let kind = CloudKitSyncSchema.kind(for: encoded.recordType) else {
            return nil
        }

        guard let id = UUID(uuidString: encoded.recordName) else {
            return nil
        }

        return SyncRecordEnvelope(
            kind: kind,
            id: id,
            updatedAt: encoded.updatedAt,
            payload: encoded.payload,
            isDeleted: encoded.isDeleted
        )
    }
}
