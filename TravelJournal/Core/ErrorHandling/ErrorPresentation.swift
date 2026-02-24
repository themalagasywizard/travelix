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
                title: TJStrings.ErrorPresentation.databaseTitle,
                message: TJStrings.ErrorPresentation.databaseMessage,
                actionTitle: TJStrings.ErrorPresentation.databaseAction
            )
        case .mediaImportFailed:
            return ErrorBannerModel(
                title: TJStrings.ErrorPresentation.mediaImportTitle,
                message: TJStrings.ErrorPresentation.mediaImportMessage,
                actionTitle: TJStrings.ErrorPresentation.mediaImportAction
            )
        case .invalidInput(let message):
            return ErrorBannerModel(
                title: TJStrings.ErrorPresentation.invalidInputTitle,
                message: message,
                actionTitle: nil
            )
        case .unknown:
            return ErrorBannerModel(
                title: TJStrings.ErrorPresentation.unknownTitle,
                message: TJStrings.ErrorPresentation.unknownMessage,
                actionTitle: TJStrings.ErrorPresentation.unknownAction
            )
        }
    }
}
