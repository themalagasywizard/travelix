import Foundation
import GRDB
import TravelJournalDomain

public protocol VisitRepository {
    func createVisit(_ visit: Visit) throws
    func updateVisit(_ visit: Visit) throws
    func deleteVisit(id: UUID) throws
    func fetchVisits(forPlace placeID: UUID) throws -> [Visit]
    func fetchVisits(forTrip tripID: UUID) throws -> [Visit]
}

public final class GRDBVisitRepository: VisitRepository {
    private let dbQueue: DatabaseQueue

    public init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    public func createVisit(_ visit: Visit) throws {
        try dbQueue.write { db in
            try VisitRecord(visit: visit).insert(db)
        }
    }

    public func updateVisit(_ visit: Visit) throws {
        try dbQueue.write { db in
            try VisitRecord(visit: visit).update(db)
        }
    }

    public func deleteVisit(id: UUID) throws {
        try dbQueue.write { db in
            _ = try VisitRecord.deleteOne(db, key: id.uuidString.lowercased())
        }
    }

    public func fetchVisits(forPlace placeID: UUID) throws -> [Visit] {
        try dbQueue.read { db in
            try VisitRecord
                .filter(VisitRecord.Columns.placeID == placeID.uuidString.lowercased())
                .order(VisitRecord.Columns.startDate.asc)
                .fetchAll(db)
                .map { $0.toDomain() }
        }
    }

    public func fetchVisits(forTrip tripID: UUID) throws -> [Visit] {
        try dbQueue.read { db in
            try VisitRecord
                .filter(VisitRecord.Columns.tripID == tripID.uuidString.lowercased())
                .order(VisitRecord.Columns.startDate.asc)
                .fetchAll(db)
                .map { $0.toDomain() }
        }
    }
}

struct VisitRecord: Codable, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "visits"

    var id: String
    var placeID: String
    var tripID: String?
    var startDate: TimeInterval
    var endDate: TimeInterval
    var summary: String?
    var notes: String?
    var createdAt: TimeInterval
    var updatedAt: TimeInterval

    enum Columns: String, ColumnExpression {
        case id
        case placeID = "place_id"
        case tripID = "trip_id"
        case startDate = "start_date"
        case endDate = "end_date"
        case summary
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(visit: Visit) {
        self.id = visit.id.uuidString.lowercased()
        self.placeID = visit.placeID.uuidString.lowercased()
        self.tripID = visit.tripID?.uuidString.lowercased()
        self.startDate = visit.startDate.timeIntervalSince1970
        self.endDate = visit.endDate.timeIntervalSince1970
        self.summary = visit.summary
        self.notes = visit.notes
        self.createdAt = visit.createdAt.timeIntervalSince1970
        self.updatedAt = visit.updatedAt.timeIntervalSince1970
    }

    func toDomain() -> Visit {
        Visit(
            id: UUID(uuidString: id) ?? UUID(),
            placeID: UUID(uuidString: placeID) ?? UUID(),
            tripID: tripID.flatMap(UUID.init(uuidString:)),
            startDate: Date(timeIntervalSince1970: startDate),
            endDate: Date(timeIntervalSince1970: endDate),
            summary: summary,
            notes: notes,
            createdAt: Date(timeIntervalSince1970: createdAt),
            updatedAt: Date(timeIntervalSince1970: updatedAt)
        )
    }
}
