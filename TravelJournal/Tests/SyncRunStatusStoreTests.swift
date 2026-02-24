import Foundation
import XCTest
@testable import TravelJournalData

final class SyncRunStatusStoreTests: XCTestCase {
    func testSaveAndLoadLastSuccessfulSyncTimestamp() {
        let suite = "SyncRunStatusStoreTests.save-load.\(UUID().uuidString)"
        guard let userDefaults = UserDefaults(suiteName: suite) else {
            return XCTFail("Failed to create test UserDefaults suite")
        }
        userDefaults.removePersistentDomain(forName: suite)
        defer {
            userDefaults.removePersistentDomain(forName: suite)
        }

        let store = UserDefaultsSyncRunStatusStore(userDefaults: userDefaults, key: "test.key")
        let timestamp = Date(timeIntervalSince1970: 1234)

        store.saveLastSuccessfulSync(at: timestamp)

        XCTAssertEqual(store.lastSuccessfulSyncAt(), timestamp)
    }

    func testSaveNilClearsStoredTimestamp() {
        let suite = "SyncRunStatusStoreTests.clear.\(UUID().uuidString)"
        guard let userDefaults = UserDefaults(suiteName: suite) else {
            return XCTFail("Failed to create test UserDefaults suite")
        }
        userDefaults.removePersistentDomain(forName: suite)
        defer {
            userDefaults.removePersistentDomain(forName: suite)
        }

        let store = UserDefaultsSyncRunStatusStore(userDefaults: userDefaults, key: "test.key")
        store.saveLastSuccessfulSync(at: Date(timeIntervalSince1970: 42))

        store.saveLastSuccessfulSync(at: nil)

        XCTAssertNil(store.lastSuccessfulSyncAt())
    }
}
