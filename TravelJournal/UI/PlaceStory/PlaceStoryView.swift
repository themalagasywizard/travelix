import SwiftUI

public struct PlaceStoryView: View {
    @StateObject private var viewModel: PlaceStoryViewModel

    public init(viewModel: @autoclosure @escaping () -> PlaceStoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                miniPreviewCard
                visitsSection
            }
            .padding(16)
        }
        .background(Color.black.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.placeName)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)

            Text(viewModel.countryName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(viewModel.visitCountText)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var miniPreviewCard: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                HStack(spacing: 8) {
                    Image(systemName: "globe.europe.africa.fill")
                    Text("Mini globe preview")
                        .font(.footnote.weight(.medium))
                }
                .foregroundStyle(.white.opacity(0.9))
            )
            .frame(height: 90)
    }

    private var visitsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Visits")
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(viewModel.visits) { visit in
                VStack(alignment: .leading, spacing: 4) {
                    Text(visit.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)

                    Text(visit.dateRangeText)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let summary = visit.summary, !summary.isEmpty {
                        Text(summary)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}
