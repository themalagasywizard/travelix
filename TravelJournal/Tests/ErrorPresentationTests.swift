import XCTest
@testable import TravelJournalCore

final class ErrorPresentationTests: XCTestCase {
    func testDatabaseFailureMapsToRetryBanner() {
        let banner = ErrorPresentationMapper.banner(for: .databaseFailure)

        XCTAssertEqual(banner.title, "Something went wrong")
        XCTAssertEqual(banner.message, "We couldn’t save your data. Please try again.")
        XCTAssertEqual(banner.actionTitle, "Retry")
    }

    func testInvalidInputKeepsProvidedMessage() {
        let banner = ErrorPresentationMapper.banner(for: .invalidInput(message: "End date must be after start date"))

        XCTAssertEqual(banner.title, "Check your input")
        XCTAssertEqual(banner.message, "End date must be after start date")
        XCTAssertNil(banner.actionTitle)
    }

    func testUnknownMapsToSafeFallbackBanner() {
        let banner = ErrorPresentationMapper.banner(for: .unknown)

        XCTAssertEqual(banner.title, "Unexpected error")
        XCTAssertEqual(banner.actionTitle, "Dismiss")
    }
}
