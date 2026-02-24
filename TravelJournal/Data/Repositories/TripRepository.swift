import Foundation
import GRDB
import TravelJournalDomain

public protocol TripRepository {
    func createTrip(_ trip: Trip) throws
    func updateTrip(_ trip: Trip) throws
    func fetchTrips() throws -> [Trip]
    func fetchTrip(id: UUID) throws -> Trip?
}

public final class GRDBTripRepository: TripRepository {
    private let dbQueue: DatabaseQueue

    public init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    public func createTrip(_ trip: Trip) throws {
        try dbQueue.write { db in
            try TripRecord(trip: trip).insert(db)
        }
    }

    public func updateTrip(_ trip: Trip) throws {
        try dbQueue.write { db in
            try TripRecord(trip: trip).update(db)
        }
    }

    public func fetchTrips() throws -> [Trip] {
        try dbQueue.read { db in
            let rows = try TripRecord.fetchAll(
                db,
                sql: "SELECT * FROM trips ORDER BY start_date IS NULL, start_date ASC, name COLLATE NOCASE ASC"
            )
            return rows.map { $0.toDomain() }
        }
    }

    public func fetchTrip(id: UUID) throws -> Trip? {
        try dbQueue.read { db in
            try TripRecord.fetchOne(db, key: id.uuidString.lowercased())?.toDomain()
        }
    }
}

struct TripRecord: Codable, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "trips"

    var id: String
    var name: String
    var startDate: TimeInterval?
    var endDate: TimeInterval?
    var coverMediaID: String?
    var createdAt: TimeInterval
    var updatedAt: TimeInterval

    enum Columns: String, ColumnExpression {
        case id
        case name
        case startDate = "start_date"
        case endDate = "end_date"
        case coverMediaID = "cover_media_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(trip: Trip) {
        self.id = trip.id.uuidString.lowercased()
        self.name = trip.name
        self.startDate = trip.startDate?.timeIntervalSince1970
        self.endDate = trip.endDate?.timeIntervalSince1970
        self.coverMediaID = trip.coverMediaID?.uuidString.lowercased()
        self.createdAt = trip.createdAt.timeIntervalSince1970
        self.updatedAt = trip.updatedAt.timeIntervalSince1970
    }

    func toDomain() -> Trip {
        Trip(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            startDate: startDate.map { Date(timeIntervalSince1970: $0) },
            endDate: endDate.map { Date(timeIntervalSince1970: $0) },
            coverMediaID: coverMediaID.flatMap(UUID.init(uuidString:)),
            createdAt: Date(timeIntervalSince1970: createdAt),
            updatedAt: Date(timeIntervalSince1970: updatedAt)
        )
    }
}
