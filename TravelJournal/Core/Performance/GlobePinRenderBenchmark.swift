import Foundation

public struct GlobeBenchmarkPin: Equatable {
    public let id: String
    public let latitude: Double
    public let longitude: Double

    public init(id: String, latitude: Double, longitude: Double) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct GlobePinRenderBenchmarkResult: Equatable {
    public let pinCount: Int
    public let durationMs: Double

    public init(pinCount: Int, durationMs: Double) {
        self.pinCount = pinCount
        self.durationMs = durationMs
    }
}

public enum GlobePinRenderBenchmark {
    /// Measures only the CPU-side pin generation/conversion path.
    /// SceneKit draw/GPU timing must be profiled on an Xcode/Instruments runner.
    public static func measurePinGeneration(pinCount: Int, radius: Double = 1.0) -> GlobePinRenderBenchmarkResult {
        precondition(pinCount >= 0, "pinCount must be non-negative")

        let pins = makeBenchmarkPins(count: pinCount)
        let start = DispatchTime.now().uptimeNanoseconds

        _ = pins.map {
            GlobeCoordinateConverter.latLonToCartesian(
                latitude: $0.latitude,
                longitude: $0.longitude,
                radius: radius
            )
        }

        let end = DispatchTime.now().uptimeNanoseconds
        let durationMs = Double(end - start) / 1_000_000.0

        return GlobePinRenderBenchmarkResult(pinCount: pinCount, durationMs: durationMs)
    }

    public static func makeBenchmarkPins(count: Int) -> [GlobeBenchmarkPin] {
        precondition(count >= 0, "count must be non-negative")
        guard count > 0 else { return [] }

        var pins: [GlobeBenchmarkPin] = []
        pins.reserveCapacity(count)

        for i in 0..<count {
            let latitude = -70.0 + Double(i % 140)
            let longitude = -180.0 + Double((i * 17) % 360)
            pins.append(GlobeBenchmarkPin(id: "bench-\(i)", latitude: latitude, longitude: longitude))
        }

        return pins
    }
}
