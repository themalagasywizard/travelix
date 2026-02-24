import Foundation

public enum TJAppError: Error, Equatable {
    case databaseFailure
    case mediaImportFailed
    case invalidInput(message: String)
    case unknown
}

public struct ErrorBannerModel: Equatable {
    public let title: String
    public let message: String
    public let actionTitle: String?

    public init(title: String, message: String, actionTitle: String?) {
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
    }
}

public enum ErrorPresentationMapper {
    public static func banner(for error: TJAppError) -> ErrorBannerModel {
        switch error {
        case .databaseFailure:
            return ErrorBannerModel(
                title: "Something went wrong",
                message: "We couldn’t save your data. Please try again.",
                actionTitle: "Retry"
            )
        case .mediaImportFailed:
            return ErrorBannerModel(
                title: "Import failed",
                message: "We couldn’t import one or more photos.",
                actionTitle: "Try Again"
            )
        case .invalidInput(let message):
            return ErrorBannerModel(
                title: "Check your input",
                message: message,
                actionTitle: nil
            )
        case .unknown:
            return ErrorBannerModel(
                title: "Unexpected error",
                message: "Please try again in a moment.",
                actionTitle: "Dismiss"
            )
        }
    }
}
