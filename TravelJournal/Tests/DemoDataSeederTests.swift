import XCTest
import GRDB
@testable import TravelJournalData

final class DemoDataSeederTests: XCTestCase {
    func testSeedIfNeededInsertsExpectedCounts() throws {
        let manager = try DatabaseManager(path: ":memory:")
        let seeder = DemoDataSeeder(dbQueue: manager.dbQueue)

        let report = try seeder.seedIfNeeded(targetPlaces: 50, targetVisits: 120)
        XCTAssertEqual(report.placesInserted, 50)
        XCTAssertEqual(report.visitsInserted, 120)

        try manager.dbQueue.read { db in
            let placeCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM places")
            let visitCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM visits")
            XCTAssertEqual(placeCount, 50)
            XCTAssertEqual(visitCount, 120)
        }
    }

    func testSeedIfNeededDoesNotDuplicateWhenDataExists() throws {
        let manager = try DatabaseManager(path: ":memory:")
        let seeder = DemoDataSeeder(dbQueue: manager.dbQueue)

        _ = try seeder.seedIfNeeded(targetPlaces: 10, targetVisits: 20)
        let second = try seeder.seedIfNeeded(targetPlaces: 10, targetVisits: 20)

        XCTAssertEqual(second.placesInserted, 0)
        XCTAssertEqual(second.visitsInserted, 0)

        try manager.dbQueue.read { db in
            let placeCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM places")
            let visitCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM visits")
            XCTAssertEqual(placeCount, 10)
            XCTAssertEqual(visitCount, 20)
        }
    }
}
