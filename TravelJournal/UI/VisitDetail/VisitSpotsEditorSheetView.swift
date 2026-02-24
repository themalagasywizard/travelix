import SwiftUI
import TravelJournalCore

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
                Section(TJStrings.SpotsEditor.addSpotSection) {
                    TextField(TJStrings.SpotsEditor.nameField, text: $draftName)
                    TextField(TJStrings.SpotsEditor.categoryField, text: $draftCategory)
                    TextField(TJStrings.SpotsEditor.noteField, text: $draftNote, axis: .vertical)
                        .lineLimit(2...4)

                    Button(TJStrings.SpotsEditor.addSpotButton) {
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

                Section(TJStrings.SpotsEditor.savedSpotsSection) {
                    if viewModel.spots.isEmpty {
                        Text(TJStrings.SpotsEditor.noSpotsYet)
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
                    Section(TJStrings.SpotsEditor.errorSection) {
                        Text(banner.title)
                            .font(.headline)
                        Text(banner.message)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle(TJStrings.SpotsEditor.title)
            .onAppear { viewModel.loadSpots() }
        }
    }
}
