import Foundation

public protocol SyncRunStatusStoring: Sendable {
    func lastSuccessfulSyncAt() -> Date?
    func saveLastSuccessfulSync(at date: Date?)
}

public struct UserDefaultsSyncRunStatusStore: SyncRunStatusStoring {
    private let userDefaults: UserDefaults
    private let key: String

    public init(
        userDefaults: UserDefaults = .standard,
        key: String = "traveljournal.sync.lastSuccessfulSyncAt"
    ) {
        self.userDefaults = userDefaults
        self.key = key
    }

    public func lastSuccessfulSyncAt() -> Date? {
        userDefaults.object(forKey: key) as? Date
    }

    public func saveLastSuccessfulSync(at date: Date?) {
        if let date {
            userDefaults.set(date, forKey: key)
        } else {
            userDefaults.removeObject(forKey: key)
        }
    }
}
