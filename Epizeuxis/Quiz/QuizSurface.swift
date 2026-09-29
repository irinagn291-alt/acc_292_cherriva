import SwiftUI

/// Locked echo. Quiz is the home mechanic: doubled Line, Elide, Echo.
struct QuizSurface: View {
    @Environment(EchoStore.self) private var store
    @Environment(EchoRouter.self) private var router
    @Environment(\.dynamicTypeSize) private var dynamicType
    @State private var selectedToken: UUID?
    @State private var retryingLoad = false

    var body: some View {
        Group {
            if store.echo == .plain, store.document.echoPool.isEmpty {
                EchoEmptyPage(
                    headline: "The line is plain.",
                    line: "Save a work, then elide.",
                    actionTitle: "Explore",
                    art: EchoCutout(name: "epz_EmptyHome")
                ) {
                    router.sheet = .explore
                }
            } else {
                populated
            }
        }
        .background(EchoColor.background.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: 0) {
                chrome
                if let warning = store.document.loadWarning {
                    loadWarning(warning)
                }
            }
        }
        .onAppear {
            if store.echo == .idle, store.card == nil {
                _ = store.echoLine()
            }
            if selectedToken == nil {
                selectedToken = store.card?.line.twinLeadingID
            }
        }
        .onChange(of: store.card?.line.tokens.map(\.id)) { _, ids in
            let known = ids ?? []
            if selectedToken == nil || !known.contains(selectedToken ?? UUID()) {
                selectedToken = store.card?.line.twinLeadingID
            }
        }
    }

    private var chrome: some View {
        HStack(alignment: .center, spacing: EchoSpace.small) {
            Text(jobWord)
                .font(EchoType.display(for: dynamicType))
                .foregroundStyle(EchoColor.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .layoutPriority(1)
            Spacer(minLength: EchoSpace.small)
            iconButton("square.grid.2x2", label: "Explore") { router.sheet = .explore }
            iconButton("tray", label: "Saved") { router.sheet = .saved }
            iconButton("slider.horizontal.3", label: "Settings") { router.sheet = .settings }
        }
        .padding(.horizontal, EchoSpace.item)
        .padding(.vertical, EchoSpace.small)
        .background(EchoColor.background)
    }

    private var populated: some View {
        GeometryReader { geo in
            let pageWidth = geo.size.width
            let column = max(0, pageWidth - EchoSpace.item * 2)
            let heroHeight = fittedHeroHeight(available: geo.size.height, column: column)
            ScrollView {
                VStack(alignment: .leading, spacing: EchoSpace.item) {
                    heroTile(height: heroHeight)

                    captionBlock

                    tokenRail
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Tap \(twinWord), then Elide.")
                        .font(EchoType.body)
                        .foregroundStyle(EchoColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    verbRow

                    railAndStat

                    Button("Undo") {
                        _ = store.undoNewestMark()
                        selectedToken = store.card?.line.twinLeadingID
                    }
                    .font(EchoType.headline)
                    .foregroundStyle(EchoColor.ink)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(EchoColor.surface, in: Capsule())
                    .contentShape(Capsule())
                    .buttonStyle(ChromePressStyle())
                    .disabled(store.document.marksInOrder.isEmpty)
                    .opacity(store.document.marksInOrder.isEmpty ? 0.45 : 1)

                    Button {
                        router.sheet = .twist
                    } label: {
                        HStack(spacing: EchoSpace.small) {
                            Image("epz_ControlFace")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                                .accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: EchoSpace.tight) {
                                Text("How the twin works")
                                    .font(EchoType.headline)
                                    .foregroundStyle(EchoColor.ink)
                                Text("One word sits twice. Elide either twin.")
                                    .font(EchoType.micro)
                                    .foregroundStyle(EchoColor.muted)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: EchoSpace.small)
                        }
                        .padding(EchoSpace.item)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        .background(EchoColor.surface, in: RoundedRectangle(cornerRadius: EchoRadius.card, style: .continuous))
                        .contentShape(RoundedRectangle(cornerRadius: EchoRadius.card, style: .continuous))
                    }
                    .buttonStyle(ChromePressStyle())
                    .accessibilityLabel("How the twin works")
                }
                .padding(.horizontal, EchoSpace.item)
                .padding(.bottom, EchoSpace.item)
                .frame(width: pageWidth, alignment: .topLeading)
            }
            .frame(width: pageWidth, height: geo.size.height, alignment: .top)
            .clipped()
            .scrollDismissesKeyboard(.interactively)
        }
    }

    /// Photo-tile stays large enough to read the painting, and still leaves
    /// the twin, Elide, and the fair titles in the first viewport.
    private func fittedHeroHeight(available: CGFloat, column: CGFloat) -> CGFloat {
        let reserved: CGFloat = 500
        let preferred = min(max(column * 0.62, 188), 400)
        let fitted = available - reserved
        return min(preferred, max(188, fitted))
    }

    private func heroTile(height: CGFloat) -> some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: max(height, EchoSpace.block * 6))
            .overlay {
                GeometryReader { tile in
                    painting
                        .frame(width: tile.size.width, height: tile.size.height)
                        .clipped()
                }
            }
            .overlay(alignment: .top) {
                TileSheen()
                    .fill(.ultraThinMaterial)
                    .frame(height: 28)
                    .allowsHitTesting(false)
            }
            .overlay {
                if store.echo == .fair {
                    Image("epz_SuccessMark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .accessibilityHidden(true)
                }
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: EchoRadius.card, style: .continuous))
            .shadow(color: EchoShadow.color, radius: EchoShadow.radius, x: 0, y: EchoShadow.y)
            .overlay {
                RoundedRectangle(cornerRadius: EchoRadius.card, style: .continuous)
                    .strokeBorder(EchoColor.muted.opacity(0.12), lineWidth: 1)
            }
            .accessibilityLabel(liveWork?.title ?? "Painting")
    }

    private var painting: some View {
        WorkPainting(urlString: liveWork?.thumbURL ?? "")
    }

    private var captionBlock: some View {
        VStack(alignment: .leading, spacing: EchoSpace.tight) {
            Text(liveWork?.title ?? "Saved painting")
                .font(EchoType.headline)
                .foregroundStyle(EchoColor.ink)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(alignment: .firstTextBaseline, spacing: EchoSpace.small) {
                Text(fieldWord)
                    .font(EchoType.caption)
                    .foregroundStyle(EchoColor.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: EchoSpace.small)
                Text(statusWord)
                    .font(EchoType.caption)
                    .foregroundStyle(EchoColor.ink)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var tokenRail: some View {
        let tokens = store.card?.line.tokens ?? []
        return EchoWrap(spacing: EchoSpace.small) {
            ForEach(tokens) { token in
                Button {
                    selectedToken = token.id
                } label: {
                    HStack(spacing: EchoSpace.tight) {
                        Text(token.text)
                            .lineLimit(1)
                        if token.isCooled {
                            Text("cooled")
                                .font(EchoType.micro)
                        }
                    }
                }
                .buttonStyle(
                    TokenChipStyle(
                        isSelected: selectedToken == token.id || store.card?.line.isTwin(token.id) == true,
                        isCooled: token.isCooled,
                        isEnabled: store.echo == .echoed && !token.isCooled,
                        isError: token.isCooled
                    )
                )
                .disabled(store.echo != .echoed || token.isCooled)
                .accessibilityLabel(tokenAccessibility(token))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
    }

    private var verbRow: some View {
        Group {
            if store.echo == .echoed {
                Button("Elide") {
                    commitElide()
                }
                .buttonStyle(ElidePillStyle(isEnabled: elideEnabled, isLoading: false))
                .disabled(!elideEnabled)
            } else {
                Button("Write twice") {
                    _ = store.echoLine()
                    selectedToken = store.card?.line.twinLeadingID
                }
                .buttonStyle(ElidePillStyle(isEnabled: echoEnabled, isLoading: false))
                .disabled(!echoEnabled)
            }
        }
    }

    private var railAndStat: some View {
        HStack(alignment: .top, spacing: EchoSpace.item) {
            fairRail
                .frame(maxWidth: .infinity, alignment: .topLeading)
            markStat
                .frame(width: 104, alignment: .topLeading)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var fairRail: some View {
        let fair = store.document.fairWorks.suffix(6)
        return VStack(alignment: .leading, spacing: EchoSpace.small) {
            Text("Fair lately")
                .font(EchoType.caption)
                .foregroundStyle(EchoColor.muted)
            if fair.isEmpty {
                Text("Filed works rest here after an elide.")
                    .font(EchoType.caption)
                    .foregroundStyle(EchoColor.muted)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                VStack(alignment: .leading, spacing: EchoSpace.item) {
                    ForEach(Array(fair)) { work in
                        fairCell(work)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(EchoSpace.item)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(EchoColor.surface, in: RoundedRectangle(cornerRadius: EchoRadius.card, style: .continuous))
    }

    private func fairCell(_ work: Work) -> some View {
        Button {
            router.sheet = .saved
        } label: {
            HStack(alignment: .center, spacing: EchoSpace.small) {
                WorkPainting(urlString: work.thumbURL)
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: EchoRadius.small, style: .continuous))
                Text(work.title)
                    .font(EchoType.caption)
                    .foregroundStyle(EchoColor.ink)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(ChromePressStyle())
        .accessibilityLabel(work.title)
        .accessibilityHint("Opens Saved")
    }

    private var markStat: some View {
        VStack(alignment: .leading, spacing: EchoSpace.small) {
            statLine(count: store.elideMarks.count, caption: "Elides")
            statLine(count: store.botchMarks.count, caption: "Botches")
        }
        .padding(EchoSpace.item)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .background(EchoColor.surface, in: RoundedRectangle(cornerRadius: EchoRadius.card, style: .continuous))
    }

    private func statLine(count: Int, caption: String) -> some View {
        VStack(alignment: .leading, spacing: EchoSpace.tight) {
            Text(EchoFigure.countText(count))
                .font(EchoType.title)
                .foregroundStyle(EchoColor.ink)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(caption)
                .font(EchoType.caption)
                .foregroundStyle(EchoColor.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var liveWork: Work? {
        let identity = store.card?.workID ?? store.document.focusedWorkID
        return store.works.first { $0.identity == identity } ?? store.works.first
    }

    private var jobWord: String {
        switch store.echo {
        case .idle: return "Echo a work"
        case .echoed: return "Tap the twin"
        case .fair: return "File it fair"
        case .plain: return "The line is plain"
        }
    }

    private var statusWord: String {
        switch store.echo {
        case .idle: return "Idle"
        case .echoed: return "Echoed"
        case .fair: return "Fair"
        case .plain: return "Plain"
        }
    }

    private var twinWord: String {
        guard let line = store.card?.line else { return "the twin" }
        return line.tokens.first { line.isTwin($0.id) }?.text ?? "the twin"
    }

    private var fieldWord: String {
        switch store.card?.line.field {
        case .maker: return "Maker line"
        case .title: return "Title line"
        case .none: return "Line"
        }
    }

    private var elideEnabled: Bool {
        store.echo == .echoed && selectedToken != nil
    }

    private var echoEnabled: Bool {
        store.echo != .echoed
    }

    private func loadWarning(_ warning: String) -> some View {
        VStack(alignment: .leading, spacing: EchoSpace.small) {
            Text(warning)
                .font(EchoType.body)
                .foregroundStyle(EchoColor.ink)
                .lineLimit(3)
            Button("Try again") {
                retryingLoad = true
                Task {
                    await store.retryLoad()
                    retryingLoad = false
                }
            }
            .buttonStyle(ElidePillStyle(isEnabled: !retryingLoad, isLoading: retryingLoad))
            .disabled(retryingLoad)
        }
        .padding(EchoSpace.item)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(EchoColor.surface)
    }

    private func commitElide() {
        guard let selectedToken else { return }
        applyElide(selectedToken)
    }

    private func applyElide(_ tokenID: UUID) {
        let before = store.elideMarks.count
        let outcome = store.elideToken(tokenID)
        if outcome == .folded, store.elideMarks.count > before {
            EchoHaptic.elideSuccess()
        }
    }

    private func tokenAccessibility(_ token: Token) -> String {
        if token.isCooled { return "\(token.text), cooled" }
        if store.card?.line.isTwin(token.id) == true { return "\(token.text), written twice" }
        return token.text
    }

    private func iconButton(_ system: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(EchoType.headline)
                .foregroundStyle(EchoColor.ink)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(ChromePressStyle())
        .accessibilityLabel(label)
    }
}

/// Tokens stay inside the quiz column. A horizontal scroller was widening the page.
struct EchoWrap: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        let rows = rows(maxWidth: maxWidth, subviews: subviews)
        let height = rows.reduce(CGFloat(0)) { $0 + $1.height } + spacing * CGFloat(max(rows.count - 1, 0))
        let width = maxWidth > 0 ? maxWidth : rows.map(\.width).max() ?? 0
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = rows(maxWidth: bounds.width, subviews: subviews)
        var y = bounds.minY
        var index = 0
        for row in rows {
            var x = bounds.minX
            for size in row.sizes {
                subviews[index].place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(width: size.width, height: size.height)
                )
                x += size.width + spacing
                index += 1
            }
            y += row.height + spacing
        }
    }

    private func rows(maxWidth: CGFloat, subviews: Subviews) -> [EchoWrapRow] {
        var rows: [EchoWrapRow] = []
        var current: [CGSize] = []
        var x: CGFloat = 0
        var rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            let next = x == 0 ? size.width : x + spacing + size.width
            if maxWidth > 0, next > maxWidth, !current.isEmpty {
                rows.append(EchoWrapRow(sizes: current, width: x, height: rowHeight))
                current = [size]
                x = size.width
                rowHeight = size.height
            } else {
                current.append(size)
                x = next
                rowHeight = max(rowHeight, size.height)
            }
        }
        if !current.isEmpty {
            rows.append(EchoWrapRow(sizes: current, width: x, height: rowHeight))
        }
        return rows
    }
}

private struct EchoWrapRow {
    var sizes: [CGSize]
    var width: CGFloat
    var height: CGFloat
}

/// Custom drawing confined to the Quiz photo-tile.
struct TileSheen: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: rect.height * 0.18))
            path.addQuadCurve(
                to: CGPoint(x: rect.width, y: 0),
                control: CGPoint(x: rect.width * 0.45, y: 0)
            )
            path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.14))
            path.addQuadCurve(
                to: CGPoint(x: 0, y: rect.height * 0.28),
                control: CGPoint(x: rect.width * 0.55, y: rect.height * 0.08)
            )
            path.closeSubpath()
        }
    }
}
