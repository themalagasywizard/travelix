import Foundation
import Combine
import TravelJournalCore
import TravelJournalData

@MainActor
public final class DeveloperToolsViewModel: ObservableObject {
    @Published public private(set) var statusMessage: String?
    @Published public private(set) var isSeeding = false
    @Published public private(set) var cacheSummary: String?

    private let seeder: DemoDataSeeding
    private let thumbnailCache: ThumbnailCache?

    public init(seeder: DemoDataSeeding, thumbnailCache: ThumbnailCache? = nil) {
        self.seeder = seeder
        self.thumbnailCache = thumbnailCache
        refreshThumbnailCacheSummary()
    }

    public func loadDemoData() {
        guard !isSeeding else { return }
        isSeeding = true
        defer { isSeeding = false }

        do {
            let report = try seeder.seedIfNeeded(targetPlaces: 50, targetVisits: 120)
            if report.placesInserted == 0, report.visitsInserted == 0 {
                statusMessage = "Demo data already loaded"
            } else {
                statusMessage = "Loaded \(report.placesInserted) places and \(report.visitsInserted) visits"
            }
        } catch {
            statusMessage = "Failed to load demo data: \(error.localizedDescription)"
        }
    }

    public func clearThumbnailCache() {
        guard let thumbnailCache else {
            cacheSummary = "Thumbnail cache unavailable"
            return
        }

        do {
            try thumbnailCache.removeAll()
            refreshThumbnailCacheSummary()
            statusMessage = "Cleared thumbnail cache"
        } catch {
            statusMessage = "Failed to clear thumbnail cache: \(error.localizedDescription)"
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
            cacheSummary = "Thumbnail cache: \(stats.entryCount) files (\(bytesText))"
        } catch {
            cacheSummary = "Thumbnail cache: unavailable"
        }
    }
}
