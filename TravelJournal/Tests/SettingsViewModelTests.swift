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

    func testRunSyncNowNoopsWhenActionUnavailable() async {
        let store = SyncFeatureFlagStoreStub(isSyncEnabled: true)
        let viewModel = SettingsViewModel(syncFeatureFlags: store)

        await viewModel.runSyncNow()

        XCTAssertFalse(viewModel.canRunSyncNow)
        XCTAssertNil(viewModel.syncStatusMessage)
        XCTAssertFalse(viewModel.isRunningSyncNow)
    }

    func testRunSyncNowPromptsToEnableWhenSyncFlagDisabled() async {
        let store = SyncFeatureFlagStoreStub(isSyncEnabled: false)
        let recorder = SyncNowActionRecorder(result: .success("unexpected"))
        let viewModel = SettingsViewModel(syncFeatureFlags: store, runSyncNowAction: recorder.action)

        await viewModel.runSyncNow()

        XCTAssertEqual(recorder.callCount, 0)
        XCTAssertEqual(viewModel.syncStatusMessage, "Enable iCloud Sync to run a sync now")
        XCTAssertFalse(viewModel.isRunningSyncNow)
    }

    func testRunSyncNowStoresSuccessStatusMessage() async {
        let store = SyncFeatureFlagStoreStub(isSyncEnabled: true)
        let recorder = SyncNowActionRecorder(result: .success("Sync finished: pushed 2, pulled 1, applied 1"))
        let viewModel = SettingsViewModel(syncFeatureFlags: store, runSyncNowAction: recorder.action)

        await viewModel.runSyncNow()

        XCTAssertEqual(recorder.callCount, 1)
        XCTAssertEqual(viewModel.syncStatusMessage, "Sync finished: pushed 2, pulled 1, applied 1")
        XCTAssertFalse(viewModel.isRunningSyncNow)
    }

    func testRunSyncNowStoresFailureStatusMessage() async {
        let store = SyncFeatureFlagStoreStub(isSyncEnabled: true)
        let recorder = SyncNowActionRecorder(result: .failure(SyncNowActionRecorder.TestError.networkDown))
        let viewModel = SettingsViewModel(syncFeatureFlags: store, runSyncNowAction: recorder.action)

        await viewModel.runSyncNow()

        XCTAssertEqual(recorder.callCount, 1)
        XCTAssertEqual(viewModel.syncStatusMessage, "Sync failed: The operation could not be completed. (SettingsViewModelTests.SyncNowActionRecorder.TestError error 0.)")
        XCTAssertFalse(viewModel.isRunningSyncNow)
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

private final class SyncNowActionRecorder: @unchecked Sendable {
    enum TestError: Error {
        case networkDown
    }

    private(set) var callCount = 0
    private let result: Result<String, Error>

    init(result: Result<String, Error>) {
        self.result = result
    }

    var action: @Sendable () async throws -> String {
        { [self] in
            callCount += 1
            switch result {
            case .success(let message):
                return message
            case .failure(let error):
                throw error
            }
        }
    }
}
