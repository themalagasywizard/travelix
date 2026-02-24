import SwiftUI

public struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    public init(viewModel: @autoclosure @escaping () -> HomeViewModel = HomeViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        ZStack(alignment: .top) {
            GlobeSceneView(
                configuration: .init(radius: 1.0, earthTextureName: nil, pins: viewModel.pins),
                onPinSelected: viewModel.handlePinSelected
            )
            .ignoresSafeArea()

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
                }
            }
        }
    }
}

private struct PlaceStorySheetItem: Identifiable {
    let id: String
    let viewModel: PlaceStoryViewModel
}
