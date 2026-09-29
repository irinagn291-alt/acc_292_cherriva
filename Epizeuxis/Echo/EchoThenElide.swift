import SwiftUI

/// Twist screen: echo-then-elide, plus the doubled line on Quiz.
struct EchoThenElide: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: EchoSpace.item) {
                    EchoCutout(name: "epz_TwistHero")
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                    Text("Tap the twin")
                        .font(EchoType.display)
                        .foregroundStyle(EchoColor.ink)
                        .lineLimit(2)
                    Text("A saved painting that is not yet fair gets one word written twice. Maker or title, never both.")
                        .font(EchoType.body)
                        .foregroundStyle(EchoColor.ink)
                    Text("Tap either matching neighbor to file it fair. A miss cools that word and keeps the doubled caption.")
                        .font(EchoType.body)
                        .foregroundStyle(EchoColor.muted)
                    Image("epz_TwinToken")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 140)
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                    Image("epz_EchoedLine")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                }
                .padding(EchoSpace.section)
            }
            .background(EchoColor.background)
            .navigationTitle("The twin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                        .accessibilityLabel("Close the twin")
                }
            }
        }
        .modifier(SheetAppear())
    }
}
