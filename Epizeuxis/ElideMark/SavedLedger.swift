import SwiftUI

/// Fair works and reviewable BotchMarks. Counts both mark kinds.
struct SavedLedger: View {
    @Environment(EchoStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if store.document.fairWorks.isEmpty && store.botchMarks.isEmpty {
                    EchoEmptyPage(
                        headline: "Nothing filed yet.",
                        line: "Elide a twin to file a work as fair.",
                        actionTitle: "Back to the line",
                        art: EchoCutout(name: "epz_EmptyList")
                    ) {
                        dismiss()
                    }
                } else {
                    list
                }
            }
            .background(EchoColor.background)
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                        .accessibilityLabel("Close Saved")
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Undo") { _ = store.undoNewestMark() }
                        .disabled(store.document.marksInOrder.isEmpty)
                }
            }
        }
        .modifier(SheetAppear())
    }

    private var list: some View {
        List {
            Section {
                HStack {
                    labeledCount(store.elideMarks.count, title: "Elides")
                    labeledCount(store.botchMarks.count, title: "Botches")
                }
                .listRowBackground(EchoColor.surface)
            }
            if !store.document.fairWorks.isEmpty {
                Section("Fair") {
                    ForEach(store.document.fairWorks) { work in
                        VStack(alignment: .leading, spacing: EchoSpace.tight) {
                            Text(work.title)
                                .font(EchoType.headline)
                                .foregroundStyle(EchoColor.ink)
                                .lineLimit(2)
                            Text(work.maker)
                                .font(EchoType.caption)
                                .foregroundStyle(EchoColor.muted)
                                .lineLimit(1)
                            Text(EchoFigure.daykeyText(work.daykey))
                                .font(EchoType.micro)
                                .foregroundStyle(EchoColor.muted)
                                .monospacedDigit()
                        }
                        .listRowBackground(EchoColor.surface)
                    }
                }
            }
            if !store.botchMarks.isEmpty {
                Section("Botches") {
                    ForEach(store.botchMarks) { mark in
                        VStack(alignment: .leading, spacing: EchoSpace.tight) {
                            Text(mark.tokenText)
                                .font(EchoType.headline)
                                .foregroundStyle(EchoColor.ink)
                            Text(workTitle(mark.workID))
                                .font(EchoType.caption)
                                .foregroundStyle(EchoColor.muted)
                                .lineLimit(1)
                            Text(EchoFigure.daykeyText(mark.daykey))
                                .font(EchoType.micro)
                                .foregroundStyle(EchoColor.muted)
                                .monospacedDigit()
                        }
                        .listRowBackground(EchoColor.surface)
                    }
                }
            }
            if store.document.fairWorks.isEmpty && !store.botchMarks.isEmpty {
                Section {
                    Text("Fair works land here after a true elide.")
                        .font(EchoType.body)
                        .foregroundStyle(EchoColor.muted)
                        .listRowBackground(EchoColor.surface)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .contentMargins(.bottom, EchoSpace.section)
        .background(EchoColor.background)
    }

    private func labeledCount(_ value: Int, title: String) -> some View {
        VStack(alignment: .leading, spacing: EchoSpace.tight) {
            Text(EchoFigure.countText(value))
                .font(EchoType.title)
                .foregroundStyle(EchoColor.ink)
                .monospacedDigit()
            Text(title)
                .font(EchoType.micro)
                .foregroundStyle(EchoColor.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func workTitle(_ identity: String) -> String {
        store.works.first { $0.identity == identity }?.title ?? identity
    }
}
