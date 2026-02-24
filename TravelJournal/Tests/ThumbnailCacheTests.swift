import XCTest
@testable import TravelJournalCore

final class ThumbnailCacheTests: XCTestCase {
    func testStoreAndLoadRoundTripFromDiskCache() throws {
        let fileManager = FileManager.default
        let root = fileManager.temporaryDirectory.appendingPathComponent("traveljournal-thumbnail-tests-\(UUID().uuidString)")
        defer { try? fileManager.removeItem(at: root) }

        let cache = try DefaultThumbnailCache(rootDirectory: root)
        let request = ThumbnailRequest(mediaID: UUID(), pixelSize: 512)
        let payload = Data([0xAA, 0xBB, 0xCC, 0xDD])

        try cache.store(payload, for: request)

        let loaded = try cache.load(for: request)
        XCTAssertEqual(loaded, payload)
    }

    func testRemoveAllClearsMemoryAndDiskEntries() throws {
        let fileManager = FileManager.default
        let root = fileManager.temporaryDirectory.appendingPathComponent("traveljournal-thumbnail-tests-\(UUID().uuidString)")
        defer { try? fileManager.removeItem(at: root) }

        let cache = try DefaultThumbnailCache(rootDirectory: root)
        let request = ThumbnailRequest(mediaID: UUID(), pixelSize: 1024)
        try cache.store(Data([0x01, 0x02, 0x03]), for: request)

        try cache.removeAll()

        XCTAssertNil(try cache.load(for: request))
        let files = try fileManager.contentsOfDirectory(at: root, includingPropertiesForKeys: nil)
        XCTAssertTrue(files.isEmpty)
    }
}
