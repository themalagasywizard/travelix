import Foundation

public protocol SyncCursorStoring: Sendable {
    func lastPulledAt() -> Date?
    func save(lastPulledAt: Date?)
}

public struct UserDefaultsSyncCursorStore: SyncCursorStoring {
    private let userDefaults: UserDefaults
    private let key: String

    public init(
        userDefaults: UserDefaults = .standard,
        key: String = "traveljournal.sync.lastPulledAt"
    ) {
        self.userDefaults = userDefaults
        self.key = key
    }

    public func lastPulledAt() -> Date? {
        userDefaults.object(forKey: key) as? Date
    }

    public func save(lastPulledAt: Date?) {
        if let lastPulledAt {
            userDefaults.set(lastPulledAt, forKey: key)
        } else {
            userDefaults.removeObject(forKey: key)
        }
    }
}
