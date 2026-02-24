import Foundation
import GRDB

public struct DatabasePerformanceSample: Equatable {
    public let operation: String
    public let durationMs: Double

    public init(operation: String, durationMs: Double) {
        self.operation = operation
        self.durationMs = durationMs
    }
}

public enum DatabasePerformanceBenchmark {
    /// Measures database bootstrap time (queue open + migrations).
    public static func measureColdStart(path: String) throws -> DatabasePerformanceSample {
        let start = DispatchTime.now().uptimeNanoseconds
        _ = try DatabaseManager(path: path)
        let end = DispatchTime.now().uptimeNanoseconds

        return DatabasePerformanceSample(
            operation: "db_cold_start",
            durationMs: Double(end - start) / 1_000_000.0
        )
    }

    /// Measures read path over visits after deterministic fixture insertion.
    public static func measureVisitRead(dbQueue: DatabaseQueue, rows: Int) throws -> DatabasePerformanceSample {
        precondition(rows >= 0, "rows must be non-negative")

        try dbQueue.write { db in
            try db.execute(sql: "DELETE FROM visits")
            try db.execute(sql: "DELETE FROM places")

            let now = Date().timeIntervalSince1970
            for i in 0..<rows {
                let placeID = UUID().uuidString.lowercased()
                let visitID = UUID().uuidString.lowercased()
                try db.execute(
                    sql: "INSERT INTO places (id, name, country, latitude, longitude, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)",
                    arguments: [placeID, "Place \(i)", "Country", 10.0, 20.0, now, now]
                )
                try db.execute(
                    sql: "INSERT INTO visits (id, place_id, trip_id, start_date, end_date, summary, notes, created_at, updated_at, mood) VALUES (?, ?, NULL, ?, ?, ?, ?, ?, ?, ?)",
                    arguments: [visitID, placeID, now, now + 10, "Summary \(i)", "Notes \(i)", now, now, ""]
                )
            }
        }

        let start = DispatchTime.now().uptimeNanoseconds
        try dbQueue.read { db in
            _ = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM visits")
        }
        let end = DispatchTime.now().uptimeNanoseconds

        return DatabasePerformanceSample(
            operation: "db_visit_read",
            durationMs: Double(end - start) / 1_000_000.0
        )
    }
}
