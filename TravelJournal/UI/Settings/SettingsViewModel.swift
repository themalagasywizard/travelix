import Foundation
import TravelJournalCore

@MainActor
public final class SettingsViewModel: ObservableObject {
    @Published public var isSyncEnabled: Bool
    @Published public private(set) var isRunningSyncNow = false
    @Published public private(set) var syncStatusMessage: String?
    @Published public private(set) var syncErrorBanner: ErrorBannerModel?
    @Published public private(set) var lastSuccessfulSyncDescription: String?

    public var canRunSyncNow: Bool {
        runSyncNowAction != nil
    }

    private let syncFeatureFlags: SyncFeatureFlagProviding
    private let runSyncNowAction: (@Sendable () async throws -> String)?
    private let syncRunStatusStore: SyncRunStatusStoring?
    private let now: @Sendable () -> Date
    private let dateString: @Sendable (Date) -> String

    public init(
        syncFeatureFlags: SyncFeatureFlagProviding,
        runSyncNowAction: (@Sendable () async throws -> String)? = nil,
        syncRunStatusStore: SyncRunStatusStoring? = nil,
        now: @escaping @Sendable () -> Date = Date.init,
        dateString: @escaping @Sendable (Date) -> String = Self.defaultDateString
    ) {
        self.syncFeatureFlags = syncFeatureFlags
        self.runSyncNowAction = runSyncNowAction
        self.syncRunStatusStore = syncRunStatusStore
        self.now = now
        self.dateString = dateString
        self.isSyncEnabled = syncFeatureFlags.isSyncEnabled

        if let lastSuccessful = syncRunStatusStore?.lastSuccessfulSyncAt() {
            lastSuccessfulSyncDescription = "Last successful sync: \(dateString(lastSuccessful))"
        }
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
            syncErrorBanner = ErrorPresentationMapper.banner(
                for: .invalidInput(message: "Enable iCloud Sync to run a sync now")
            )
            return
        }

        isRunningSyncNow = true
        defer { isRunningSyncNow = false }

        do {
            syncErrorBanner = nil
            syncStatusMessage = try await runSyncNowAction() ?? "Sync finished"
            let timestamp = now()
            syncRunStatusStore?.saveLastSuccessfulSync(at: timestamp)
            lastSuccessfulSyncDescription = "Last successful sync: \(dateString(timestamp))"
        } catch {
            syncStatusMessage = "Sync failed: \(error.localizedDescription)"
            syncErrorBanner = ErrorPresentationMapper.banner(for: .databaseFailure)
        }
    }

    private static func defaultDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
