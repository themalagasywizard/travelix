import XCTest
@testable import TravelJournalCore

final class GlobeCoordinateConverterTests: XCTestCase {
    func testEquatorPrimeMeridianMapsToPositiveZAxis() {
        let v = GlobeCoordinateConverter.latLonToCartesian(latitude: 0, longitude: 0, radius: 1)

        XCTAssertEqual(v.x, 0, accuracy: 0.000_001)
        XCTAssertEqual(v.y, 0, accuracy: 0.000_001)
        XCTAssertEqual(v.z, 1, accuracy: 0.000_001)
    }

    func testNorthPoleMapsToPositiveYAxis() {
        let v = GlobeCoordinateConverter.latLonToCartesian(latitude: 90, longitude: 0, radius: 1)

        XCTAssertEqual(v.x, 0, accuracy: 0.000_001)
        XCTAssertEqual(v.y, 1, accuracy: 0.000_001)
        XCTAssertEqual(v.z, 0, accuracy: 0.000_001)
    }

    func testEquatorAt90EastMapsToPositiveXAxis() {
        let v = GlobeCoordinateConverter.latLonToCartesian(latitude: 0, longitude: 90, radius: 1)

        XCTAssertEqual(v.x, 1, accuracy: 0.000_001)
        XCTAssertEqual(v.y, 0, accuracy: 0.000_001)
        XCTAssertEqual(v.z, 0, accuracy: 0.000_001)
    }

    func testRadiusScalingIsApplied() {
        let v = GlobeCoordinateConverter.latLonToCartesian(latitude: 0, longitude: 0, radius: 3.5)

        XCTAssertEqual(v.x, 0, accuracy: 0.000_001)
        XCTAssertEqual(v.y, 0, accuracy: 0.000_001)
        XCTAssertEqual(v.z, 3.5, accuracy: 0.000_001)
    }
}
