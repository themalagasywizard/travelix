import XCTest
@testable import TravelJournalCore

final class GlobePinRenderBenchmarkTests: XCTestCase {
    func testMakeBenchmarkPinsCountAndDeterministicIDs() {
        let pins = GlobePinRenderBenchmark.makeBenchmarkPins(count: 200)

        XCTAssertEqual(pins.count, 200)
        XCTAssertEqual(pins.first?.id, "bench-0")
        XCTAssertEqual(pins.last?.id, "bench-199")
    }

    func testMeasurePinGenerationReturnsResultFor200Pins() {
        let result = GlobePinRenderBenchmark.measurePinGeneration(pinCount: 200, radius: 1.0)

        XCTAssertEqual(result.pinCount, 200)
        XCTAssertGreaterThanOrEqual(result.durationMs, 0)
    }

    func testMeasurePinGenerationHandlesZeroPins() {
        let result = GlobePinRenderBenchmark.measurePinGeneration(pinCount: 0)
        XCTAssertEqual(result.pinCount, 0)
        XCTAssertGreaterThanOrEqual(result.durationMs, 0)
    }
}
