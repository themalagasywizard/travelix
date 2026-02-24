import SwiftUI

struct VisitSpotsEditorSheetView: View {
    @StateObject private var viewModel: VisitSpotsEditorViewModel
    @State private var draftName = ""
    @State private var draftCategory = ""
    @State private var draftNote = ""

    init(viewModel: @autoclosure @escaping () -> VisitSpotsEditorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Add spot") {
                    TextField("Name", text: $draftName)
                    TextField("Category", text: $draftCategory)
                    TextField("Note", text: $draftNote, axis: .vertical)
                        .lineLimit(2...4)

                    Button("Add Spot") {
                        viewModel.addSpot(
                            name: draftName.trimmingCharacters(in: .whitespacesAndNewlines),
                            category: draftCategory.trimmingCharacters(in: .whitespacesAndNewlines),
                            note: draftNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : draftNote.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        draftName = ""
                        draftCategory = ""
                        draftNote = ""
                    }
                    .disabled(draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                Section("Saved spots") {
                    if viewModel.spots.isEmpty {
                        Text("No spots yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.spots) { spot in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(spot.name)
                                Text(spot.category)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                if let note = spot.note {
                                    Text(note)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                viewModel.deleteSpot(id: viewModel.spots[index].id)
                            }
                        }
                    }
                }

                if let banner = viewModel.errorBanner {
                    Section("Error") {
                        Text(banner.title)
                            .font(.headline)
                        Text(banner.message)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Manage Spots")
            .onAppear { viewModel.loadSpots() }
        }
    }
}
