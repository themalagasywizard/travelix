import XCTest
@testable import TravelJournalCore

final class AppDeepLinkTests: XCTestCase {
    func testParsesSchemeBasedLinks() {
        XCTAssertEqual(AppDeepLink(url: URL(string: "place://tokyo-pin")!), .place(id: "tokyo-pin"))
        XCTAssertEqual(AppDeepLink(url: URL(string: "visit://abc123")!), .visit(id: "abc123"))
        XCTAssertEqual(AppDeepLink(url: URL(string: "trip://trip-2025")!), .trip(id: "trip-2025"))
    }

    func testParsesPathBasedTravelJournalLinks() {
        XCTAssertEqual(AppDeepLink(url: URL(string: "traveljournal://open/place/tokyo-pin")!), .place(id: "tokyo-pin"))
        XCTAssertEqual(AppDeepLink(url: URL(string: "traveljournal://open/visit/visit-42")!), .visit(id: "visit-42"))
        XCTAssertEqual(AppDeepLink(url: URL(string: "traveljournal://open/trip/trip-2026")!), .trip(id: "trip-2026"))
    }

    func testRejectsUnsupportedOrMissingIdentifiers() {
        XCTAssertNil(AppDeepLink(url: URL(string: "https://example.com/place/tokyo")!))
        XCTAssertNil(AppDeepLink(url: URL(string: "place://")!))
        XCTAssertNil(AppDeepLink(url: URL(string: "traveljournal://open/place/")!))
    }
}
