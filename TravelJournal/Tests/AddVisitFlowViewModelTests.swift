import XCTest
@testable import TravelJournalUI

@MainActor
final class AddVisitFlowViewModelTests: XCTestCase {
    func testStepNavigationBounds() {
        let viewModel = AddVisitFlowViewModel()

        XCTAssertEqual(viewModel.currentStep, .location)
        XCTAssertFalse(viewModel.canGoBack)

        viewModel.goBack()
        XCTAssertEqual(viewModel.currentStep, .location)

        viewModel.goNext()
        XCTAssertEqual(viewModel.currentStep, .dates)
        XCTAssertTrue(viewModel.canGoBack)

        viewModel.goNext()
        XCTAssertEqual(viewModel.currentStep, .content)
        XCTAssertTrue(viewModel.isLastStep)

        viewModel.goNext()
        XCTAssertEqual(viewModel.currentStep, .content)
    }

    func testDraftUpdates() {
        let viewModel = AddVisitFlowViewModel()
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let end = Date(timeIntervalSince1970: 1_700_086_400)

        viewModel.updateLocationQuery("Tokyo")
        viewModel.updateDates(start: start, end: end)
        viewModel.updateContent(note: "Sakura everywhere", photoItemCount: 12)

        XCTAssertEqual(viewModel.draft.locationQuery, "Tokyo")
        XCTAssertEqual(viewModel.draft.startDate, start)
        XCTAssertEqual(viewModel.draft.endDate, end)
        XCTAssertEqual(viewModel.draft.note, "Sakura everywhere")
        XCTAssertEqual(viewModel.draft.photoItemCount, 12)
    }
}
