import SwiftUI

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
                    Text("Load Demo Data")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isSeeding)

            if let cacheSummary = viewModel.cacheSummary {
                Text(cacheSummary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button("Clear Thumbnail Cache") {
                    viewModel.clearThumbnailCache()
                }
                .buttonStyle(.bordered)
            }

            if let status = viewModel.statusMessage {
                Text(status)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
