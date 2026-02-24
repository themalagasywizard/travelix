import Foundation
import GRDB

public protocol DemoDataSeeding {
    @discardableResult
    func seedIfNeeded(targetPlaces: Int, targetVisits: Int) throws -> DemoSeedReport
}

public struct DemoSeedReport: Equatable {
    public let placesInserted: Int
    public let visitsInserted: Int
}

public final class DemoDataSeeder: DemoDataSeeding {
    private let dbQueue: DatabaseQueue

    public init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    @discardableResult
    public func seedIfNeeded(targetPlaces: Int = 50, targetVisits: Int = 120) throws -> DemoSeedReport {
        try dbQueue.write { db in
            let existingPlaces = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM places") ?? 0
            let existingVisits = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM visits") ?? 0

            guard existingPlaces == 0, existingVisits == 0 else {
                return DemoSeedReport(placesInserted: 0, visitsInserted: 0)
            }

            let now = Date().timeIntervalSince1970
            var generator = SeededGenerator(seed: 42)
            var placeIDs: [String] = []

            for idx in 0..<targetPlaces {
                let placeID = UUID().uuidString.lowercased()
                placeIDs.append(placeID)

                let city = DemoData.cityNames[idx % DemoData.cityNames.count]
                let country = DemoData.countryNames[idx % DemoData.countryNames.count]
                let coordinate = DemoData.coordinates[idx % DemoData.coordinates.count]

                try db.execute(
                    sql: """
                    INSERT INTO places (id, name, country, latitude, longitude, created_at, updated_at)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    """,
                    arguments: [placeID, city, country, coordinate.lat, coordinate.lon, now, now]
                )
            }

            for idx in 0..<targetVisits {
                let visitID = UUID().uuidString.lowercased()
                let placeID = placeIDs[idx % placeIDs.count]
                let startOffsetDays = Int.random(in: 0...900, using: &generator)
                let durationDays = Int.random(in: 1...7, using: &generator)
                let startDate = now - Double(startOffsetDays * 86_400)
                let endDate = startDate + Double(durationDays * 86_400)

                let summary = DemoData.summaries[idx % DemoData.summaries.count]
                let note = DemoData.notes[idx % DemoData.notes.count]

                try db.execute(
                    sql: """
                    INSERT INTO visits (id, place_id, trip_id, start_date, end_date, summary, notes, created_at, updated_at)
                    VALUES (?, ?, NULL, ?, ?, ?, ?, ?, ?)
                    """,
                    arguments: [visitID, placeID, startDate, endDate, summary, note, now, now]
                )
            }

            return DemoSeedReport(placesInserted: targetPlaces, visitsInserted: targetVisits)
        }
    }
}

private enum DemoData {
    static let cityNames = [
        "Paris", "Tokyo", "Lisbon", "Seoul", "Rome", "Barcelona", "Cape Town", "Montreal", "Bangkok", "Istanbul"
    ]

    static let countryNames = [
        "France", "Japan", "Portugal", "South Korea", "Italy", "Spain", "South Africa", "Canada", "Thailand", "Turkey"
    ]

    static let coordinates: [(lat: Double, lon: Double)] = [
        (48.8566, 2.3522), (35.6764, 139.6500), (38.7223, -9.1393), (37.5665, 126.9780), (41.9028, 12.4964),
        (41.3851, 2.1734), (-33.9249, 18.4241), (45.5017, -73.5673), (13.7563, 100.5018), (41.0082, 28.9784)
    ]

    static let summaries = [
        "Weekend getaway", "Food-focused trip", "City break", "Museum and culture", "Work + exploration"
    ]

    static let notes = [
        "Saved top spots and cafés.",
        "Would revisit during spring.",
        "Great local food and long walks.",
        "Packed schedule but worth it.",
        "Best memories around sunset viewpoints."
    ]
}

private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }
}
