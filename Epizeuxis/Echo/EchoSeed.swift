import Foundation

/// Simulator-only seed behind epz.demo.v2. Never writes Plain as the first frame.
enum EchoSeed {
    static let flagKey = "epz.demo.v2"

    static func shouldSeed(defaults: UserDefaults, isSimulator: Bool) -> Bool {
        guard isSimulator else { return false }
        return defaults.bool(forKey: flagKey) == false
    }

    static func applyIfNeeded(document: inout EchoDocument, defaults: UserDefaults) {
        #if targetEnvironment(simulator)
        guard shouldSeed(defaults: defaults, isSimulator: true) else { return }
        document = make(daykey: DayKey.fold(Date()))
        defaults.set(true, forKey: flagKey)
        #endif
    }

    static func make(daykey: Int) -> EchoDocument {
        var shelf = CourtauldShelf.works(daykey: daykey)
        guard shelf.count >= 4 else { return EchoDocument.empty() }

        shelf[0].fold = .echoed
        shelf[0].chosenField = .maker
        shelf[1].fold = .fair
        shelf[2].fold = .fair
        shelf[3].fold = .idle
        if shelf.count > 4 { shelf[4].fold = .idle }
        if shelf.count > 5 { shelf[5].fold = .fair }

        let raw = shelf[0].chosenRaw
        let line = Line.echo(
            workID: shelf[0].identity,
            field: shelf[0].chosenField,
            raw: raw,
            duplicateIndex: 0
        )
        let card: EchoCard
        if let line {
            card = EchoCard(line: line)
        } else {
            let first = Token(text: "Bar")
            let twin = Token(text: "Bar")
            card = EchoCard(
                line: Line(
                    workID: shelf[0].identity,
                    field: .title,
                    tokens: [Token(text: "A"), first, twin, Token(text: "at")],
                    twinLeadingID: first.id,
                    twinTrailingID: twin.id
                )
            )
        }

        let cooled = card.line.tokens.first(where: { !$0.lineTwin(card.line) })
        let botchOne = BotchMark(
            workID: shelf[0].identity,
            tokenID: cooled?.id ?? UUID(),
            tokenText: cooled?.text ?? "A",
            sequence: 1,
            daykey: daykey
        )
        let botchTwo = BotchMark(
            workID: shelf[1].identity,
            tokenID: UUID(),
            tokenText: Line.splitField(shelf[1].title).last ?? "Ear",
            sequence: 2,
            daykey: daykey
        )
        let elideOne = ElideMark(
            workID: shelf[1].identity,
            tokenID: UUID(),
            tokenText: Line.splitField(shelf[1].title).first ?? "Self",
            sequence: 3,
            daykey: daykey
        )
        let elideTwo = ElideMark(
            workID: shelf[2].identity,
            tokenID: UUID(),
            tokenText: Line.splitField(shelf[2].title).first ?? "The",
            sequence: 4,
            daykey: daykey
        )

        return repaired(EchoDocument(
            schemaVersion: EchoDocument.currentSchema,
            echo: .echoed,
            works: shelf,
            card: card,
            elideMarks: [elideOne, elideTwo],
            botchMarks: [botchOne, botchTwo],
            cachedWorks: shelf,
            focusedWorkID: shelf[0].identity,
            onboardingComplete: true,
            loadWarning: nil
        ))
    }

    /// Older seeds stored Commons names that 404. Rewrite the file and the thumb.
    static func repairImages(document: inout EchoDocument) {
        document.works = document.works.map(repairedWork)
        document.cachedWorks = document.cachedWorks.map(repairedWork)
    }

    private static func repaired(_ document: EchoDocument) -> EchoDocument {
        var copy = document
        repairImages(document: &copy)
        return copy
    }

    private static func repairedWork(_ work: Work) -> Work {
        var copy = work
        if let fixed = retiredFiles[copy.imageFile] {
            copy.imageFile = fixed
        }
        copy.thumbURL = copy.imageFile.isEmpty ? "" : Work.commonsThumb(file: copy.imageFile)
        return copy
    }

    private static let retiredFiles: [String: String] = [
        "Edouard_Manet,_A_Bar_at_the_Folies-Bergere.jpg": "Edouard Manet, A Bar at the Folies-Bergère.jpg",
        "Vincent_van_Gogh_-_Self-Portrait_with_Bandaged_Ear.jpg": "Vincent van Gogh - Self-portrait with bandaged ear (1889, Courtauld Institute).jpg",
        "Paul_Cezanne_The_Card_Players.jpg": "Les Joueurs de cartes, par Paul Cézanne.jpg",
        "Pierre-Auguste_Renoir_La_Loge.jpg": "Pierre-Auguste Renoir, La Loge, Courtauld Gallery.jpg",
        "Paul_Gauguin_Nevermore.jpg": "Paul Gauguin 091.jpg",
        "Georges_Seurat_Young_Woman_Powdering_Herself.jpg": "Young Woman Powdering Herself Georges Seurat.jpg"
    ]
}

private extension Token {
    func lineTwin(_ line: Line) -> Bool {
        line.isTwin(id)
    }
}
