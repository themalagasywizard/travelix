import Foundation
#if canImport(UIKit)
import UIKit
#endif

public enum HapticEvent: Equatable {
    case selection
    case success
    case warning
    case error
}

public protocol HapticsEngine {
    func trigger(_ event: HapticEvent)
}

public final class HapticsClient {
    private let engine: HapticsEngine

    public init(engine: HapticsEngine = DefaultHapticsEngine()) {
        self.engine = engine
    }

    public func selection() {
        engine.trigger(.selection)
    }

    public func notifySuccess() {
        engine.trigger(.success)
    }

    public func notifyWarning() {
        engine.trigger(.warning)
    }

    public func notifyError() {
        engine.trigger(.error)
    }
}

public final class DefaultHapticsEngine: HapticsEngine {
    public init() {}

    public func trigger(_ event: HapticEvent) {
        #if canImport(UIKit)
        importUIKitTrigger(event)
        #else
        // No-op fallback for non-UIKit environments.
        _ = event
        #endif
    }

    #if canImport(UIKit)
    private func importUIKitTrigger(_ event: HapticEvent) {
        switch event {
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.warning)
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.error)
        }
    }
    #endif
}
