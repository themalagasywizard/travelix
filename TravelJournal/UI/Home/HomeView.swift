import SwiftUI
import TravelJournalCore
import TravelJournalData

public struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var isPinsListPresented = false
    @State private var isAddVisitPresented = false
    @State private var isSettingsPresented = false
    @State private var isTripsPresented = false
    @State private var addVisitViewModel = AddVisitFlowViewModel()
    @State private var tripsListViewModel: TripsListViewModel?
    @State private var deepLinkedVisitDetailViewModel: VisitDetailViewModel?

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
                if viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
                   viewModel.searchResults.isEmpty == false {
                    searchResultsCard
                }
                pinsListButton

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

                if let banner = viewModel.errorBanner {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(banner.title)
                                .font(.caption.weight(.semibold))
                            Text(banner.message)
                                .font(.caption2)
                        }

                        Spacer(minLength: 0)

                        Button("Dismiss") {
                            viewModel.clearErrorBanner()
                        }
                        .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .accessibilityIdentifier(TJAccessibility.Identifier.homeErrorBanner)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
        }
        .background(Color.black)
        .sheet(item: selectedPlaceStoryItem, onDismiss: viewModel.clearSelectedPlace) { item in
            PlaceStoryView(viewModel: item.viewModel)
        }
        .sheet(isPresented: $isPinsListPresented) {
            NavigationStack {
                List(viewModel.pinListItems) { item in
                    Button(item.title) {
                        viewModel.handlePinSelected(item.id)
                        isPinsListPresented = false
                    }
                    .accessibilityIdentifier(TJAccessibility.Identifier.homePinsListRowPrefix + item.id)
                    .accessibilityLabel(TJAccessibility.Label.pinListRow(item.title))
                }
                .accessibilityIdentifier(TJAccessibility.Identifier.homePinsList)
                .navigationTitle("Visible Pins")
            }
        }
        .sheet(isPresented: $isAddVisitPresented) {
            AddVisitFlowView(viewModel: addVisitViewModel) { result in
                viewModel.registerCreatedVisit(result)
                isAddVisitPresented = false
            }
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView(viewModel: SettingsViewModel(syncFeatureFlags: UserDefaultsSyncFeatureFlagStore()))
        }
        .sheet(isPresented: $isTripsPresented) {
            if let tripsListViewModel {
                NavigationStack {
                    TripsListView(viewModel: tripsListViewModel)
                }
            }
        }
        .onOpenURL { url in
            guard let deepLink = AppDeepLink(url: url) else { return }
            viewModel.handleDeepLink(deepLink)
            deepLinkedVisitDetailViewModel = viewModel.consumePendingVisitDeepLinkDetailViewModel()
        }
        .onChange(of: viewModel.pendingVisitDeepLinkID) { _, _ in
            deepLinkedVisitDetailViewModel = viewModel.consumePendingVisitDeepLinkDetailViewModel()
        }
        .sheet(item: deepLinkedVisitDetailSheetItem) { item in
            NavigationStack {
                VisitDetailView(viewModel: item.viewModel)
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button {
                    isSettingsPresented = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(.leading, 16)
                .padding(.bottom, 8)
                .accessibilityIdentifier(TJAccessibility.Identifier.homeSettingsButton)
                .accessibilityLabel(TJAccessibility.Label.homeSettingsButton)

                Button {
                    do {
                        tripsListViewModel = try viewModel.makeTripsListViewModel()
                        isTripsPresented = true
                    } catch {
                        viewModel.handleTripsUnavailable()
                    }
                } label: {
                    Image(systemName: "suitcase.rolling")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)
                .accessibilityIdentifier(TJAccessibility.Identifier.homeTripsButton)
                .accessibilityLabel(TJAccessibility.Label.homeTripsButton)

                Spacer()

                Button {
                    addVisitViewModel = viewModel.makeAddVisitFlowViewModel()
                    isAddVisitPresented = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(16)
                        .background(Color.blue.opacity(0.9))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(.trailing, 16)
                .padding(.bottom, 8)
                .accessibilityIdentifier(TJAccessibility.Identifier.homeAddVisitButton)
                .accessibilityLabel(TJAccessibility.Label.homeAddVisitButton)
            }
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

    private var pinsListButton: some View {
        HStack {
            Spacer()
            Button {
                isPinsListPresented = true
            } label: {
                Label("Pins List", systemImage: "list.bullet")
                    .font(.footnote.weight(.semibold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.16))
            .clipShape(Capsule())
            .accessibilityIdentifier(TJAccessibility.Identifier.homePinsListButton)
            .accessibilityLabel(TJAccessibility.Label.homePinsListButton)
        }
    }

    private var searchResultsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(viewModel.searchResults, id: \.id) { result in
                Button {
                    viewModel.handleSearchResultSelected(result)
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: iconName(for: result.kind))
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(result.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            if let subtitle = result.subtitle, subtitle.isEmpty == false {
                                Text(subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(TJAccessibility.Identifier.homeSearchResultRowPrefix + result.id)
                .accessibilityLabel(result.subtitle.map { "\(result.title), \($0)" } ?? result.title)

                if result.id != viewModel.searchResults.last?.id {
                    Divider()
                }
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func iconName(for kind: SearchResultKind) -> String {
        switch kind {
        case .place:
            return "mappin.and.ellipse"
        case .trip:
            return "suitcase"
        case .visit:
            return "calendar"
        case .spot:
            return "fork.knife"
        case .tag:
            return "tag"
        }
    }

    private var selectedPlaceStoryItem: PlaceStorySheetItem? {
        guard let viewModel = viewModel.selectedPlaceStoryViewModel,
              let selectedID = self.viewModel.selectedPlaceID
        else {
            return nil
        }
        return PlaceStorySheetItem(id: selectedID, viewModel: viewModel)
    }


    private var deepLinkedVisitDetailSheetItem: VisitDetailSheetItem? {
        guard let deepLinkedVisitDetailViewModel else { return nil }
        return VisitDetailSheetItem(viewModel: deepLinkedVisitDetailViewModel)
    }

    private var filtersRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(HomeViewModel.FilterChip.allCases) { filter in
                    Button {
                        viewModel.toggleFilter(filter)
                    } label: {
                        Text(viewModel.chipTitle(for: filter))
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


private struct VisitDetailSheetItem: Identifiable {
    let id = UUID()
    let viewModel: VisitDetailViewModel
}
