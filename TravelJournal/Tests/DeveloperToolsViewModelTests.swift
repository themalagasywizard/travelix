import XCTest
@testable import TravelJournalData
@testable import TravelJournalUI

@MainActor
final class DeveloperToolsViewModelTests: XCTestCase {
    func testLoadDemoDataUpdatesSuccessMessage() {
        let seeder = SeederStub(result: .success(DemoSeedReport(placesInserted: 50, visitsInserted: 120)))
        let viewModel = DeveloperToolsViewModel(seeder: seeder)

        viewModel.loadDemoData()

        XCTAssertEqual(viewModel.statusMessage, "Loaded 50 places and 120 visits")
        XCTAssertFalse(viewModel.isSeeding)
    }

    func testLoadDemoDataHandlesAlreadyLoadedCase() {
        let seeder = SeederStub(result: .success(DemoSeedReport(placesInserted: 0, visitsInserted: 0)))
        let viewModel = DeveloperToolsViewModel(seeder: seeder)

        viewModel.loadDemoData()

        XCTAssertEqual(viewModel.statusMessage, "Demo data already loaded")
    }
}

private struct SeederStub: DemoDataSeeding {
    enum StubError: Error { case failed }

    let result: Result<DemoSeedReport, Error>

    func seedIfNeeded(targetPlaces: Int, targetVisits: Int) throws -> DemoSeedReport {
        try result.get()
    }
}
