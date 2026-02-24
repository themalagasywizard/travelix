import XCTest
@testable import TravelJournalUI
@testable import TravelJournalData
@testable import TravelJournalDomain

@MainActor
final class VisitSpotsEditorViewModelTests: XCTestCase {
    func testAddAndDeleteSpot() {
        let visitID = UUID()
        let repository = InMemorySpotRepository()
        let viewModel = VisitSpotsEditorViewModel(visitID: visitID, repository: repository)

        viewModel.addSpot(name: "Time Out Market", category: "food", note: "Try croquettes")

        XCTAssertEqual(viewModel.spots.count, 1)
        XCTAssertEqual(viewModel.spots.first?.name, "Time Out Market")

        let id = try! XCTUnwrap(viewModel.spots.first?.id)
        viewModel.deleteSpot(id: id)

        XCTAssertTrue(viewModel.spots.isEmpty)
    }

    func testUpdateSpotChangesValues() {
        let visitID = UUID()
        let repository = InMemorySpotRepository()
        let viewModel = VisitSpotsEditorViewModel(visitID: visitID, repository: repository)

        viewModel.addSpot(name: "Old", category: "food", note: nil)
        let id = try! XCTUnwrap(viewModel.spots.first?.id)

        viewModel.updateSpot(id: id, name: "New", category: "cafe", note: "Great coffee")

        XCTAssertEqual(viewModel.spots.first?.name, "New")
        XCTAssertEqual(viewModel.spots.first?.category, "cafe")
        XCTAssertEqual(viewModel.spots.first?.note, "Great coffee")
    }
}

private final class InMemorySpotRepository: SpotRepository {
    private var storage: [Spot] = []

    func addSpot(_ spot: Spot) throws {
        storage.append(spot)
    }

    func updateSpot(_ spot: Spot) throws {
        guard let index = storage.firstIndex(where: { $0.id == spot.id }) else { return }
        storage[index] = spot
    }

    func deleteSpot(id: UUID) throws {
        storage.removeAll { $0.id == id }
    }

    func fetchSpots(forVisit visitID: UUID) throws -> [Spot] {
        storage.filter { $0.visitID == visitID }
    }
}
