import SwiftUI
import TravelJournalCore

public struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    public init(viewModel: @autoclosure @escaping () -> HomeViewModel = HomeViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        ZStack(alignment: .top) {
            GlobeSceneView(
                configuration: .init(radius: 1.0, earthTextureName: nil, pins: viewModel.visiblePins),
                onPinSelected: viewModel.handlePinSelected
            )
            .ignoresSafeArea()
            .accessibilityLabel(TJAccessibility.Label.homeGlobe)

            VStack(spacing: 10) {
                searchBar
                filtersRow

                if let selectedPlaceID = viewModel.selectedPlaceID {
                    Text("Selected: \(selectedPlaceID)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .accessibilityIdentifier(TJAccessibility.Identifier.homeSelectedPlaceBadge)
                        .accessibilityLabel(TJAccessibility.Label.selectedPlace(selectedPlaceID))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
        }
        .background(Color.black)
        .sheet(item: selectedPlaceStoryItem, onDismiss: viewModel.clearSelectedPlace) { item in
            PlaceStoryView(viewModel: item.viewModel)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search places, trips, spots, tags", text: $viewModel.searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityIdentifier(TJAccessibility.Identifier.homeSearchField)
                .accessibilityLabel(TJAccessibility.Label.homeSearchField)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var selectedPlaceStoryItem: PlaceStorySheetItem? {
        guard let viewModel = viewModel.selectedPlaceStoryViewModel,
              let selectedID = self.viewModel.selectedPlaceID
        else {
            return nil
        }
        return PlaceStorySheetItem(id: selectedID, viewModel: viewModel)
    }

    private var filtersRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(HomeViewModel.FilterChip.allCases) { filter in
                    Button {
                        viewModel.toggleFilter(filter)
                    } label: {
                        Text(filter.rawValue)
                            .font(.footnote.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedFilters.contains(filter) ? Color.white.opacity(0.24) : Color.white.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .accessibilityIdentifier(TJAccessibility.Identifier.homeFilterChipPrefix + filter.rawValue.lowercased())
                    .accessibilityLabel(TJAccessibility.Label.filterChip(filter.rawValue, isSelected: viewModel.selectedFilters.contains(filter)))
                }
            }
        }
    }
}

private struct PlaceStorySheetItem: Identifiable {
    let id: String
    let viewModel: PlaceStoryViewModel
}
