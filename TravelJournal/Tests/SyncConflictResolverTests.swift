import Foundation
import XCTest
@testable import TravelJournalData

final class SyncConflictResolverTests: XCTestCase {
    func testResolveLastWriteWinsReturnsRemoteWhenRemoteIsNewer() {
        let local = SyncConflictValue(value: "local", updatedAt: Date(timeIntervalSince1970: 100))
        let remote = SyncConflictValue(value: "remote", updatedAt: Date(timeIntervalSince1970: 101))

        let resolved = SyncConflictResolver.resolveLastWriteWins(local: local, remote: remote)

        XCTAssertEqual(resolved, remote)
    }

    func testResolveLastWriteWinsReturnsRemoteWhenTimestampsTie() {
        let tieDate = Date(timeIntervalSince1970: 100)
        let local = SyncConflictValue(value: "local", updatedAt: tieDate)
        let remote = SyncConflictValue(value: "remote", updatedAt: tieDate)

        let resolved = SyncConflictResolver.resolveLastWriteWins(local: local, remote: remote)

        XCTAssertEqual(resolved, remote)
    }

    func testResolveLastWriteWinsReturnsLocalWhenLocalIsNewer() {
        let local = SyncConflictValue(value: "local", updatedAt: Date(timeIntervalSince1970: 102))
        let remote = SyncConflictValue(value: "remote", updatedAt: Date(timeIntervalSince1970: 101))

        let resolved = SyncConflictResolver.resolveLastWriteWins(local: local, remote: remote)

        XCTAssertEqual(resolved, local)
    }
}
