import Foundation
import GRDB
import TravelJournalDomain

public protocol TagRepository {
    @discardableResult
    func createTag(named name: String) throws -> Tag
    func fetchTags() throws -> [Tag]
    func assignTag(tagID: UUID, toVisit visitID: UUID) throws
    func removeTag(tagID: UUID, fromVisit visitID: UUID) throws
    func fetchTags(forVisit visitID: UUID) throws -> [Tag]
    func fetchPlaceIDs(tagID: UUID) throws -> [UUID]
}

public final class GRDBTagRepository: TagRepository {
    private let dbQueue: DatabaseQueue

    public init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    @discardableResult
    public func createTag(named name: String) throws -> Tag {
        let normalized = name.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(!normalized.isEmpty, "Tag name must not be empty")

        return try dbQueue.write { db in
            if let existing = try TagRecord
                .filter(TagRecord.Columns.name == normalized)
                .fetchOne(db) {
                return existing.toDomain()
            }

            let tag = Tag(id: UUID(), name: normalized)
            try TagRecord(tag: tag).insert(db)
            return tag
        }
    }

    public func fetchTags() throws -> [Tag] {
        try dbQueue.read { db in
            try TagRecord
                .order(TagRecord.Columns.name.asc)
                .fetchAll(db)
                .map { $0.toDomain() }
        }
    }

    public func assignTag(tagID: UUID, toVisit visitID: UUID) throws {
        try dbQueue.write { db in
            try VisitTagRecord(visitID: visitID.uuidString.lowercased(), tagID: tagID.uuidString.lowercased())
                .insert(db, onConflict: .ignore)
        }
    }

    public func removeTag(tagID: UUID, fromVisit visitID: UUID) throws {
        try dbQueue.write { db in
            _ = try VisitTagRecord.deleteOne(
                db,
                key: [
                    VisitTagRecord.Columns.visitID.rawValue: visitID.uuidString.lowercased(),
                    VisitTagRecord.Columns.tagID.rawValue: tagID.uuidString.lowercased()
                ]
            )
        }
    }

    public func fetchTags(forVisit visitID: UUID) throws -> [Tag] {
        try dbQueue.read { db in
            let sql = """
            SELECT t.id, t.name
            FROM tags t
            INNER JOIN visit_tags vt ON vt.tag_id = t.id
            WHERE vt.visit_id = ?
            ORDER BY t.name ASC
            """

            return try TagRecord
                .fetchAll(db, sql: sql, arguments: [visitID.uuidString.lowercased()])
                .map { $0.toDomain() }
        }
    }

    public func fetchPlaceIDs(tagID: UUID) throws -> [UUID] {
        try dbQueue.read { db in
            let sql = """
            SELECT DISTINCT v.place_id
            FROM visits v
            INNER JOIN visit_tags vt ON vt.visit_id = v.id
            WHERE vt.tag_id = ?
            ORDER BY v.place_id ASC
            """

            let rows = try Row.fetchAll(db, sql: sql, arguments: [tagID.uuidString.lowercased()])
            return rows.compactMap { row in
                guard let raw: String = row["place_id"] else { return nil }
                return UUID(uuidString: raw)
            }
        }
    }
}

private struct TagRecord: Codable, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "tags"

    var id: String
    var name: String

    enum Columns: String, ColumnExpression {
        case id
        case name
    }

    init(tag: Tag) {
        self.id = tag.id.uuidString.lowercased()
        self.name = tag.name
    }

    func toDomain() -> Tag {
        Tag(id: UUID(uuidString: id) ?? UUID(), name: name)
    }
}

private struct VisitTagRecord: Codable, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "visit_tags"

    var visitID: String
    var tagID: String

    enum Columns: String, ColumnExpression {
        case visitID = "visit_id"
        case tagID = "tag_id"
    }
}
