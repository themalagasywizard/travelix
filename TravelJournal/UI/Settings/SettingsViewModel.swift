import Foundation
import TravelJournalCore

@MainActor
public final class SettingsViewModel: ObservableObject {
    @Published public var isSyncEnabled: Bool

    private let syncFeatureFlags: SyncFeatureFlagProviding

    public init(syncFeatureFlags: SyncFeatureFlagProviding) {
        self.syncFeatureFlags = syncFeatureFlags
        self.isSyncEnabled = syncFeatureFlags.isSyncEnabled
    }

    public func setSyncEnabled(_ enabled: Bool) {
        guard isSyncEnabled != enabled else { return }
        isSyncEnabled = enabled
        syncFeatureFlags.setSyncEnabled(enabled)
    }
}
