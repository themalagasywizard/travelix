import XCTest
import GRDB
@testable import TravelJournalData

final class DatabasePerformanceBenchmarkTests: XCTestCase {
    func testMeasureColdStartReturnsNonNegativeDuration() throws {
        let path = FileManager.default.temporaryDirectory
            .appendingPathComponent("traveljournal-perf-coldstart-\(UUID().uuidString).sqlite")
            .path
        defer { try? FileManager.default.removeItem(atPath: path) }

        let sample = try DatabasePerformanceBenchmark.measureColdStart(path: path)

        XCTAssertEqual(sample.operation, "db_cold_start")
        XCTAssertGreaterThanOrEqual(sample.durationMs, 0)
    }

    func testMeasureVisitReadReturnsNonNegativeDuration() throws {
        let manager = try DatabaseManager(path: ":memory:")

        let sample = try DatabasePerformanceBenchmark.measureVisitRead(dbQueue: manager.dbQueue, rows: 200)

        XCTAssertEqual(sample.operation, "db_visit_read")
        XCTAssertGreaterThanOrEqual(sample.durationMs, 0)
    }
}
