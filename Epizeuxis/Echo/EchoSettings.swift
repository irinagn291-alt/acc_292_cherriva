import SwiftUI

/// Courtauld credit, Undo, contact, onboarding, reset.
struct EchoSettings: View {
    @Environment(EchoStore.self) private var store
    @Environment(EchoRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: EchoSpace.item) {
                    settingsGroup(title: "The Courtauld") {
                        credit("The Courtauld", url: EchoCredit.courtauldHome)
                        Divider().padding(.leading, EchoSpace.item)
                        credit("Collection", url: EchoCredit.courtauldCollection)
                        Divider().padding(.leading, EchoSpace.item)
                        credit("Wikidata Q1138087", url: EchoCredit.wikidataGallery)
                    }
                    settingsGroup(title: "Marks") {
                        Button("Undo newest mark") {
                            _ = store.undoNewestMark()
                        }
                        .buttonStyle(SettingsRowStyle())
                        .disabled(store.document.marksInOrder.isEmpty)
                        if store.document.marksInOrder.isEmpty {
                            Text("No filed tap or miss to peel.")
                                .font(EchoType.caption)
                                .foregroundStyle(EchoColor.muted)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                .padding(.horizontal, EchoSpace.item)
                        }
                    }
                    settingsGroup(title: "Help") {
                        if let url = EchoCredit.contact {
                            Link(destination: url) {
                                settingsRowLabel("Contact us")
                            }
                        }
                        Divider().padding(.leading, EchoSpace.item)
                        Button {
                            router.sheet = .twist
                        } label: {
                            settingsRowLabel("How the twin works")
                        }
                        .buttonStyle(ChromePressStyle())
                        Divider().padding(.leading, EchoSpace.item)
                        Button {
                            router.sheet = nil
                            router.showsOnboarding = true
                        } label: {
                            settingsRowLabel("Show the first pages")
                        }
                        .buttonStyle(ChromePressStyle())
                    }
                    VStack(alignment: .leading, spacing: EchoSpace.small) {
                        Button("Reset all data", role: .destructive) {
                            confirmReset = true
                        }
                        .buttonStyle(ElidePillStyle(isEnabled: true, isLoading: false, isDestructive: true))
                        Text("Clears saved paintings, the live caption, and every mark on this device.")
                            .font(EchoType.caption)
                            .foregroundStyle(EchoColor.muted)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(EchoSpace.item)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(EchoColor.surface, in: RoundedRectangle(cornerRadius: EchoRadius.card, style: .continuous))
                }
                .padding(.horizontal, EchoSpace.item)
                .padding(.top, EchoSpace.small)
                .padding(.bottom, EchoSpace.block)
            }
            .background(EchoColor.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                        .accessibilityLabel("Close Settings")
                }
            }
            .confirmationDialog(
                "Reset all data",
                isPresented: $confirmReset,
                titleVisibility: .visible
            ) {
                Button("Reset all data", role: .destructive) {
                    store.resetAllData()
                }
                Button("Keep my crate", role: .cancel) {}
            } message: {
                Text("Paintings, marks, and the live quiz leave this device. This cannot be undone.")
            }
        }
        .modifier(SheetAppear())
        .modifier(SettingsPageSheet())
    }

    private func settingsGroup(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: EchoSpace.small) {
            Text(title)
                .font(EchoType.caption)
                .foregroundStyle(EchoColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .leading, spacing: 0) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(EchoColor.surface, in: RoundedRectangle(cornerRadius: EchoRadius.card, style: .continuous))
        }
    }

    @ViewBuilder
    private func credit(_ title: String, url: URL?) -> some View {
        if let url {
            Link(destination: url) {
                settingsRowLabel(title)
            }
        }
    }

    private func settingsRowLabel(_ title: String) -> some View {
        Text(title)
            .font(EchoType.body)
            .foregroundStyle(Color.blue)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .padding(.horizontal, EchoSpace.item)
            .contentShape(Rectangle())
    }
}

/// iPad form sheets were clipping the reset card. A page sheet keeps the sentence on screen.
private struct SettingsPageSheet: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content
                .presentationSizing(.page)
                .presentationDetents([.large])
        } else {
            content
        }
    }
}

private struct SettingsRowStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(EchoType.body)
            .foregroundStyle(Color.blue)
            .lineLimit(2)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .padding(.horizontal, EchoSpace.item)
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
