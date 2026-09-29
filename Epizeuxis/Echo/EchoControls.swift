import SwiftUI

/// Full-width Elide pill. Undo is not this style. Reset uses the destructive variant.
struct ElidePillStyle: ButtonStyle {
    var isEnabled: Bool
    var isLoading: Bool
    var isDestructive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        ElidePillBody(
            configuration: configuration,
            isEnabled: isEnabled,
            isLoading: isLoading,
            isDestructive: isDestructive
        )
    }
}

private struct ElidePillBody: View {
    let configuration: ButtonStyleConfiguration
    var isEnabled: Bool
    var isLoading: Bool
    var isDestructive: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicType

    var body: some View {
        let pressed = configuration.isPressed && isEnabled
        ZStack {
            configuration.label
                .opacity(isLoading ? 0 : 1)
            if isLoading {
                ProgressView()
                    .tint(EchoColor.surface)
            }
        }
        .font(EchoType.elide(for: dynamicType))
        .foregroundStyle(isEnabled ? EchoColor.surface : EchoColor.muted)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 52)
        .background(fill, in: Capsule())
        .contentShape(Capsule())
        .scaleEffect(pressed && !reduceMotion ? 0.97 : 1)
        .opacity(pressed && reduceMotion ? 0.72 : (isEnabled ? 1 : 0.55))
        .animation(EchoMotion.pressAnimation(reduceMotion: reduceMotion), value: pressed)
    }

    private var fill: Color {
        if isDestructive { return EchoColor.ink }
        return isEnabled ? EchoColor.accent : EchoColor.muted.opacity(0.35)
    }
}

/// Token on the doubled caption. Colour is never the only miss signal.
struct TokenChipStyle: ButtonStyle {
    var isSelected: Bool
    var isCooled: Bool
    var isEnabled: Bool
    var isError: Bool

    func makeBody(configuration: Configuration) -> some View {
        TokenChipBody(
            configuration: configuration,
            isSelected: isSelected,
            isCooled: isCooled,
            isEnabled: isEnabled,
            isError: isError
        )
    }
}

private struct TokenChipBody: View {
    let configuration: ButtonStyleConfiguration
    var isSelected: Bool
    var isCooled: Bool
    var isEnabled: Bool
    var isError: Bool
    @Environment(\.isFocused) private var isFocused
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let pressed = configuration.isPressed && isEnabled
        configuration.label
            .font(EchoType.body)
            .foregroundStyle(ink)
            .padding(.horizontal, EchoSpace.item)
            .frame(minHeight: 44)
            .background(fill, in: RoundedRectangle(cornerRadius: EchoRadius.small, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: EchoRadius.small, style: .continuous)
                    .strokeBorder(stroke, lineWidth: isFocused || isSelected ? 2 : 1)
            }
            .opacity(isCooled ? 0.45 : (isEnabled ? 1 : 0.5))
            .scaleEffect(pressed && !reduceMotion ? 0.97 : 1)
            .animation(EchoMotion.pressAnimation(reduceMotion: reduceMotion), value: pressed)
            .contentShape(RoundedRectangle(cornerRadius: EchoRadius.small, style: .continuous))
    }

    private var fill: Color {
        if isError || isCooled { return EchoColor.muted.opacity(0.18) }
        if isSelected { return EchoColor.accent.opacity(0.16) }
        return EchoColor.surface
    }

    private var ink: Color {
        if isCooled || isError { return EchoColor.muted }
        return EchoColor.ink
    }

    private var stroke: Color {
        if isError { return EchoColor.ink.opacity(0.35) }
        if isSelected || isFocused { return EchoColor.accent }
        return EchoColor.muted.opacity(0.25)
    }
}

struct EchoEmptyPage<Art: View>: View {
    let headline: String
    let line: String
    let actionTitle: String
    let art: Art
    let action: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicType

    var body: some View {
        VStack(alignment: .leading, spacing: EchoSpace.item) {
            art
                .frame(maxWidth: .infinity)
                .frame(height: 180)
            Text(headline)
                .font(EchoType.display(for: dynamicType))
                .foregroundStyle(EchoColor.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
            Text(line)
                .font(EchoType.body)
                .foregroundStyle(EchoColor.muted)
            Spacer(minLength: EchoSpace.item)
            Button(actionTitle, action: action)
                .buttonStyle(ElidePillStyle(isEnabled: true, isLoading: false))
        }
        .padding(EchoSpace.section)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(EchoColor.background)
    }
}

struct EchoCutout: View {
    let name: String

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .accessibilityHidden(true)
    }
}

struct ChromePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ChromePressBody(configuration: configuration)
    }
}

private struct ChromePressBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .opacity(configuration.isPressed && reduceMotion ? 0.7 : 1)
            .animation(EchoMotion.pressAnimation(reduceMotion: reduceMotion), value: configuration.isPressed)
    }
}

struct SheetAppear: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var ready = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(ready || reduceMotion ? 1 : 0.96)
            .opacity(ready ? 1 : 0)
            .onAppear {
                withAnimation(EchoMotion.sheetAnimation(reduceMotion: reduceMotion)) {
                    ready = true
                }
            }
    }
}
