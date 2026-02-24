import SwiftUI
import TravelJournalCore

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
                        .accessibilityIdentifier(TJAccessibility.Identifier.settingsSyncToggle)
                        .accessibilityLabel(TJAccessibility.Label.settingsSyncToggle)
                    Text("Off by default. When enabled, Travel Journal will sync records using your private iCloud database.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier(TJAccessibility.Identifier.settingsSyncDescription)
                        .accessibilityLabel(TJAccessibility.Label.settingsSyncDescription)

                    if viewModel.canRunSyncNow {
                        Button(action: { Task { await viewModel.runSyncNow() } }) {
                            if viewModel.isRunningSyncNow {
                                ProgressView()
                            } else {
                                Text("Sync Now")
                            }
                        }
                        .disabled(viewModel.isRunningSyncNow)
                        .accessibilityIdentifier(TJAccessibility.Identifier.settingsSyncNowButton)
                        .accessibilityLabel(TJAccessibility.Label.settingsSyncNowButton)

                        if let syncStatusMessage = viewModel.syncStatusMessage {
                            Text(syncStatusMessage)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .accessibilityIdentifier(TJAccessibility.Identifier.settingsSyncNowStatus)
                                .accessibilityLabel(TJAccessibility.Label.settingsSyncNowStatus)
                        }
                    }
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
