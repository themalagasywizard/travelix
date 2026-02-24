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
}
