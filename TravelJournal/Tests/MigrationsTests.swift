import XCTest
import GRDB
@testable import TravelJournalData

final class MigrationsTests: XCTestCase {
    func testMigrationsCreateAllTables() throws {
        let manager = try DatabaseManager(path: ":memory:")

        try manager.dbQueue.inDatabase { db in
            let expected = Set(["places", "trips", "visits", "spots", "media", "tags", "visit_tags"])
            let rows = try Row.fetchAll(db, sql: "SELECT name FROM sqlite_master WHERE type='table'")
            let names = Set(rows.compactMap { $0["name"] as String? })
            XCTAssertTrue(expected.isSubset(of: names))
        }
    }

    func testLatestMigrationAddsVisitsMoodColumn() throws {
        let manager = try DatabaseManager(path: ":memory:")

        try manager.dbQueue.inDatabase { db in
            let columns = try db.columns(in: "visits")
            XCTAssertTrue(columns.contains(where: { $0.name == "mood" }))
        }
    }

    func testMigratorUpgradesFromV1ToV2() throws {
        let fileManager = FileManager.default
        let path = fileManager.temporaryDirectory
            .appendingPathComponent("traveljournal-migration-upgrade-\(UUID().uuidString).sqlite")
            .path
        defer { try? fileManager.removeItem(atPath: path) }

        let dbQueue = try DatabaseQueue(path: path)
        try dbQueue.write { db in
            try db.execute(sql: """
            CREATE TABLE visits (
                id TEXT PRIMARY KEY,
                place_id TEXT NOT NULL,
                trip_id TEXT,
                start_date REAL NOT NULL,
                end_date REAL NOT NULL,
                summary TEXT,
                notes TEXT,
                created_at REAL NOT NULL,
                updated_at REAL NOT NULL
            )
            """)
            try db.execute(sql: "CREATE TABLE grdb_migrations(identifier TEXT NOT NULL PRIMARY KEY)")
            try db.execute(sql: "INSERT INTO grdb_migrations(identifier) VALUES ('v1_create_schema')")
        }

        _ = try DatabaseManager(path: path)

        try dbQueue.inDatabase { db in
            let columns = try db.columns(in: "visits")
            XCTAssertTrue(columns.contains(where: { $0.name == "mood" }))
        }
    }
}
