import Foundation
import XCTest
@testable import TravelJournalCore
@testable import TravelJournalData

final class SyncExecutionCoordinatorTests: XCTestCase {
    func testRunIfEnabledSkipsRunnerWhenFeatureFlagDisabled() async throws {
        let featureFlags = InMemorySyncFeatureFlags(isSyncEnabled: false)
        let runner = SyncRunExecutorSpy(reportToReturn: .fixture(appliedCount: 2))
        let coordinator = SyncExecutionCoordinator(syncFeatureFlags: featureFlags, runner: runner)

        let report = try await coordinator.runIfEnabled()

        XCTAssertNil(report)
        let callCount = await runner.runCallCount
        XCTAssertEqual(callCount, 0)
    }

    func testRunIfEnabledExecutesRunnerWhenFeatureFlagEnabled() async throws {
        let expected = SyncRunReport.fixture(appliedCount: 3)
        let featureFlags = InMemorySyncFeatureFlags(isSyncEnabled: true)
        let runner = SyncRunExecutorSpy(reportToReturn: expected)
        let coordinator = SyncExecutionCoordinator(syncFeatureFlags: featureFlags, runner: runner)

        let report = try await coordinator.runIfEnabled()

        XCTAssertEqual(report, expected)
        let callCount = await runner.runCallCount
        XCTAssertEqual(callCount, 1)
    }

    func testRunIfEnabledPropagatesRunnerErrorWhenEnabled() async {
        let featureFlags = InMemorySyncFeatureFlags(isSyncEnabled: true)
        let runner = SyncRunExecutorSpy(errorToThrow: SyncExecutionTestError.expected)
        let coordinator = SyncExecutionCoordinator(syncFeatureFlags: featureFlags, runner: runner)

        await XCTAssertThrowsErrorAsync(try await coordinator.runIfEnabled()) { error in
            XCTAssertEqual(error as? SyncExecutionTestError, .expected)
        }
    }
}

private enum SyncExecutionTestError: Error, Equatable {
    case expected
}

private final class InMemorySyncFeatureFlags: SyncFeatureFlagProviding, @unchecked Sendable {
    var isSyncEnabled: Bool

    init(isSyncEnabled: Bool) {
        self.isSyncEnabled = isSyncEnabled
    }

    func setSyncEnabled(_ enabled: Bool) {
        isSyncEnabled = enabled
    }
}

private actor SyncRunExecutorSpy: SyncRunExecuting {
    private(set) var runCallCount = 0
    private let reportToReturn: SyncRunReport
    private let errorToThrow: Error?

    init(
        reportToReturn: SyncRunReport = .fixture(),
        errorToThrow: Error? = nil
    ) {
        self.reportToReturn = reportToReturn
        self.errorToThrow = errorToThrow
    }

    func runOnce() async throws -> SyncRunReport {
        runCallCount += 1
        if let errorToThrow {
            throw errorToThrow
        }
        return reportToReturn
    }
}

private extension SyncRunReport {
    static func fixture(appliedCount: Int = 1) -> SyncRunReport {
        .init(
            pushedCount: 2,
            pulledCount: 4,
            appliedCount: appliedCount,
            updatedCursor: Date(timeIntervalSince1970: 123)
        )
    }
}

private func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ errorHandler: (Error) -> Void,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Expected expression to throw", file: file, line: line)
    } catch {
        errorHandler(error)
    }
}
