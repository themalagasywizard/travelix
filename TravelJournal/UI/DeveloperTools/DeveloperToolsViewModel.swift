import Foundation
import Combine
import TravelJournalCore
import TravelJournalData

@MainActor
public final class DeveloperToolsViewModel: ObservableObject {
    @Published public private(set) var statusMessage: String?
    @Published public private(set) var errorBanner: ErrorBannerModel?
    @Published public private(set) var isSeeding = false
    @Published public private(set) var cacheSummary: String?

    private let seeder: DemoDataSeeding
    private let thumbnailCache: ThumbnailCache?

    public init(seeder: DemoDataSeeding, thumbnailCache: ThumbnailCache? = nil) {
        self.seeder = seeder
        self.thumbnailCache = thumbnailCache
        refreshThumbnailCacheSummary()
    }

    public convenience init(thumbnailCache: ThumbnailCache? = nil) {
        self.init(seeder: UnavailableDemoDataSeeder(), thumbnailCache: thumbnailCache)
    }

    public func loadDemoData() {
        guard !isSeeding else { return }
        isSeeding = true
        defer { isSeeding = false }

        do {
            let report = try seeder.seedIfNeeded(targetPlaces: 50, targetVisits: 120)
            errorBanner = nil
            if report.placesInserted == 0, report.visitsInserted == 0 {
                statusMessage = TJStrings.DeveloperTools.demoDataAlreadyLoaded
            } else {
                statusMessage = TJStrings.DeveloperTools.loadedDemoData(places: report.placesInserted, visits: report.visitsInserted)
            }
        } catch {
            statusMessage = TJStrings.DeveloperTools.failedToLoadDemoData(error.localizedDescription)
            errorBanner = ErrorPresentationMapper.banner(for: .databaseFailure)
        }
    }

    public func clearThumbnailCache() {
        guard let thumbnailCache else {
            cacheSummary = TJStrings.DeveloperTools.thumbnailCacheUnavailable
            return
        }

        do {
            try thumbnailCache.removeAll()
            refreshThumbnailCacheSummary()
            errorBanner = nil
            statusMessage = TJStrings.DeveloperTools.clearedThumbnailCache
        } catch {
            statusMessage = TJStrings.DeveloperTools.failedToClearThumbnailCache(error.localizedDescription)
            errorBanner = ErrorPresentationMapper.banner(for: .databaseFailure)
        }
    }

    public func refreshThumbnailCacheSummary() {
        guard let thumbnailCache else {
            cacheSummary = nil
            return
        }

        do {
            let stats = try thumbnailCache.stats()
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useKB, .useMB]
            formatter.countStyle = .file
            formatter.includesUnit = true
            let bytesText = formatter.string(fromByteCount: Int64(stats.totalBytes))
            cacheSummary = TJStrings.DeveloperTools.thumbnailCacheSummary(files: stats.entryCount, bytesText: bytesText)
        } catch {
            cacheSummary = TJStrings.DeveloperTools.thumbnailCacheUnavailableSummary
        }
    }
}

private struct UnavailableDemoDataSeeder: DemoDataSeeding {
    func seedIfNeeded(targetPlaces: Int, targetVisits: Int) throws -> DemoSeedReport {
        throw NSError(
            domain: "DeveloperTools",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: TJStrings.DeveloperTools.unavailableDemoSeederError]
        )
    }
}
