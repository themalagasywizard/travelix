import Foundation

#if canImport(CloudKit)
import CloudKit

public struct CloudKitDatabaseRecordTransport: CloudKitRecordTransport, @unchecked Sendable {
    private let database: CKDatabase

    public init(database: CKDatabase) {
        self.database = database
    }

    public func upload(records: [CloudKitSyncRecordCodec.EncodedRecord]) async throws {
        guard records.isEmpty == false else { return }

        let ckRecords = records.map { encoded in
            let recordID = CKRecord.ID(recordName: encoded.recordName)
            let record = CKRecord(recordType: encoded.recordType, recordID: recordID)
            record[CloudKitSyncSchema.updatedAtField] = encoded.updatedAt as CKRecordValue
            record[CloudKitSyncSchema.payloadField] = encoded.payload as CKRecordValue
            record[CloudKitSyncSchema.isDeletedField] = encoded.isDeleted as CKRecordValue
            return record
        }

        _ = try await database.modifyRecords(
            saving: ckRecords,
            deleting: [],
            savePolicy: .changedKeys,
            atomically: false
        )
    }

    public func fetchChanges(since: Date?) async throws -> [CloudKitSyncRecordCodec.EncodedRecord] {
        let predicate: NSPredicate
        if let since {
            predicate = NSPredicate(format: "%K > %@", CloudKitSyncSchema.updatedAtField, since as NSDate)
        } else {
            predicate = NSPredicate(value: true)
        }

        var collected: [CloudKitSyncRecordCodec.EncodedRecord] = []
        for kind in SyncRecordEnvelope.Kind.allCases {
            let recordType = CloudKitSyncSchema.recordType(for: kind)
            let records = try await fetchAllRecords(recordType: recordType, predicate: predicate)
            collected.append(contentsOf: records.compactMap(makeEncodedRecord(from:)))
        }

        return collected.sorted { lhs, rhs in
            if lhs.updatedAt == rhs.updatedAt {
                return lhs.recordName < rhs.recordName
            }
            return lhs.updatedAt < rhs.updatedAt
        }
    }

    private func fetchAllRecords(recordType: String, predicate: NSPredicate) async throws -> [CKRecord] {
        let query = CKQuery(recordType: recordType, predicate: predicate)
        return try await fetchAllRecords(query: query, cursor: nil, accumulated: [])
    }

    private func fetchAllRecords(
        query: CKQuery,
        cursor: CKQueryOperation.Cursor?,
        accumulated: [CKRecord]
    ) async throws -> [CKRecord] {
        let page = try await fetchRecordPage(query: query, cursor: cursor)
        let merged = accumulated + page.records
        guard let nextCursor = page.nextCursor else {
            return merged
        }
        return try await fetchAllRecords(query: query, cursor: nextCursor, accumulated: merged)
    }

    private func fetchRecordPage(
        query: CKQuery,
        cursor: CKQueryOperation.Cursor?
    ) async throws -> (records: [CKRecord], nextCursor: CKQueryOperation.Cursor?) {
        try await withCheckedThrowingContinuation { continuation in
            var fetched: [CKRecord] = []
            let lock = NSLock()
            let operation = cursor.map(CKQueryOperation.init(cursor:)) ?? CKQueryOperation(query: query)

            operation.recordMatchedBlock = { _, result in
                switch result {
                case let .success(record):
                    lock.lock()
                    fetched.append(record)
                    lock.unlock()
                case .failure:
                    break
                }
            }

            operation.queryResultBlock = { result in
                switch result {
                case let .success(nextCursor):
                    lock.lock()
                    let records = fetched
                    lock.unlock()
                    continuation.resume(returning: (records, nextCursor))
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }

            database.add(operation)
        }
    }

    private func makeEncodedRecord(from record: CKRecord) -> CloudKitSyncRecordCodec.EncodedRecord? {
        guard let updatedAt = record[CloudKitSyncSchema.updatedAtField] as? Date else {
            return nil
        }

        guard let payload = record[CloudKitSyncSchema.payloadField] as? Data else {
            return nil
        }

        let isDeleted = (record[CloudKitSyncSchema.isDeletedField] as? NSNumber)?.boolValue
            ?? (record[CloudKitSyncSchema.isDeletedField] as? Bool)
            ?? false

        return CloudKitSyncRecordCodec.EncodedRecord(
            recordType: record.recordType,
            recordName: record.recordID.recordName,
            updatedAt: updatedAt,
            payload: payload,
            isDeleted: isDeleted
        )
    }
}

#endif
