import Foundation
import TravelJournalCore

public protocol SyncRunExecuting: Sendable {
    func runOnce() async throws -> SyncRunReport
}

extension SyncOrchestrator: SyncRunExecuting {}

public struct SyncExecutionCoordinator: Sendable {
    private let syncFeatureFlags: SyncFeatureFlagProviding
    private let runner: SyncRunExecuting

    public init(
        syncFeatureFlags: SyncFeatureFlagProviding,
        runner: SyncRunExecuting
    ) {
        self.syncFeatureFlags = syncFeatureFlags
        self.runner = runner
    }

    public func runIfEnabled() async throws -> SyncRunReport? {
        guard syncFeatureFlags.isSyncEnabled else {
            return nil
        }

        return try await runner.runOnce()
    }
}
