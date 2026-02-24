import SwiftUI
import TravelJournalCore

public struct TripsListView: View {
    @StateObject private var viewModel: TripsListViewModel

    public init(viewModel: @autoclosure @escaping () -> TripsListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        List {
            ForEach(viewModel.rows) { row in
                VStack(alignment: .leading, spacing: 6) {
                    Text(row.title)
                        .font(.headline)
                    Text(row.dateRangeText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(row.visitCountText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                .accessibilityIdentifier(TJAccessibility.Identifier.tripsRowPrefix + row.id.uuidString.lowercased())
                .accessibilityLabel(TJAccessibility.Label.tripsRow(title: row.title, dateRange: row.dateRangeText, visitCount: row.visitCountText))
            }
        }
        .accessibilityIdentifier(TJAccessibility.Identifier.tripsList)
        .accessibilityLabel(TJAccessibility.Label.tripsList)
        .listStyle(.insetGrouped)
        .navigationTitle(TJStrings.Trips.title)
        .task {
            viewModel.loadTrips()
        }
        .overlay(alignment: .top) {
            if let banner = viewModel.errorBanner {
                Text(TJStrings.Trips.banner(title: banner.title, message: banner.message))
                    .font(.footnote)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.88))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .padding(.top, 8)
                    .accessibilityIdentifier(TJAccessibility.Identifier.tripsErrorBanner)
                    .accessibilityLabel(TJAccessibility.Label.tripsErrorBanner)
            }
        }
    }
}
