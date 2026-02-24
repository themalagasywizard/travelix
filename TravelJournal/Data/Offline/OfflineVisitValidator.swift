import Foundation
import TravelJournalCore
import TravelJournalDomain

public struct OfflineVisitValidationReport: Equatable {
    public let visitID: UUID
    public let requiredThumbnailSizes: [Int]
    public let totalMediaCount: Int
    public let fullyCachedMediaCount: Int
    public let missingThumbnailRequests: [ThumbnailRequest]

    public init(
        visitID: UUID,
        requiredThumbnailSizes: [Int],
        totalMediaCount: Int,
        fullyCachedMediaCount: Int,
        missingThumbnailRequests: [ThumbnailRequest]
    ) {
        self.visitID = visitID
        self.requiredThumbnailSizes = requiredThumbnailSizes
        self.totalMediaCount = totalMediaCount
        self.fullyCachedMediaCount = fullyCachedMediaCount
        self.missingThumbnailRequests = missingThumbnailRequests
    }

    public var isOfflineReady: Bool {
        missingThumbnailRequests.isEmpty
    }
}

public final class OfflineVisitValidator {
    private let mediaRepository: MediaRepository
    private let thumbnailCache: ThumbnailCache

    public init(mediaRepository: MediaRepository, thumbnailCache: ThumbnailCache) {
        self.mediaRepository = mediaRepository
        self.thumbnailCache = thumbnailCache
    }

    public func validateVisit(
        _ visitID: UUID,
        requiredThumbnailSizes: [Int] = [512]
    ) throws -> OfflineVisitValidationReport {
        let mediaItems = try mediaRepository.fetchMedia(forVisit: visitID)
        var missing: [ThumbnailRequest] = []
        var fullyCachedCount = 0

        for media in mediaItems {
            var mediaHasAllSizes = true
            for size in requiredThumbnailSizes {
                let request = ThumbnailRequest(mediaID: media.id, pixelSize: size)
                if try thumbnailCache.load(for: request) == nil {
                    missing.append(request)
                    mediaHasAllSizes = false
                }
            }
            if mediaHasAllSizes {
                fullyCachedCount += 1
            }
        }

        return OfflineVisitValidationReport(
            visitID: visitID,
            requiredThumbnailSizes: requiredThumbnailSizes,
            totalMediaCount: mediaItems.count,
            fullyCachedMediaCount: fullyCachedCount,
            missingThumbnailRequests: missing
        )
    }
}
