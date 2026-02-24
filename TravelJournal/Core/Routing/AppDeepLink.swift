import Foundation

public enum AppDeepLink: Equatable {
    case place(id: String)
    case visit(id: String)
    case trip(id: String)

    public init?(url: URL) {
        let scheme = (url.scheme ?? "").lowercased()

        if ["place", "visit", "trip"].contains(scheme) {
            guard let rawID = AppDeepLink.extractID(from: url), rawID.isEmpty == false else {
                return nil
            }

            switch scheme {
            case "place":
                self = .place(id: rawID)
            case "visit":
                self = .visit(id: rawID)
            case "trip":
                self = .trip(id: rawID)
            default:
                return nil
            }
            return
        }

        if scheme == "traveljournal" {
            let components = url.pathComponents.filter { $0 != "/" }
            guard components.count >= 2 else { return nil }

            let kind = components[0].lowercased()
            let rawID = components[1]
            guard rawID.isEmpty == false else { return nil }

            switch kind {
            case "place":
                self = .place(id: rawID)
            case "visit":
                self = .visit(id: rawID)
            case "trip":
                self = .trip(id: rawID)
            default:
                return nil
            }
            return
        }

        return nil
    }

    private static func extractID(from url: URL) -> String? {
        if let host = url.host(), host.isEmpty == false {
            return host
        }

        let trimmedPath = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return trimmedPath.isEmpty ? nil : trimmedPath
    }
}
