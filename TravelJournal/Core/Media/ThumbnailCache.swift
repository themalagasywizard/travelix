import Foundation

public struct ThumbnailRequest: Hashable {
    public let mediaID: UUID
    public let pixelSize: Int

    public init(mediaID: UUID, pixelSize: Int) {
        self.mediaID = mediaID
        self.pixelSize = pixelSize
    }

    var cacheKey: String {
        "\(mediaID.uuidString.lowercased())_\(pixelSize)"
    }

    var fileName: String {
        "\(cacheKey).thumb"
    }
}

public protocol ThumbnailCache {
    func store(_ data: Data, for request: ThumbnailRequest) throws
    func load(for request: ThumbnailRequest) throws -> Data?
    func removeAll() throws
}

public final class DefaultThumbnailCache: ThumbnailCache {
    private let rootDirectory: URL
    private let fileManager: FileManager
    private let memoryCache = NSCache<NSString, NSData>()

    public init(rootDirectory: URL, fileManager: FileManager = .default) throws {
        self.rootDirectory = rootDirectory
        self.fileManager = fileManager
        try fileManager.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
    }

    public func store(_ data: Data, for request: ThumbnailRequest) throws {
        memoryCache.setObject(data as NSData, forKey: request.cacheKey as NSString)
        let url = rootDirectory.appendingPathComponent(request.fileName)
        try data.write(to: url, options: .atomic)
    }

    public func load(for request: ThumbnailRequest) throws -> Data? {
        if let inMemory = memoryCache.object(forKey: request.cacheKey as NSString) {
            return inMemory as Data
        }

        let url = rootDirectory.appendingPathComponent(request.fileName)
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        let data = try Data(contentsOf: url)
        memoryCache.setObject(data as NSData, forKey: request.cacheKey as NSString)
        return data
    }

    public func removeAll() throws {
        memoryCache.removeAllObjects()

        guard fileManager.fileExists(atPath: rootDirectory.path) else {
            return
        }

        let contents = try fileManager.contentsOfDirectory(at: rootDirectory, includingPropertiesForKeys: nil)
        for url in contents {
            try fileManager.removeItem(at: url)
        }
    }
}
