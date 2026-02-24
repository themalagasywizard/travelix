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
    @Published public private(set) var selectedVisitID: String?

    public init(
        placeName: String,
        countryName: String,
        visits: [PlaceStoryVisitRow]
    ) {
        self.placeName = placeName
        self.countryName = countryName
        self.visits = visits
        self.selectedVisitID = nil
        self.visitCountText = "\(visits.count) \(visits.count == 1 ? "visit" : "visits")"
    }

    public func apply(visits: [PlaceStoryVisitRow]) {
        self.visits = visits
        self.visitCountText = "\(visits.count) \(visits.count == 1 ? "visit" : "visits")"

        if let selectedVisitID, visits.contains(where: { $0.id == selectedVisitID }) == false {
            self.selectedVisitID = nil
        }
    }

    public func selectVisit(_ visitID: String) {
        guard visits.contains(where: { $0.id == visitID }) else { return }
        selectedVisitID = visitID
    }

    public func clearSelectedVisit() {
        selectedVisitID = nil
    }

    public var selectedVisitDetailViewModel: VisitDetailViewModel? {
        guard let selectedVisitID,
              let visit = visits.first(where: { $0.id == selectedVisitID })
        else {
            return nil
        }

        return VisitDetailViewModel(
            title: visit.title,
            dateRangeText: visit.dateRangeText,
            summary: visit.summary,
            notes: visit.summary,
            photoCount: 0,
            spots: [],
            recommendations: []
        )
    }
}
