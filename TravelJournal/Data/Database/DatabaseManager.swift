import Foundation
import GRDB

public final class DatabaseManager {
    public let dbQueue: DatabaseQueue

    public init(path: String) throws {
        dbQueue = try DatabaseQueue(path: path)
        try Self.makeMigrator().migrate(dbQueue)
    }

    public static func makeMigrator() -> DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("v1_create_schema") { db in
            try db.create(table: "places") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("country", .text)
                t.column("latitude", .double).notNull()
                t.column("longitude", .double).notNull()
                t.column("created_at", .double).notNull()
                t.column("updated_at", .double).notNull()
            }

            try db.create(table: "trips") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("start_date", .double)
                t.column("end_date", .double)
                t.column("cover_media_id", .text)
                t.column("created_at", .double).notNull()
                t.column("updated_at", .double).notNull()
            }

            try db.create(table: "visits") { t in
                t.column("id", .text).primaryKey()
                t.column("place_id", .text).notNull().references("places", onDelete: .cascade)
                t.column("trip_id", .text).references("trips", onDelete: .setNull)
                t.column("start_date", .double).notNull()
                t.column("end_date", .double).notNull()
                t.column("summary", .text)
                t.column("notes", .text)
                t.column("created_at", .double).notNull()
                t.column("updated_at", .double).notNull()
            }

            try db.create(table: "spots") { t in
                t.column("id", .text).primaryKey()
                t.column("visit_id", .text).notNull().references("visits", onDelete: .cascade)
                t.column("name", .text).notNull()
                t.column("category", .text)
                t.column("latitude", .double)
                t.column("longitude", .double)
                t.column("address", .text)
                t.column("rating", .integer)
                t.column("note", .text)
                t.column("created_at", .double).notNull()
                t.column("updated_at", .double).notNull()
            }

            try db.create(table: "media") { t in
                t.column("id", .text).primaryKey()
                t.column("visit_id", .text).notNull().references("visits", onDelete: .cascade)
                t.column("local_identifier", .text)
                t.column("file_url", .text)
                t.column("width", .integer)
                t.column("height", .integer)
                t.column("created_at", .double).notNull()
                t.column("updated_at", .double).notNull()
            }

            try db.create(table: "tags") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull().unique()
            }

            try db.create(table: "visit_tags") { t in
                t.column("visit_id", .text).notNull().references("visits", onDelete: .cascade)
                t.column("tag_id", .text).notNull().references("tags", onDelete: .cascade)
                t.primaryKey(["visit_id", "tag_id"])
            }

            try db.create(index: "idx_visits_place", on: "visits", columns: ["place_id"])
            try db.create(index: "idx_visits_trip", on: "visits", columns: ["trip_id"])
            try db.create(index: "idx_spots_visit", on: "spots", columns: ["visit_id"])
            try db.create(index: "idx_media_visit", on: "media", columns: ["visit_id"])
        }

        migrator.registerMigration("v2_add_visits_mood") { db in
            try db.alter(table: "visits") { table in
                table.add(column: "mood", .text).notNull().defaults(to: "")
            }
        }

        return migrator
    }
}
