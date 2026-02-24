import XCTest
@testable import TravelJournalCore

final class SyncFeatureFlagsTests: XCTestCase {
    func testDefaultSyncFlagIsDisabled() {
        let userDefaults = UserDefaults(suiteName: "SyncFeatureFlagsTests-default")!
        userDefaults.removePersistentDomain(forName: "SyncFeatureFlagsTests-default")

        let store = UserDefaultsSyncFeatureFlagStore(userDefaults: userDefaults, key: "sync-enabled")

        XCTAssertFalse(store.isSyncEnabled)
    }

    func testSetSyncFlagPersistsEnabledAndDisabledStates() {
        let userDefaults = UserDefaults(suiteName: "SyncFeatureFlagsTests-persist")!
        userDefaults.removePersistentDomain(forName: "SyncFeatureFlagsTests-persist")

        let store = UserDefaultsSyncFeatureFlagStore(userDefaults: userDefaults, key: "sync-enabled")
        XCTAssertFalse(store.isSyncEnabled)

        store.setSyncEnabled(true)
        XCTAssertTrue(store.isSyncEnabled)

        store.setSyncEnabled(false)
        XCTAssertFalse(store.isSyncEnabled)
    }
}
