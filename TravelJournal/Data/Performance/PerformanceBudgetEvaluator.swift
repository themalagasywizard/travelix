import Foundation

public struct PerformanceBudgetEvaluation: Equatable {
    public let operation: String
    public let samplesMs: [Double]
    public let medianMs: Double
    public let p95Ms: Double
    public let budgetMs: Double

    public var isWithinBudget: Bool {
        p95Ms <= budgetMs
    }

    public init(operation: String, samplesMs: [Double], medianMs: Double, p95Ms: Double, budgetMs: Double) {
        self.operation = operation
        self.samplesMs = samplesMs
        self.medianMs = medianMs
        self.p95Ms = p95Ms
        self.budgetMs = budgetMs
    }
}

public enum PerformanceBudgetEvaluator {
    /// Evaluates a timing budget using p95 to reduce single-spike noise while still catching regressions.
    public static func evaluate(operation: String, samplesMs: [Double], budgetMs: Double) -> PerformanceBudgetEvaluation {
        precondition(!samplesMs.isEmpty, "samples must not be empty")
        precondition(budgetMs >= 0, "budgetMs must be non-negative")

        let sorted = samplesMs.sorted()
        let median = percentile(sorted: sorted, p: 0.5)
        let p95 = percentile(sorted: sorted, p: 0.95)

        return PerformanceBudgetEvaluation(
            operation: operation,
            samplesMs: sorted,
            medianMs: median,
            p95Ms: p95,
            budgetMs: budgetMs
        )
    }

    private static func percentile(sorted: [Double], p: Double) -> Double {
        precondition((0...1).contains(p), "percentile must be in [0, 1]")
        guard sorted.count > 1 else { return sorted[0] }

        let rank = p * Double(sorted.count - 1)
        let lowerIndex = Int(rank.rounded(.down))
        let upperIndex = Int(rank.rounded(.up))

        guard lowerIndex != upperIndex else { return sorted[lowerIndex] }

        let fraction = rank - Double(lowerIndex)
        return sorted[lowerIndex] + (sorted[upperIndex] - sorted[lowerIndex]) * fraction
    }
}
