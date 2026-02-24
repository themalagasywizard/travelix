import SwiftUI

public struct EditVisitView: View {
    @StateObject private var viewModel: EditVisitViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: @autoclosure @escaping () -> EditVisitViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Location") {
                    TextField("Location", text: $viewModel.locationName)
                        .textInputAutocapitalization(.words)
                }

                Section("Dates") {
                    DatePicker("Start", selection: $viewModel.startDate, displayedComponents: .date)
                    DatePicker("End", selection: $viewModel.endDate, displayedComponents: .date)

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

                Section("Summary") {
                    TextField("One-line summary", text: $viewModel.summary)
                }

                Section("Notes") {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("Edit Visit")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: { dismiss() })
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
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
