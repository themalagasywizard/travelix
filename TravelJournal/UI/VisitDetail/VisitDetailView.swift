import SwiftUI
import TravelJournalCore

public struct VisitDetailView: View {
    @StateObject private var viewModel: VisitDetailViewModel

    public init(viewModel: @autoclosure @escaping () -> VisitDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                summarySection
                photosSection
                notesSection
                spotsSection
                recommendationsSection
            }
            .padding(16)
        }
        .background(Color.black.ignoresSafeArea())
        .sheet(isPresented: $viewModel.isSpotsEditorPresented, onDismiss: viewModel.refreshSpotsFromEditor) {
            if let spotsEditorViewModel = viewModel.spotsEditorViewModel {
                VisitSpotsEditorSheetView(viewModel: spotsEditorViewModel)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            Text(viewModel.dateRangeText)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .accessibilityIdentifier(TJAccessibility.Identifier.visitHeader)
    }

    private var summarySection: some View {
        sectionCard(title: "Summary") {
            Text(viewModel.summary ?? "No summary yet")
                .font(.body)
                .foregroundStyle(.white.opacity(0.92))
        }
        .accessibilityIdentifier(TJAccessibility.Identifier.visitSummarySection)
        .accessibilityLabel(TJAccessibility.Label.visitSummaryTitle)
    }

    private var photosSection: some View {
        sectionCard(title: viewModel.photoSectionTitle) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(0..<max(viewModel.photoCount, 3), id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
        .accessibilityIdentifier(TJAccessibility.Identifier.visitPhotosSection)
        .accessibilityLabel(TJAccessibility.Label.visitPhotosTitle)
    }

    private var notesSection: some View {
        sectionCard(title: "Notes") {
            Text(viewModel.notes ?? "No notes yet")
                .font(.body)
                .foregroundStyle(.white.opacity(0.9))
        }
        .accessibilityIdentifier(TJAccessibility.Identifier.visitNotesSection)
        .accessibilityLabel(TJAccessibility.Label.visitNotesTitle)
    }

    private var spotsSection: some View {
        sectionCard(title: "Spots") {
            VStack(alignment: .leading, spacing: 10) {
                if viewModel.spots.isEmpty {
                    Text("No spots added")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.spots) { spot in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(spot.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)

                            Text(spot.category)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if let rating = spot.ratingText {
                                Text(rating)
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.85))
                            }

                            if let note = spot.note {
                                Text(note)
                                    .font(.footnote)
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                        }
                    }
                }

                if viewModel.canManageSpots {
                    Button("Manage Spots") {
                        viewModel.presentSpotsEditor()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.white.opacity(0.2))
                }
            }
        }
        .accessibilityIdentifier(TJAccessibility.Identifier.visitSpotsSection)
        .accessibilityLabel(TJAccessibility.Label.visitSpotsTitle)
    }

    private var recommendationsSection: some View {
        sectionCard(title: "Recommendations") {
            VStack(alignment: .leading, spacing: 6) {
                if viewModel.recommendations.isEmpty {
                    Text("No recommendations yet")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.recommendations, id: \.self) { item in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 5, height: 5)
                                .padding(.top, 6)

                            Text(item)
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.92))
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier(TJAccessibility.Identifier.visitRecommendationsSection)
        .accessibilityLabel(TJAccessibility.Label.visitRecommendationsTitle)
    }

    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            content()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
