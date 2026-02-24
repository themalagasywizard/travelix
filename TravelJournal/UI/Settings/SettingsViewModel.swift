import Foundation
import TravelJournalCore

@MainActor
public final class SettingsViewModel: ObservableObject {
    @Published public var isSyncEnabled: Bool
    @Published public private(set) var isRunningSyncNow = false
    @Published public private(set) var syncStatusMessage: String?

    public var canRunSyncNow: Bool {
        runSyncNowAction != nil
    }

    private let syncFeatureFlags: SyncFeatureFlagProviding
    private let runSyncNowAction: (@Sendable () async throws -> String)?

    public init(
        syncFeatureFlags: SyncFeatureFlagProviding,
        runSyncNowAction: (@Sendable () async throws -> String)? = nil
    ) {
        self.syncFeatureFlags = syncFeatureFlags
        self.runSyncNowAction = runSyncNowAction
        self.isSyncEnabled = syncFeatureFlags.isSyncEnabled
    }

    public func setSyncEnabled(_ enabled: Bool) {
        guard isSyncEnabled != enabled else { return }
        isSyncEnabled = enabled
        syncFeatureFlags.setSyncEnabled(enabled)
    }

    public func runSyncNow() async {
        guard let runSyncNowAction else { return }
        guard isSyncEnabled else {
            syncStatusMessage = "Enable iCloud Sync to run a sync now"
            return
        }

        isRunningSyncNow = true
        defer { isRunningSyncNow = false }

        do {
            syncStatusMessage = try await runSyncNowAction() ?? "Sync finished"
        } catch {
            syncStatusMessage = "Sync failed: \(error.localizedDescription)"
        }
    }
}
