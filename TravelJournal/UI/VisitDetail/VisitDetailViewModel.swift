import Foundation
import Combine

public struct VisitSpotRow: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let category: String
    public let ratingText: String?
    public let note: String?

    public init(id: String, name: String, category: String, ratingText: String? = nil, note: String? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.ratingText = ratingText
        self.note = note
    }
}

@MainActor
public final class VisitDetailViewModel: ObservableObject {
    @Published public private(set) var title: String
    @Published public private(set) var dateRangeText: String
    @Published public private(set) var summary: String?
    @Published public private(set) var notes: String?
    @Published public private(set) var photoCount: Int
    @Published public private(set) var spots: [VisitSpotRow]
    @Published public private(set) var recommendations: [String]

    public init(
        title: String,
        dateRangeText: String,
        summary: String?,
        notes: String?,
        photoCount: Int,
        spots: [VisitSpotRow],
        recommendations: [String]
    ) {
        self.title = title
        self.dateRangeText = dateRangeText
        self.summary = summary
        self.notes = notes
        self.photoCount = photoCount
        self.spots = spots
        self.recommendations = recommendations
    }

    public var photoSectionTitle: String {
        "Photos (\(photoCount))"
    }
}
