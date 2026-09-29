import Foundation
import SwiftUI

/// In-memory source of truth. UserDefaults and the file are projections.
@MainActor
@Observable
final class EchoStore {
    private(set) var document: EchoDocument
    private let projection: EchoProjection
    private var writeTask: Task<Void, Never>?
    private let writeDelayNanoseconds: UInt64

    init(
        projection: EchoProjection,
        document: EchoDocument = .empty(),
        writeDelayNanoseconds: UInt64 = 350_000_000
    ) {
        self.projection = projection
        self.document = document
        self.writeDelayNanoseconds = writeDelayNanoseconds
    }

    static func bootstrap(suiteName: String? = nil) async -> EchoStore {
        let directory: URL
        if let url = try? EchoProjection.applicationSupportDirectory() {
            directory = url
        } else {
            directory = FileManager.default.temporaryDirectory.appendingPathComponent("Cherriva", isDirectory: true)
        }
        let projection = EchoProjection(suiteName: suiteName, directory: directory)
        var loaded = await projection.load()
        let seedDefaults = suiteName.flatMap { UserDefaults(suiteName: $0) } ?? .standard
        EchoSeed.applyIfNeeded(document: &loaded, defaults: seedDefaults)
        EchoSeed.repairImages(document: &loaded)
        await PaintingCache.shared.prefetch(loaded.works.map(\.thumbURL))
        let store = EchoStore(projection: projection, document: loaded)
        await store.persistNow()
        return store
    }

    var echo: Echo { document.echo }
    var card: EchoCard? { document.card }
    var works: [Work] { document.works }
    var elideMarks: [ElideMark] { document.elideMarks }
    var botchMarks: [BotchMark] { document.botchMarks }

    func echoLine(preferring identity: String? = nil) -> EchoOutcome {
        if document.echo == .echoed {
            return .refused(.secondEchoWhileEchoed)
        }
        let pool = document.echoPool
        guard !pool.isEmpty else {
            document.echo = .plain
            document.card = nil
            scheduleWrite()
            return .wrotePlain
        }
        let chosen: Work
        if let identity, let match = pool.first(where: { $0.identity == identity }) {
            chosen = match
        } else {
            chosen = pool[0]
        }
        guard let line = Line.echo(
            workID: chosen.identity,
            field: chosen.chosenField,
            raw: chosen.chosenRaw
        ) else {
            document.echo = .plain
            document.card = nil
            scheduleWrite()
            return .wrotePlain
        }
        if let index = document.works.firstIndex(where: { $0.identity == chosen.identity }) {
            document.works[index].fold = .echoed
        }
        document.echo = .echoed
        document.card = EchoCard(line: line)
        document.focusedWorkID = chosen.identity
        scheduleWrite()
        return .folded
    }

    func elideToken(_ tokenID: UUID) -> EchoOutcome {
        guard document.echo == .echoed, var card = document.card else {
            return .refused(.elideWhileIdle)
        }
        guard let token = card.line.tokens.first(where: { $0.id == tokenID }) else {
            return .refused(.noLiveLine)
        }
        let daykey = DayKey.fold(Date())
        if card.line.isTwin(tokenID) {
            let mark = ElideMark(
                workID: card.workID,
                tokenID: tokenID,
                tokenText: token.text,
                sequence: document.nextSequence,
                daykey: daykey
            )
            document.elideMarks.append(mark)
            if let index = document.works.firstIndex(where: { $0.identity == card.workID }) {
                document.works[index].fold = .fair
            }
            document.echo = .fair
            persistNowDebounced(force: true)
            return .folded
        }
        card.line.cool(tokenID)
        document.card = card
        let mark = BotchMark(
            workID: card.workID,
            tokenID: tokenID,
            tokenText: token.text,
            sequence: document.nextSequence,
            daykey: daykey
        )
        document.botchMarks.append(mark)
        persistNowDebounced(force: true)
        return .folded
    }

    func undoNewestMark() -> EchoOutcome {
        guard let newest = document.marksInOrder.last else {
            return .refused(.noLiveLine)
        }
        switch newest {
        case .elide(let mark):
            document.elideMarks.removeAll { $0.id == mark.id }
            if let index = document.works.firstIndex(where: { $0.identity == mark.workID }) {
                document.works[index].fold = .echoed
            }
            document.echo = .echoed
        case .botch(let mark):
            document.botchMarks.removeAll { $0.id == mark.id }
            if var card = document.card, card.workID == mark.workID {
                card.line.reheat(mark.tokenID)
                document.card = card
            }
        }
        persistNowDebounced(force: true)
        return .folded
    }

    func saveExplored(_ work: Work) -> EchoOutcome {
        if let index = document.works.firstIndex(where: { $0.objectID == work.objectID }) {
            document.focusedWorkID = document.works[index].identity
            scheduleWrite()
            return .focusedExisting
        }
        var incoming = work
        incoming.fold = .idle
        incoming.daykey = DayKey.fold(Date())
        if incoming.chosenField == .maker && !Line.hasPairwiseDistinctTokens(incoming.maker) {
            incoming.chosenField = Work.pickField(maker: incoming.maker, title: incoming.title) ?? .title
        }
        document.works.append(incoming)
        document.cacheResolved([incoming])
        persistNowDebounced(force: true)
        return .folded
    }

    func rememberCatalog(_ works: [Work]) {
        document.cacheResolved(works)
        scheduleWrite()
    }

    func catalogFallback() -> [Work] {
        if !document.cachedWorks.isEmpty { return document.cachedWorks }
        return CourtauldShelf.works(daykey: DayKey.fold(Date()))
    }

    func markOnboardingComplete() {
        document.onboardingComplete = true
        persistNowDebounced(force: true)
    }

    /// Re-read the projection after a failed load. A clean file clears the warning.
    func retryLoad() async {
        await persistNow()
        let loaded = await projection.load()
        if loaded.loadWarning != nil {
            document = loaded
        } else {
            document.loadWarning = nil
        }
    }

    func resetAllData() {
        writeTask?.cancel()
        writeTask = nil
        document = EchoDocument.empty()
        Task { await projection.reset() }
    }

    func flushForScenePhase(_ phase: ScenePhase) {
        guard phase == .inactive || phase == .background else { return }
        persistNowDebounced(force: true)
    }

    func persistNow() async {
        writeTask?.cancel()
        writeTask = nil
        await projection.save(document)
    }

    private func scheduleWrite() {
        persistNowDebounced(force: false)
    }

    private func persistNowDebounced(force: Bool) {
        writeTask?.cancel()
        if force {
            writeTask = Task { await projection.save(document) }
            return
        }
        writeTask = Task { [writeDelayNanoseconds] in
            try? await Task.sleep(nanoseconds: writeDelayNanoseconds)
            guard !Task.isCancelled else { return }
            await projection.save(document)
        }
    }
}
