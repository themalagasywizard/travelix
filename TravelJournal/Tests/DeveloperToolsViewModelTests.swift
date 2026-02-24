import XCTest
@testable import TravelJournalCore
@testable import TravelJournalData
@testable import TravelJournalUI

@MainActor
final class DeveloperToolsViewModelTests: XCTestCase {
    func testLoadDemoDataUpdatesSuccessMessage() {
        let seeder = SeederStub(result: .success(DemoSeedReport(placesInserted: 50, visitsInserted: 120)))
        let viewModel = DeveloperToolsViewModel(seeder: seeder)

        viewModel.loadDemoData()

        XCTAssertEqual(viewModel.statusMessage, "Loaded 50 places and 120 visits")
        XCTAssertNil(viewModel.errorBanner)
        XCTAssertFalse(viewModel.isSeeding)
    }

    func testLoadDemoDataHandlesAlreadyLoadedCase() {
        let seeder = SeederStub(result: .success(DemoSeedReport(placesInserted: 0, visitsInserted: 0)))
        let viewModel = DeveloperToolsViewModel(seeder: seeder)

        viewModel.loadDemoData()

        XCTAssertEqual(viewModel.statusMessage, "Demo data already loaded")
    }

    func testRefreshThumbnailCacheSummaryShowsFileAndSize() {
        let seeder = SeederStub(result: .success(DemoSeedReport(placesInserted: 0, visitsInserted: 0)))
        let cache = ThumbnailCacheStub(stats: ThumbnailCacheStats(entryCount: 2, totalBytes: 2_048))
        let viewModel = DeveloperToolsViewModel(seeder: seeder, thumbnailCache: cache)

        XCTAssertEqual(viewModel.cacheSummary, "Thumbnail cache: 2 files (2 KB)")
    }

    func testClearThumbnailCacheUpdatesSummaryAndStatus() {
        let seeder = SeederStub(result: .success(DemoSeedReport(placesInserted: 0, visitsInserted: 0)))
        let cache = ThumbnailCacheStub(stats: ThumbnailCacheStats(entryCount: 1, totalBytes: 512))
        let viewModel = DeveloperToolsViewModel(seeder: seeder, thumbnailCache: cache)

        viewModel.clearThumbnailCache()

        XCTAssertEqual(cache.removeAllCallCount, 1)
        XCTAssertEqual(viewModel.cacheSummary?.hasPrefix("Thumbnail cache: 0 files ("), true)
        XCTAssertEqual(viewModel.statusMessage, "Cleared thumbnail cache")
    }

    func testFallbackInitializerReportsUnavailableSeeding() {
        let viewModel = DeveloperToolsViewModel()

        viewModel.loadDemoData()

        XCTAssertEqual(viewModel.statusMessage, "Failed to load demo data: Demo seeding is unavailable in this build context")
        XCTAssertEqual(viewModel.errorBanner, ErrorPresentationMapper.banner(for: .databaseFailure))
    }
}

private struct SeederStub: DemoDataSeeding {
    enum StubError: Error { case failed }

    let result: Result<DemoSeedReport, Error>

    func seedIfNeeded(targetPlaces: Int, targetVisits: Int) throws -> DemoSeedReport {
        try result.get()
    }
}

private final class ThumbnailCacheStub: ThumbnailCache {
    private(set) var statsValue: ThumbnailCacheStats
    private(set) var removeAllCallCount = 0

    init(stats: ThumbnailCacheStats) {
        self.statsValue = stats
    }

    func store(_ data: Data, for request: ThumbnailRequest) throws {}

    func load(for request: ThumbnailRequest) throws -> Data? { nil }

    func removeAll() throws {
        removeAllCallCount += 1
        statsValue = ThumbnailCacheStats(entryCount: 0, totalBytes: 0)
    }

    func stats() throws -> ThumbnailCacheStats {
        statsValue
    }
}
