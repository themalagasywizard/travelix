import Foundation

public struct Place: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var country: String?
    public var latitude: Double
    public var longitude: Double
    public var createdAt: Date
    public var updatedAt: Date
}

public struct Trip: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var startDate: Date?
    public var endDate: Date?
    public var coverMediaID: UUID?
    public var createdAt: Date
    public var updatedAt: Date
}

public struct Visit: Identifiable, Codable, Equatable {
    public let id: UUID
    public var placeID: UUID
    public var tripID: UUID?
    public var startDate: Date
    public var endDate: Date
    public var summary: String?
    public var notes: String?
    public var createdAt: Date
    public var updatedAt: Date
}

public struct Spot: Identifiable, Codable, Equatable {
    public let id: UUID
    public var visitID: UUID
    public var name: String
    public var category: String?
    public var latitude: Double?
    public var longitude: Double?
    public var address: String?
    public var rating: Int?
    public var note: String?
    public var createdAt: Date
    public var updatedAt: Date
}

public struct Media: Identifiable, Codable, Equatable {
    public let id: UUID
    public var visitID: UUID
    public var localIdentifier: String?
    public var fileURL: String?
    public var width: Int?
    public var height: Int?
    public var createdAt: Date
    public var updatedAt: Date
}

public struct Tag: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
}
