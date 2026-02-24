import XCTest
@testable import TravelJournalCore
@testable import TravelJournalUI

@MainActor
final class SettingsViewModelTests: XCTestCase {
    func testInitLoadsCurrentSyncFlagValue() {
        let store = SyncFeatureFlagStoreStub(isSyncEnabled: true)

        let viewModel = SettingsViewModel(syncFeatureFlags: store)

        XCTAssertTrue(viewModel.isSyncEnabled)
    }

    func testSetSyncEnabledPersistsChange() {
        let store = SyncFeatureFlagStoreStub(isSyncEnabled: false)
        let viewModel = SettingsViewModel(syncFeatureFlags: store)

        viewModel.setSyncEnabled(true)

        XCTAssertTrue(viewModel.isSyncEnabled)
        XCTAssertEqual(store.setCalls, [true])
    }

    func testSetSyncEnabledDoesNotPersistWhenUnchanged() {
        let store = SyncFeatureFlagStoreStub(isSyncEnabled: false)
        let viewModel = SettingsViewModel(syncFeatureFlags: store)

        viewModel.setSyncEnabled(false)

        XCTAssertEqual(store.setCalls, [])
    }
}

private final class SyncFeatureFlagStoreStub: SyncFeatureFlagProviding {
    private(set) var isSyncEnabled: Bool
    private(set) var setCalls: [Bool] = []

    init(isSyncEnabled: Bool) {
        self.isSyncEnabled = isSyncEnabled
    }

    func setSyncEnabled(_ enabled: Bool) {
        setCalls.append(enabled)
        isSyncEnabled = enabled
    }
}
