import SwiftUI
import TravelJournalData

#if canImport(PhotosUI)
import PhotosUI
#endif

public struct AddVisitFlowView: View {
    @StateObject private var viewModel: AddVisitFlowViewModel
    private let onSaved: ((AddVisitSaveResult) -> Void)?

    #if canImport(PhotosUI)
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    #endif

    public init(
        viewModel: @autoclosure @escaping () -> AddVisitFlowViewModel = AddVisitFlowViewModel(),
        onSaved: ((AddVisitSaveResult) -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onSaved = onSaved
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            stepContent
            footer
        }
        .padding(16)
        .background(Color.black.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Add Visit")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            Text("Step \(viewModel.currentStep.rawValue + 1)/3 · \(viewModel.currentStep.title)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .location:
            VStack(alignment: .leading, spacing: 10) {
                Text("Where did you go?")
                    .foregroundStyle(.white)
                TextField(
                    "Search city or place",
                    text: Binding(
                        get: { viewModel.draft.locationQuery },
                        set: viewModel.updateLocationQuery
                    )
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(10)
                .background(Color.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

        case .dates:
            VStack(alignment: .leading, spacing: 10) {
                DatePicker(
                    "Start date",
                    selection: Binding(
                        get: { viewModel.draft.startDate },
                        set: { viewModel.updateDates(start: $0, end: viewModel.draft.endDate) }
                    ),
                    displayedComponents: .date
                )
                DatePicker(
                    "End date",
                    selection: Binding(
                        get: { viewModel.draft.endDate },
                        set: { viewModel.updateDates(start: viewModel.draft.startDate, end: $0) }
                    ),
                    displayedComponents: .date
                )
            }
            .foregroundStyle(.white)

        case .content:
            VStack(alignment: .leading, spacing: 10) {
                Text("Quick notes")
                    .foregroundStyle(.white)

                TextEditor(
                    text: Binding(
                        get: { viewModel.draft.note },
                        set: { viewModel.updateContent(note: $0, photoItemCount: viewModel.draft.photoItemCount) }
                    )
                )
                .frame(minHeight: 120)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(Color.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                #if canImport(PhotosUI)
                PhotosPicker(
                    selection: $selectedPhotoItems,
                    maxSelectionCount: 100,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Select photos", systemImage: "photo.on.rectangle")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.14))
                        .clipShape(Capsule())
                }
                .onChange(of: selectedPhotoItems) { _, newItems in
                    let payloads = newItems.map { item in
                        MediaImportPayload(
                            localIdentifier: item.itemIdentifier,
                            fileURL: nil,
                            width: nil,
                            height: nil
                        )
                    }
                    viewModel.updateSelectedMediaPayloads(payloads)
                }
                #endif

                Text("Photos selected: \(viewModel.draft.photoItemCount)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Button("Back", action: viewModel.goBack)
                .buttonStyle(.bordered)
                .disabled(!viewModel.canGoBack)

            Spacer()

            Button(viewModel.isLastStep ? "Save" : "Next") {
                if viewModel.isLastStep {
                    if let result = viewModel.saveVisit() {
                        onSaved?(result)
                    }
                } else {
                    viewModel.goNext()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .overlay(alignment: .bottomLeading) {
            if let banner = viewModel.errorBanner {
                VStack(alignment: .leading, spacing: 2) {
                    Text(banner.title)
                        .font(.footnote.weight(.semibold))
                    Text(banner.message)
                        .font(.footnote)
                }
                .foregroundStyle(.red)
                .padding(.top, 8)
            }
        }
    }
}
