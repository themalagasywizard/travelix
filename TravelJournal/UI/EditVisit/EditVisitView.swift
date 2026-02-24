import SwiftUI
import TravelJournalCore

public struct EditVisitView: View {
    @StateObject private var viewModel: EditVisitViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: @autoclosure @escaping () -> EditVisitViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section(TJStrings.EditVisit.locationSection) {
                    TextField(TJStrings.EditVisit.locationField, text: $viewModel.locationName)
                        .textInputAutocapitalization(.words)
                }

                Section(TJStrings.EditVisit.datesSection) {
                    DatePicker(TJStrings.EditVisit.startDate, selection: $viewModel.startDate, displayedComponents: .date)
                    DatePicker(TJStrings.EditVisit.endDate, selection: $viewModel.endDate, displayedComponents: .date)

                    if let banner = viewModel.dateValidationBanner ?? viewModel.saveErrorBanner {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(banner.title)
                                .font(.footnote.weight(.semibold))
                            Text(banner.message)
                                .font(.footnote)
                        }
                        .foregroundStyle(.red)
                    }
                }

                Section(TJStrings.EditVisit.summarySection) {
                    TextField(TJStrings.EditVisit.oneLineSummary, text: $viewModel.summary)
                }

                Section(TJStrings.EditVisit.notesSection) {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle(TJStrings.EditVisit.title)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(TJStrings.EditVisit.cancel, action: { dismiss() })
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(TJStrings.EditVisit.save) {
                        if viewModel.saveChanges() {
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.hasValidDateRange)
                }
            }
        }
    }
}
