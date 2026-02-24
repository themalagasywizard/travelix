import XCTest
@testable import TravelJournalCore

final class ErrorPresentationTests: XCTestCase {
    func testDatabaseFailureMapsToRetryBanner() {
        let banner = ErrorPresentationMapper.banner(for: .databaseFailure)

        XCTAssertEqual(banner.title, TJStrings.ErrorPresentation.databaseTitle)
        XCTAssertEqual(banner.message, TJStrings.ErrorPresentation.databaseMessage)
        XCTAssertEqual(banner.actionTitle, TJStrings.ErrorPresentation.databaseAction)
    }

    func testInvalidInputKeepsProvidedMessage() {
        let banner = ErrorPresentationMapper.banner(for: .invalidInput(message: "End date must be after start date"))

        XCTAssertEqual(banner.title, TJStrings.ErrorPresentation.invalidInputTitle)
        XCTAssertEqual(banner.message, "End date must be after start date")
        XCTAssertNil(banner.actionTitle)
    }

    func testUnknownMapsToSafeFallbackBanner() {
        let banner = ErrorPresentationMapper.banner(for: .unknown)

        XCTAssertEqual(banner.title, TJStrings.ErrorPresentation.unknownTitle)
        XCTAssertEqual(banner.actionTitle, TJStrings.ErrorPresentation.unknownAction)
    }
}
