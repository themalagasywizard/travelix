import Foundation
import GRDB
import TravelJournalDomain

public protocol SpotRepository {
    func addSpot(_ spot: Spot) throws
    func updateSpot(_ spot: Spot) throws
    func deleteSpot(id: UUID) throws
    func fetchSpots(forVisit visitID: UUID) throws -> [Spot]
}

public final class GRDBSpotRepository: SpotRepository {
    private let dbQueue: DatabaseQueue

    public init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    public func addSpot(_ spot: Spot) throws {
        try dbQueue.write { db in
            try SpotRecord(spot: spot).insert(db)
        }
    }

    public func updateSpot(_ spot: Spot) throws {
        try dbQueue.write { db in
            try SpotRecord(spot: spot).update(db)
        }
    }

    public func deleteSpot(id: UUID) throws {
        try dbQueue.write { db in
            _ = try SpotRecord.deleteOne(db, key: id.uuidString.lowercased())
        }
    }

    public func fetchSpots(forVisit visitID: UUID) throws -> [Spot] {
        try dbQueue.read { db in
            try SpotRecord
                .filter(SpotRecord.Columns.visitID == visitID.uuidString.lowercased())
                .order(SpotRecord.Columns.name.asc)
                .fetchAll(db)
                .map { $0.toDomain() }
        }
    }
}

struct SpotRecord: Codable, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "spots"

    var id: String
    var visitID: String
    var name: String
    var category: String?
    var latitude: Double?
    var longitude: Double?
    var address: String?
    var rating: Int?
    var note: String?
    var createdAt: TimeInterval
    var updatedAt: TimeInterval

    enum Columns: String, ColumnExpression {
        case id
        case visitID = "visit_id"
        case name
        case category
        case latitude
        case longitude
        case address
        case rating
        case note
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(spot: Spot) {
        self.id = spot.id.uuidString.lowercased()
        self.visitID = spot.visitID.uuidString.lowercased()
        self.name = spot.name
        self.category = spot.category
        self.latitude = spot.latitude
        self.longitude = spot.longitude
        self.address = spot.address
        self.rating = spot.rating
        self.note = spot.note
        self.createdAt = spot.createdAt.timeIntervalSince1970
        self.updatedAt = spot.updatedAt.timeIntervalSince1970
    }

    func toDomain() -> Spot {
        Spot(
            id: UUID(uuidString: id) ?? UUID(),
            visitID: UUID(uuidString: visitID) ?? UUID(),
            name: name,
            category: category,
            latitude: latitude,
            longitude: longitude,
            address: address,
            rating: rating,
            note: note,
            createdAt: Date(timeIntervalSince1970: createdAt),
            updatedAt: Date(timeIntervalSince1970: updatedAt)
        )
    }
}
