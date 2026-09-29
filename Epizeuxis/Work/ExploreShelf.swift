import SwiftUI

/// Courtauld search sheet. Empty query never hits the network.
struct ExploreShelf: View {
    @Environment(EchoStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var rows: [Work] = []
    @State private var isLoading = false
    @State private var errorText: String?
    @State private var focusedID: String?
    @State private var searchTask: Task<Void, Never>?
    @State private var client = CatalogClient()

    var body: some View {
        NavigationStack {
            Group {
                if rows.isEmpty && errorText == nil && !isLoading && query.isEmpty && store.catalogFallback().isEmpty {
                    EchoEmptyPage(
                        headline: "The crate is open.",
                        line: "Search The Courtauld, then save a work.",
                        actionTitle: "Show shelf",
                        art: EchoCutout(name: "epz_EmptyList")
                    ) {
                        rows = store.catalogFallback()
                    }
                } else {
                    list
                }
            }
            .background(EchoColor.background)
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                        .accessibilityLabel("Close Explore")
                }
            }
            .searchable(text: $query, prompt: "Maker or title")
            .onChange(of: query) { _, next in
                scheduleSearch(next)
            }
            .onAppear {
                if rows.isEmpty {
                    rows = store.catalogFallback()
                    focusedID = store.document.focusedWorkID
                }
            }
            .onDisappear {
                searchTask?.cancel()
                Task { await client.cancelSearch() }
            }
        }
        .modifier(SheetAppear())
    }

    private var list: some View {
        List {
            if let errorText {
                Section {
                    VStack(alignment: .leading, spacing: EchoSpace.small) {
                        Text(errorText)
                            .font(EchoType.body)
                            .foregroundStyle(EchoColor.ink)
                        Button("Try again") { scheduleSearch(query) }
                            .buttonStyle(ElidePillStyle(isEnabled: true, isLoading: isLoading))
                    }
                    .listRowBackground(EchoColor.surface)
                }
            }
            Section {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowBackground(EchoColor.background)
                }
                ForEach(rows) { work in
                    Button {
                        let outcome = store.saveExplored(work)
                        if outcome == .focusedExisting {
                            focusedID = work.identity
                        } else {
                            focusedID = work.identity
                        }
                    } label: {
                        HStack(spacing: EchoSpace.item) {
                            thumb(work)
                            VStack(alignment: .leading, spacing: EchoSpace.tight) {
                                Text(work.title)
                                    .font(EchoType.headline)
                                    .foregroundStyle(EchoColor.ink)
                                    .lineLimit(2)
                                Text(work.maker)
                                    .font(EchoType.caption)
                                    .foregroundStyle(EchoColor.muted)
                                    .lineLimit(1)
                            }
                            Spacer()
                            if focusedID == work.identity || store.works.contains(where: { $0.objectID == work.objectID }) {
                                Text("Saved")
                                    .font(EchoType.micro)
                                    .foregroundStyle(EchoColor.muted)
                            }
                        }
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    .listRowBackground(EchoColor.surface)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .contentMargins(.bottom, EchoSpace.section)
        .background(EchoColor.background)
    }

    private func thumb(_ work: Work) -> some View {
        WorkPainting(urlString: work.thumbURL)
            .frame(width: 64, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: EchoRadius.small, style: .continuous))
    }

    private func scheduleSearch(_ raw: String) {
        searchTask?.cancel()
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        errorText = nil
        if trimmed.isEmpty {
            isLoading = false
            rows = store.catalogFallback()
            return
        }
        searchTask = Task {
            let spinner = Task {
                try await Task.sleep(nanoseconds: 150_000_000)
                if !Task.isCancelled {
                    isLoading = true
                }
            }
            do {
                let found = try await client.searchDebounced(query: trimmed)
                spinner.cancel()
                if Task.isCancelled { return }
                store.rememberCatalog(found)
                rows = found.isEmpty ? store.catalogFallback() : found
                if found.isEmpty {
                    errorText = "No Courtauld match. The local shelf stays."
                }
                isLoading = false
            } catch is CancellationError {
                spinner.cancel()
                return
            } catch {
                spinner.cancel()
                if Task.isCancelled { return }
                rows = store.catalogFallback()
                errorText = "Search missed the catalog. The shelf is still here."
                isLoading = false
            }
        }
    }
}
