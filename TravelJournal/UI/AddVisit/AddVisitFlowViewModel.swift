import Foundation
import Combine

public struct AddVisitDraft: Equatable {
    public var locationQuery: String
    public var startDate: Date
    public var endDate: Date
    public var note: String
    public var photoItemCount: Int

    public init(
        locationQuery: String = "",
        startDate: Date = Date(),
        endDate: Date = Date(),
        note: String = "",
        photoItemCount: Int = 0
    ) {
        self.locationQuery = locationQuery
        self.startDate = startDate
        self.endDate = endDate
        self.note = note
        self.photoItemCount = photoItemCount
    }
}

@MainActor
public final class AddVisitFlowViewModel: ObservableObject {
    public enum Step: Int, CaseIterable {
        case location
        case dates
        case content

        public var title: String {
            switch self {
            case .location: return "Location"
            case .dates: return "Dates"
            case .content: return "Content"
            }
        }
    }

    @Published public private(set) var currentStep: Step = .location
    @Published public private(set) var draft: AddVisitDraft

    public init(draft: AddVisitDraft = .init()) {
        self.draft = draft
    }

    public func updateLocationQuery(_ query: String) {
        draft.locationQuery = query
    }

    public func updateDates(start: Date, end: Date) {
        draft.startDate = start
        draft.endDate = end
    }

    public func updateContent(note: String, photoItemCount: Int) {
        draft.note = note
        draft.photoItemCount = max(0, photoItemCount)
    }

    public func goNext() {
        guard let next = Step(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = next
    }

    public func goBack() {
        guard let previous = Step(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = previous
    }

    public var canGoBack: Bool {
        currentStep != .location
    }

    public var isLastStep: Bool {
        currentStep == .content
    }
}
