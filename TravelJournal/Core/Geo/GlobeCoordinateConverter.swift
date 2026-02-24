import Foundation

public struct GlobeVector3: Equatable {
    public let x: Double
    public let y: Double
    public let z: Double

    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public enum GlobeCoordinateConverter {
    /// Converts WGS84-like latitude/longitude degrees to a cartesian point on a sphere.
    /// - Parameters:
    ///   - latitude: Degrees in range [-90, 90]
    ///   - longitude: Degrees in range [-180, 180]
    ///   - radius: Sphere radius in scene units
    public static func latLonToCartesian(latitude: Double, longitude: Double, radius: Double = 1.0) -> GlobeVector3 {
        let lat = latitude * .pi / 180
        let lon = longitude * .pi / 180

        let x = radius * cos(lat) * sin(lon)
        let y = radius * sin(lat)
        let z = radius * cos(lat) * cos(lon)

        return GlobeVector3(x: x, y: y, z: z)
    }
}
