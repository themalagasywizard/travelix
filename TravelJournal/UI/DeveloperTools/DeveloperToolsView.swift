import SwiftUI
import TravelJournalCore

public struct DeveloperToolsView: View {
    @StateObject private var viewModel: DeveloperToolsViewModel

    public init(viewModel: @autoclosure @escaping () -> DeveloperToolsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: viewModel.loadDemoData) {
                if viewModel.isSeeding {
                    ProgressView()
                } else {
                    Text(TJStrings.DeveloperTools.loadDemoData)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isSeeding)

            if let cacheSummary = viewModel.cacheSummary {
                Text(cacheSummary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button(TJStrings.DeveloperTools.clearThumbnailCache) {
                    viewModel.clearThumbnailCache()
                }
                .buttonStyle(.bordered)
            }

            if let banner = viewModel.errorBanner {
                VStack(alignment: .leading, spacing: 2) {
                    Text(banner.title)
                        .font(.footnote.weight(.semibold))
                    Text(banner.message)
                        .font(.footnote)
                }
                .foregroundStyle(.orange)
            }

            if let status = viewModel.statusMessage {
                Text(status)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
