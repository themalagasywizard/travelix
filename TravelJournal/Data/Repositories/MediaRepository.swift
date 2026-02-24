import Foundation
import GRDB
import TravelJournalDomain

public protocol MediaRepository {
    func addMedia(_ media: Media) throws
    func updateMedia(_ media: Media) throws
    func deleteMedia(id: UUID) throws
    func fetchMedia(forVisit visitID: UUID) throws -> [Media]
    func fetchMedia(id: UUID) throws -> Media?
}

public final class GRDBMediaRepository: MediaRepository {
    private let dbQueue: DatabaseQueue

    public init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    public func addMedia(_ media: Media) throws {
        try dbQueue.write { db in
            try MediaRecord(media: media).insert(db)
        }
    }

    public func updateMedia(_ media: Media) throws {
        try dbQueue.write { db in
            try MediaRecord(media: media).update(db)
        }
    }

    public func deleteMedia(id: UUID) throws {
        try dbQueue.write { db in
            _ = try MediaRecord.deleteOne(db, key: id.uuidString.lowercased())
        }
    }

    public func fetchMedia(forVisit visitID: UUID) throws -> [Media] {
        try dbQueue.read { db in
            try MediaRecord
                .filter(MediaRecord.Columns.visitID == visitID.uuidString.lowercased())
                .order(MediaRecord.Columns.createdAt.asc)
                .fetchAll(db)
                .map { $0.toDomain() }
        }
    }

    public func fetchMedia(id: UUID) throws -> Media? {
        try dbQueue.read { db in
            try MediaRecord.fetchOne(db, key: id.uuidString.lowercased())?.toDomain()
        }
    }
}

struct MediaRecord: Codable, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "media"

    var id: String
    var visitID: String
    var localIdentifier: String?
    var fileURL: String?
    var width: Int?
    var height: Int?
    var createdAt: TimeInterval
    var updatedAt: TimeInterval

    enum Columns: String, ColumnExpression {
        case id
        case visitID = "visit_id"
        case localIdentifier = "local_identifier"
        case fileURL = "file_url"
        case width
        case height
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(media: Media) {
        self.id = media.id.uuidString.lowercased()
        self.visitID = media.visitID.uuidString.lowercased()
        self.localIdentifier = media.localIdentifier
        self.fileURL = media.fileURL
        self.width = media.width
        self.height = media.height
        self.createdAt = media.createdAt.timeIntervalSince1970
        self.updatedAt = media.updatedAt.timeIntervalSince1970
    }

    func toDomain() -> Media {
        Media(
            id: UUID(uuidString: id) ?? UUID(),
            visitID: UUID(uuidString: visitID) ?? UUID(),
            localIdentifier: localIdentifier,
            fileURL: fileURL,
            width: width,
            height: height,
            createdAt: Date(timeIntervalSince1970: createdAt),
            updatedAt: Date(timeIntervalSince1970: updatedAt)
        )
    }
}
