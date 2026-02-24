import Foundation

public struct SyncConflictValue<T: Equatable>: Equatable {
    public let value: T
    public let updatedAt: Date

    public init(value: T, updatedAt: Date) {
        self.value = value
        self.updatedAt = updatedAt
    }
}

public enum SyncConflictResolver {
    /// v1 policy: last-write-wins using updatedAt timestamp.
    public static func resolveLastWriteWins<T: Equatable>(
        local: SyncConflictValue<T>,
        remote: SyncConflictValue<T>
    ) -> SyncConflictValue<T> {
        if remote.updatedAt >= local.updatedAt {
            return remote
        }

        return local
    }
}
