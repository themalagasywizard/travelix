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

    func testColdStartP95StaysWithinConfiguredBudget() throws {
        let budgetMs = ProcessInfo.processInfo.environment["TJ_DB_COLD_START_BUDGET_MS"].flatMap(Double.init) ?? 5_000
        var samples: [Double] = []

        for _ in 0..<5 {
            let path = FileManager.default.temporaryDirectory
                .appendingPathComponent("traveljournal-perf-coldstart-budget-\(UUID().uuidString).sqlite")
                .path
            defer { try? FileManager.default.removeItem(atPath: path) }

            let sample = try DatabasePerformanceBenchmark.measureColdStart(path: path)
            samples.append(sample.durationMs)
        }

        let evaluation = PerformanceBudgetEvaluator.evaluate(
            operation: "db_cold_start",
            samplesMs: samples,
            budgetMs: budgetMs
        )

        XCTAssertTrue(
            evaluation.isWithinBudget,
            "Expected cold start p95 \(evaluation.p95Ms)ms <= budget \(budgetMs)ms. samples=\(evaluation.samplesMs)"
        )
    }

    func testMeasureVisitReadReturnsNonNegativeDuration() throws {
        let manager = try DatabaseManager(path: ":memory:")

        let sample = try DatabasePerformanceBenchmark.measureVisitRead(dbQueue: manager.dbQueue, rows: 200)

        XCTAssertEqual(sample.operation, "db_visit_read")
        XCTAssertGreaterThanOrEqual(sample.durationMs, 0)
    }

    func testVisitReadP95StaysWithinConfiguredBudget() throws {
        let budgetMs = ProcessInfo.processInfo.environment["TJ_DB_VISIT_READ_BUDGET_MS"].flatMap(Double.init) ?? 500
        let manager = try DatabaseManager(path: ":memory:")
        var samples: [Double] = []

        for _ in 0..<7 {
            let sample = try DatabasePerformanceBenchmark.measureVisitRead(dbQueue: manager.dbQueue, rows: 200)
            samples.append(sample.durationMs)
        }

        let evaluation = PerformanceBudgetEvaluator.evaluate(
            operation: "db_visit_read",
            samplesMs: samples,
            budgetMs: budgetMs
        )

        XCTAssertTrue(
            evaluation.isWithinBudget,
            "Expected visit read p95 \(evaluation.p95Ms)ms <= budget \(budgetMs)ms. samples=\(evaluation.samplesMs)"
        )
    }
}
