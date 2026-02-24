import Foundation
import GRDB
import TravelJournalDomain

public protocol PlaceRepository {
    func upsertPlace(_ place: Place) throws
    func fetchPlacesWithVisitCounts() throws -> [(place: Place, visitCount: Int)]
    func fetchPlace(id: UUID) throws -> Place?
}

public final class GRDBPlaceRepository: PlaceRepository {
    private let dbQueue: DatabaseQueue

    public init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    public func upsertPlace(_ place: Place) throws {
        try dbQueue.write { db in
            let record = PlaceRecord(place: place)
            try record.save(db)
        }
    }

    public func fetchPlacesWithVisitCounts() throws -> [(place: Place, visitCount: Int)] {
        try dbQueue.read { db in
            let rows = try Row.fetchAll(
                db,
                sql: """
                SELECT p.*, COUNT(v.id) AS visit_count
                FROM places p
                LEFT JOIN visits v ON v.place_id = p.id
                GROUP BY p.id
                ORDER BY p.name COLLATE NOCASE ASC
                """
            )

            return try rows.map { row in
                let record = try PlaceRecord(row: row)
                let count: Int = row["visit_count"]
                return (record.toDomain(), count)
            }
        }
    }

    public func fetchPlace(id: UUID) throws -> Place? {
        try dbQueue.read { db in
            guard let record = try PlaceRecord.fetchOne(db, key: id.uuidString.lowercased()) else {
                return nil
            }
            return record.toDomain()
        }
    }
}

struct PlaceRecord: Codable, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "places"

    var id: String
    var name: String
    var country: String?
    var latitude: Double
    var longitude: Double
    var createdAt: TimeInterval
    var updatedAt: TimeInterval

    enum Columns: String, ColumnExpression {
        case id, name, country, latitude, longitude
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(place: Place) {
        self.id = place.id.uuidString.lowercased()
        self.name = place.name
        self.country = place.country
        self.latitude = place.latitude
        self.longitude = place.longitude
        self.createdAt = place.createdAt.timeIntervalSince1970
        self.updatedAt = place.updatedAt.timeIntervalSince1970
    }

    func toDomain() -> Place {
        Place(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            country: country,
            latitude: latitude,
            longitude: longitude,
            createdAt: Date(timeIntervalSince1970: createdAt),
            updatedAt: Date(timeIntervalSince1970: updatedAt)
        )
    }
}
