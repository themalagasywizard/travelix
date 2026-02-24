import Foundation

public enum TJMotionCurve: String, Equatable {
    case easeInOut
    case spring
    case snappy
}

public struct TJMotionToken: Equatable {
    public let duration: TimeInterval
    public let curve: TJMotionCurve

    public init(duration: TimeInterval, curve: TJMotionCurve) {
        self.duration = duration
        self.curve = curve
    }
}

public enum TJMotion {
    // Keep motion restrained to avoid "spring soup" and preserve premium feel.
    public static let quickFade = TJMotionToken(duration: 0.16, curve: .easeInOut)
    public static let standardTransition = TJMotionToken(duration: 0.24, curve: .easeInOut)
    public static let emphasizedTransition = TJMotionToken(duration: 0.32, curve: .snappy)
    public static let globeFocus = TJMotionToken(duration: 0.42, curve: .spring)
}

public enum TJMotionPreset: CaseIterable {
    case quickFade
    case standardTransition
    case emphasizedTransition
    case globeFocus

    public var token: TJMotionToken {
        switch self {
        case .quickFade: return TJMotion.quickFade
        case .standardTransition: return TJMotion.standardTransition
        case .emphasizedTransition: return TJMotion.emphasizedTransition
        case .globeFocus: return TJMotion.globeFocus
        }
    }
}
