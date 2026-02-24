import SwiftUI
import TravelJournalCore

public struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    #if DEBUG
    @StateObject private var developerToolsViewModel: DeveloperToolsViewModel
    #endif

    public init(
        viewModel: @autoclosure @escaping () -> SettingsViewModel
        #if DEBUG
        , developerToolsViewModel: @autoclosure @escaping () -> DeveloperToolsViewModel
        #endif
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        #if DEBUG
        _developerToolsViewModel = StateObject(wrappedValue: developerToolsViewModel())
        #endif
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section(TJStrings.Settings.syncSectionTitle) {
                    Toggle(TJStrings.Settings.enableICloudSync, isOn: syncBinding)
                        .accessibilityIdentifier(TJAccessibility.Identifier.settingsSyncToggle)
                        .accessibilityLabel(TJAccessibility.Label.settingsSyncToggle)
                    Text(TJStrings.Settings.syncDescription)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier(TJAccessibility.Identifier.settingsSyncDescription)
                        .accessibilityLabel(TJAccessibility.Label.settingsSyncDescription)

                    if viewModel.canRunSyncNow {
                        Button(action: { Task { await viewModel.runSyncNow() } }) {
                            if viewModel.isRunningSyncNow {
                                ProgressView()
                            } else {
                                Text(TJStrings.Settings.syncNow)
                            }
                        }
                        .disabled(viewModel.isRunningSyncNow)
                        .accessibilityIdentifier(TJAccessibility.Identifier.settingsSyncNowButton)
                        .accessibilityLabel(TJAccessibility.Label.settingsSyncNowButton)

                        if let banner = viewModel.syncErrorBanner {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(banner.title)
                                    .font(.footnote.weight(.semibold))
                                Text(banner.message)
                                    .font(.footnote)
                            }
                            .foregroundStyle(.orange)
                        }

                        if let syncStatusMessage = viewModel.syncStatusMessage {
                            Text(syncStatusMessage)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .accessibilityIdentifier(TJAccessibility.Identifier.settingsSyncNowStatus)
                                .accessibilityLabel(TJAccessibility.Label.settingsSyncNowStatus)
                        }

                        if let lastSuccessfulSyncDescription = viewModel.lastSuccessfulSyncDescription {
                            Text(lastSuccessfulSyncDescription)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                #if DEBUG
                Section(TJStrings.Settings.developerSectionTitle) {
                    DeveloperToolsView(viewModel: developerToolsViewModel)
                }
                #endif
            }
            .navigationTitle(TJStrings.Settings.title)
        }
    }

    private var syncBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isSyncEnabled },
            set: { viewModel.setSyncEnabled($0) }
        )
    }
}
