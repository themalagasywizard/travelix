import XCTest
@testable import TravelJournalData

final class PerformanceBudgetEvaluatorTests: XCTestCase {
    func testEvaluateComputesMedianAndP95() {
        let evaluation = PerformanceBudgetEvaluator.evaluate(
            operation: "db_cold_start",
            samplesMs: [20, 10, 30, 40, 50],
            budgetMs: 45
        )

        XCTAssertEqual(evaluation.operation, "db_cold_start")
        XCTAssertEqual(evaluation.samplesMs, [10, 20, 30, 40, 50])
        XCTAssertEqual(evaluation.medianMs, 30, accuracy: 0.0001)
        XCTAssertEqual(evaluation.p95Ms, 48, accuracy: 0.0001)
        XCTAssertFalse(evaluation.isWithinBudget)
    }

    func testEvaluateWithinBudgetWhenP95AtThreshold() {
        let evaluation = PerformanceBudgetEvaluator.evaluate(
            operation: "db_visit_read",
            samplesMs: [2, 2, 3, 3, 4],
            budgetMs: 4
        )

        XCTAssertEqual(evaluation.p95Ms, 3.8, accuracy: 0.0001)
        XCTAssertTrue(evaluation.isWithinBudget)
    }
}
