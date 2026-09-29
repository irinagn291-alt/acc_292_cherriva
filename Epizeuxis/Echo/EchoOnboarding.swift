import SwiftUI

/// One-shot cover. Continue or Next sits full width at the bottom.
struct EchoOnboarding: View {
    let onFinish: () -> Void
    @State private var page = 0
    @Environment(\.dynamicTypeSize) private var dynamicType

    private let pages: [(art: String, title: String, line: String)] = [
        ("epz_Onboarding1", "Save a painting", "Keep Courtauld works on this device, then sit the quiz."),
        ("epz_Onboarding2", "Find the twin", "Echo writes one word twice. Tap either neighbor to elide."),
        ("epz_Onboarding3", "File it fair", "A true elide files the work. Botches stay reviewable on Saved.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: EchoSpace.item) {
            VStack(alignment: .leading, spacing: EchoSpace.item) {
                EchoCutout(name: pages[page].art)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 280)
                Text(pages[page].title)
                    .font(EchoType.display(for: dynamicType))
                    .foregroundStyle(EchoColor.ink)
                    .lineLimit(2)
                Text(pages[page].line)
                    .font(EchoType.body)
                    .foregroundStyle(EchoColor.muted)
                Spacer(minLength: EchoSpace.small)
            }
            .padding(.horizontal, EchoSpace.section)

            HStack(spacing: EchoSpace.tight) {
                ForEach(pages.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == page ? EchoColor.accent : EchoColor.muted.opacity(0.3))
                        .frame(width: index == page ? EchoSpace.section : EchoSpace.small, height: EchoSpace.small)
                }
            }
            .padding(.horizontal, EchoSpace.section)

            Button(page == pages.count - 1 ? "Continue" : "Next") {
                if page == pages.count - 1 {
                    onFinish()
                } else {
                    page += 1
                }
            }
            .buttonStyle(ElidePillStyle(isEnabled: true, isLoading: false))
            .padding(.horizontal, EchoSpace.section)
            .padding(.bottom, EchoSpace.item)

            Button("Skip") { onFinish() }
                .font(EchoType.caption)
                .foregroundStyle(EchoColor.muted)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(EchoColor.background.ignoresSafeArea())
    }
}
