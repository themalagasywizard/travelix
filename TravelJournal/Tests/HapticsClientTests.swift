import XCTest
@testable import TravelJournalCore

final class HapticsClientTests: XCTestCase {
    func testSelectionRoutesToEngine() {
        let engine = RecordingHapticsEngine()
        let client = HapticsClient(engine: engine)

        client.selection()

        XCTAssertEqual(engine.events, [.selection])
    }

    func testNotificationVariantsRouteToEngineInOrder() {
        let engine = RecordingHapticsEngine()
        let client = HapticsClient(engine: engine)

        client.notifySuccess()
        client.notifyWarning()
        client.notifyError()

        XCTAssertEqual(engine.events, [.success, .warning, .error])
    }
}

private final class RecordingHapticsEngine: HapticsEngine {
    private(set) var events: [HapticEvent] = []

    func trigger(_ event: HapticEvent) {
        events.append(event)
    }
}
