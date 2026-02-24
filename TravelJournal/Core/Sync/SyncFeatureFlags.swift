import Foundation

public protocol SyncFeatureFlagProviding: Sendable {
    var isSyncEnabled: Bool { get }
    func setSyncEnabled(_ enabled: Bool)
}

public final class UserDefaultsSyncFeatureFlagStore: SyncFeatureFlagProviding {
    public static let defaultKey = "traveljournal.feature.sync.enabled"

    private let userDefaults: UserDefaults
    private let key: String

    public init(userDefaults: UserDefaults = .standard, key: String = defaultKey) {
        self.userDefaults = userDefaults
        self.key = key

        if userDefaults.object(forKey: key) == nil {
            userDefaults.set(false, forKey: key)
        }
    }

    public var isSyncEnabled: Bool {
        userDefaults.bool(forKey: key)
    }

    public func setSyncEnabled(_ enabled: Bool) {
        userDefaults.set(enabled, forKey: key)
    }
}
