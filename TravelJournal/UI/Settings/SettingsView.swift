import SwiftUI

public struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel

    public init(viewModel: @autoclosure @escaping () -> SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Sync") {
                    Toggle("Enable iCloud Sync", isOn: syncBinding)
                    Text("Off by default. When enabled, Travel Journal will sync records using your private iCloud database.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var syncBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isSyncEnabled },
            set: { viewModel.setSyncEnabled($0) }
        )
    }
}
