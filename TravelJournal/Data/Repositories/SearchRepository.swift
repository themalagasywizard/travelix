import Foundation
import GRDB

public enum SearchResultKind: String, Codable, Equatable {
    case place
    case trip
    case visit
    case spot
    case tag
}

public struct SearchResult: Equatable {
    public let kind: SearchResultKind
    public let id: UUID
    public let title: String
    public let subtitle: String?

    public init(kind: SearchResultKind, id: UUID, title: String, subtitle: String?) {
        self.kind = kind
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }
}

public protocol SearchRepository {
    func search(_ query: String, limit: Int) throws -> [SearchResult]
}

public final class GRDBSearchRepository: SearchRepository {
    private let dbQueue: DatabaseQueue

    public init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    public func search(_ query: String, limit: Int = 50) throws -> [SearchResult] {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return [] }

        let pattern = "%\(normalized)%"

        return try dbQueue.read { db in
            let sql = """
            SELECT kind, item_id, title, subtitle
            FROM (
                SELECT
                    'place' AS kind,
                    p.id AS item_id,
                    p.name AS title,
                    p.country AS subtitle,
                    1 AS priority
                FROM places p
                WHERE lower(p.name) LIKE lower(?)
                   OR lower(COALESCE(p.country, '')) LIKE lower(?)

                UNION ALL

                SELECT
                    'trip' AS kind,
                    tr.id AS item_id,
                    tr.name AS title,
                    NULL AS subtitle,
                    2 AS priority
                FROM trips tr
                WHERE lower(tr.name) LIKE lower(?)

                UNION ALL

                SELECT
                    'visit' AS kind,
                    v.id AS item_id,
                    COALESCE(v.summary, 'Visit') AS title,
                    p.name AS subtitle,
                    3 AS priority
                FROM visits v
                INNER JOIN places p ON p.id = v.place_id
                WHERE lower(COALESCE(v.summary, '')) LIKE lower(?)
                   OR lower(COALESCE(v.notes, '')) LIKE lower(?)

                UNION ALL

                SELECT
                    'spot' AS kind,
                    s.id AS item_id,
                    s.name AS title,
                    p.name AS subtitle,
                    4 AS priority
                FROM spots s
                INNER JOIN visits v ON v.id = s.visit_id
                INNER JOIN places p ON p.id = v.place_id
                WHERE lower(s.name) LIKE lower(?)
                   OR lower(COALESCE(s.note, '')) LIKE lower(?)
                   OR lower(COALESCE(s.category, '')) LIKE lower(?)

                UNION ALL

                SELECT
                    'tag' AS kind,
                    t.id AS item_id,
                    t.name AS title,
                    NULL AS subtitle,
                    5 AS priority
                FROM tags t
                WHERE lower(t.name) LIKE lower(?)
            )
            ORDER BY priority ASC, title COLLATE NOCASE ASC
            LIMIT ?
            """

            let rows = try Row.fetchAll(
                db,
                sql: sql,
                arguments: [pattern, pattern, pattern, pattern, pattern, pattern, pattern, pattern, pattern, limit]
            )

            return rows.compactMap { row in
                guard
                    let kindRaw: String = row["kind"],
                    let kind = SearchResultKind(rawValue: kindRaw),
                    let itemIDRaw: String = row["item_id"],
                    let id = UUID(uuidString: itemIDRaw),
                    let title: String = row["title"]
                else {
                    return nil
                }

                let subtitle: String? = row["subtitle"]
                return SearchResult(kind: kind, id: id, title: title, subtitle: subtitle)
            }
        }
    }
}
