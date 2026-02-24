import Foundation
import CoreGraphics

public enum TJSpacing {
    public static let x1: CGFloat = 4
    public static let x2: CGFloat = 8
    public static let x3: CGFloat = 12
    public static let x4: CGFloat = 16
    public static let x6: CGFloat = 24
    public static let x8: CGFloat = 32
}

public enum TJRadius {
    public static let sm: CGFloat = 12
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 24
}

public struct TJTypographyToken: Equatable {
    public let size: CGFloat
    public let lineHeight: CGFloat

    public init(size: CGFloat, lineHeight: CGFloat) {
        self.size = size
        self.lineHeight = lineHeight
    }
}

public enum TJTypography {
    public static let largeTitle = TJTypographyToken(size: 34, lineHeight: 41)
    public static let title2 = TJTypographyToken(size: 22, lineHeight: 28)
    public static let body = TJTypographyToken(size: 17, lineHeight: 22)
    public static let callout = TJTypographyToken(size: 16, lineHeight: 21)
    public static let footnote = TJTypographyToken(size: 13, lineHeight: 18)
    public static let caption = TJTypographyToken(size: 12, lineHeight: 16)
}

public struct TJShadowToken: Equatable {
    public let x: CGFloat
    public let y: CGFloat
    public let blur: CGFloat
    public let opacity: CGFloat

    public init(x: CGFloat, y: CGFloat, blur: CGFloat, opacity: CGFloat) {
        self.x = x
        self.y = y
        self.blur = blur
        self.opacity = opacity
    }
}

public enum TJShadow {
    public static let card = TJShadowToken(x: 0, y: 6, blur: 18, opacity: 0.12)
    public static let floating = TJShadowToken(x: 0, y: 10, blur: 28, opacity: 0.16)
}
