import Foundation
import Combine
import TravelJournalData

@MainActor
public final class DeveloperToolsViewModel: ObservableObject {
    @Published public private(set) var statusMessage: String?
    @Published public private(set) var isSeeding = false

    private let seeder: DemoDataSeeding

    public init(seeder: DemoDataSeeding) {
        self.seeder = seeder
    }

    public func loadDemoData() {
        guard !isSeeding else { return }
        isSeeding = true
        defer { isSeeding = false }

        do {
            let report = try seeder.seedIfNeeded(targetPlaces: 50, targetVisits: 120)
            if report.placesInserted == 0, report.visitsInserted == 0 {
                statusMessage = "Demo data already loaded"
            } else {
                statusMessage = "Loaded \(report.placesInserted) places and \(report.visitsInserted) visits"
            }
        } catch {
            statusMessage = "Failed to load demo data: \(error.localizedDescription)"
        }
    }
}
