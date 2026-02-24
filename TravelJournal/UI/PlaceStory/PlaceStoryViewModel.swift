import Foundation
import Combine

public struct PlaceStoryVisitRow: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let dateRangeText: String
    public let summary: String?

    public init(id: String, title: String, dateRangeText: String, summary: String?) {
        self.id = id
        self.title = title
        self.dateRangeText = dateRangeText
        self.summary = summary
    }
}

@MainActor
public final class PlaceStoryViewModel: ObservableObject {
    @Published public private(set) var placeName: String
    @Published public private(set) var countryName: String
    @Published public private(set) var visitCountText: String
    @Published public private(set) var visits: [PlaceStoryVisitRow]

    public init(
        placeName: String,
        countryName: String,
        visits: [PlaceStoryVisitRow]
    ) {
        self.placeName = placeName
        self.countryName = countryName
        self.visits = visits
        self.visitCountText = "\(visits.count) \(visits.count == 1 ? "visit" : "visits")"
    }

    public func apply(visits: [PlaceStoryVisitRow]) {
        self.visits = visits
        self.visitCountText = "\(visits.count) \(visits.count == 1 ? "visit" : "visits")"
    }
}
