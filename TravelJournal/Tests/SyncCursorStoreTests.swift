import Foundation
import XCTest
@testable import TravelJournalData

final class SyncCursorStoreTests: XCTestCase {
    func testLastPulledAtRoundTrip() {
        let defaults = UserDefaults(suiteName: "SyncCursorStoreTests.roundTrip")!
        defaults.removePersistentDomain(forName: "SyncCursorStoreTests.roundTrip")
        let store = UserDefaultsSyncCursorStore(userDefaults: defaults, key: "cursor")

        XCTAssertNil(store.lastPulledAt())

        let now = Date(timeIntervalSince1970: 12345)
        store.save(lastPulledAt: now)

        XCTAssertEqual(store.lastPulledAt(), now)
    }

    func testSaveNilClearsPersistedCursor() {
        let defaults = UserDefaults(suiteName: "SyncCursorStoreTests.clear")!
        defaults.removePersistentDomain(forName: "SyncCursorStoreTests.clear")
        let store = UserDefaultsSyncCursorStore(userDefaults: defaults, key: "cursor")

        store.save(lastPulledAt: Date(timeIntervalSince1970: 99))
        XCTAssertNotNil(store.lastPulledAt())

        store.save(lastPulledAt: nil)

        XCTAssertNil(store.lastPulledAt())
    }
}
