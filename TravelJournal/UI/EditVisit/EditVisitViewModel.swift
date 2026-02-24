import Foundation
import Combine

@MainActor
public final class EditVisitViewModel: ObservableObject {
    @Published public private(set) var visitID: String
    @Published public var locationName: String
    @Published public var startDate: Date
    @Published public var endDate: Date
    @Published public var summary: String
    @Published public var notes: String

    public init(
        visitID: String,
        locationName: String,
        startDate: Date,
        endDate: Date,
        summary: String,
        notes: String
    ) {
        self.visitID = visitID
        self.locationName = locationName
        self.startDate = startDate
        self.endDate = endDate
        self.summary = summary
        self.notes = notes
    }

    public func applyEdits(
        locationName: String,
        startDate: Date,
        endDate: Date,
        summary: String,
        notes: String
    ) {
        self.locationName = locationName
        self.startDate = startDate
        self.endDate = endDate
        self.summary = summary
        self.notes = notes
    }

    public var hasValidDateRange: Bool {
        endDate >= startDate
    }
}
