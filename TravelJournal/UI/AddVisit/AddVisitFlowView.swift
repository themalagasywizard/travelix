import SwiftUI
import TravelJournalCore
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
            Text(TJStrings.AddVisit.title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            Text(TJStrings.AddVisit.stepCounter(stepIndex: viewModel.currentStep.rawValue + 1, total: 3, title: viewModel.currentStep.title))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .location:
            VStack(alignment: .leading, spacing: 10) {
                Text(TJStrings.AddVisit.wherePrompt)
                    .foregroundStyle(.white)
                TextField(
                    TJStrings.AddVisit.locationPlaceholder,
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

                Button {
                    Task {
                        await viewModel.useCurrentLocation()
                    }
                } label: {
                    Label(TJStrings.AddVisit.useCurrentLocation, systemImage: "location.fill")
                        .font(.callout.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isResolvingCurrentLocation)

                if viewModel.isResolvingCurrentLocation {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                }
            }

        case .dates:
            VStack(alignment: .leading, spacing: 10) {
                DatePicker(
                    TJStrings.AddVisit.startDate,
                    selection: Binding(
                        get: { viewModel.draft.startDate },
                        set: { viewModel.updateDates(start: $0, end: viewModel.draft.endDate) }
                    ),
                    displayedComponents: .date
                )
                DatePicker(
                    TJStrings.AddVisit.endDate,
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
                Text(TJStrings.AddVisit.quickNotes)
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
                    Label(TJStrings.AddVisit.selectPhotos, systemImage: "photo.on.rectangle")
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

                Text(TJStrings.AddVisit.photosSelectedCount(viewModel.draft.photoItemCount))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Button(TJStrings.AddVisit.back, action: viewModel.goBack)
                .buttonStyle(.bordered)
                .disabled(!viewModel.canGoBack)

            Spacer()

            Button(viewModel.isLastStep ? TJStrings.AddVisit.save : TJStrings.AddVisit.next) {
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
