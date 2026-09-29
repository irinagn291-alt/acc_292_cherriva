import XCTest
@testable import Epizeuxis

@MainActor
final class EpizeuxisTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: EpizeuxisApp.self), "EpizeuxisApp")
    }

    func testFamilyInvariant_quizDrawsFromSavedWorks_botchesReviewable() async {
        let store = makeStore()
        let work = shelfWork(index: 0, fold: .idle)
        _ = store.saveExplored(work)
        XCTAssertEqual(store.echoLine(), .folded)
        XCTAssertEqual(store.echo, .echoed)
        XCTAssertEqual(store.card?.workID, work.identity)
        XCTAssertTrue(store.works.contains { $0.identity == work.identity })

        guard let miss = store.card?.line.tokens.first(where: { !store.card!.line.isTwin($0.id) }) else {
            return XCTFail("need a non-twin token")
        }
        _ = store.elideToken(miss.id)
        XCTAssertFalse(store.botchMarks.isEmpty)
        XCTAssertEqual(store.echo, .echoed)
        XCTAssertEqual(store.document.fairWorks.count, 0)
    }

    func testEchoSamplesNotFairPairwiseDistinctAndWritesAdjacentTwin() {
        let store = makeStore(works: [
            shelfWork(index: 0, fold: .fair),
            shelfWork(index: 1, fold: .idle)
        ])
        XCTAssertEqual(store.echoLine(), .folded)
        XCTAssertEqual(store.card?.workID, shelfWork(index: 1, fold: .idle).identity)
        guard let line = store.card?.line else { return XCTFail("line") }
        XCTAssertTrue(line.field == .maker || line.field == .title)
        let texts = line.tokens.map(\.text)
        let pairIndex = texts.indices.dropLast().first { texts[$0] == texts[$0 + 1] }
        XCTAssertNotNil(pairIndex)
        XCTAssertEqual(Set(texts).count >= 2, true)
        XCTAssertEqual(store.works.first { $0.identity == line.workID }?.fold, .echoed)
    }

    func testElideOnIdleRefused_secondEchoWhileEchoedRefused() {
        let store = makeStore(works: [shelfWork(index: 0, fold: .idle)])
        XCTAssertEqual(store.elideToken(UUID()), .refused(.elideWhileIdle))
        XCTAssertEqual(store.echoLine(), .folded)
        XCTAssertEqual(store.echoLine(), .refused(.secondEchoWhileEchoed))
    }

    func testEitherTwinFoldsFair_missKeepsLine_undoFoldsBack() {
        let store = makeStore(works: [shelfWork(index: 0, fold: .idle)])
        _ = store.echoLine()
        guard let line = store.card?.line else { return XCTFail("line") }
        let miss = line.tokens.first { !line.isTwin($0.id) }
        if let miss {
            _ = store.elideToken(miss.id)
            XCTAssertEqual(store.echo, .echoed)
            XCTAssertEqual(store.botchMarks.count, 1)
            XCTAssertEqual(store.undoNewestMark(), .folded)
            XCTAssertTrue(store.botchMarks.isEmpty)
        }
        let twin = line.twinLeadingID
        _ = store.elideToken(twin)
        XCTAssertEqual(store.echo, .fair)
        XCTAssertEqual(store.works.first?.fold, .fair)
        XCTAssertTrue(store.document.echoPool.isEmpty)
        _ = store.undoNewestMark()
        XCTAssertEqual(store.echo, .echoed)
        XCTAssertEqual(store.works.first?.fold, .echoed)
        XCTAssertFalse(store.document.echoPool.isEmpty)
    }

    func testEmptyCrateWritesPlain_thinFieldWritesPlain() {
        let empty = makeStore()
        XCTAssertEqual(empty.echoLine(), .wrotePlain)
        XCTAssertEqual(empty.echo, .plain)

        var thin = shelfWork(index: 0, fold: .idle)
        thin.maker = "Manet"
        thin.title = "Nevermore"
        thin.chosenField = .maker
        let store = makeStore(works: [thin])
        XCTAssertEqual(store.echoLine(), .wrotePlain)
        XCTAssertEqual(store.echo, .plain)
    }

    func testExploreDuplicateFocusDoesNotResetEcho() {
        let first = shelfWork(index: 0, fold: .idle)
        let store = makeStore(works: [first])
        _ = store.echoLine()
        XCTAssertEqual(store.echo, .echoed)
        var again = first
        again.title = "Changed"
        XCTAssertEqual(store.saveExplored(again), .focusedExisting)
        XCTAssertEqual(store.echo, .echoed)
        XCTAssertEqual(store.works.count, 1)
    }

    func testPersistenceRoundTripAndCorruptFallback() async {
        let suite = "epz.test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("epz-\(UUID().uuidString)", isDirectory: true)
        let projection = EchoProjection(suiteName: suite, directory: directory)
        var seed = EchoSeed.make(daykey: 20_260_921)
        seed.echo = .echoed
        await projection.save(seed)

        let reloaded = await projection.load()
        XCTAssertEqual(reloaded.works.count, seed.works.count)
        XCTAssertEqual(reloaded.echo, .echoed)
        XCTAssertNotNil(reloaded.card)
        XCTAssertFalse(reloaded.botchMarks.isEmpty)
        XCTAssertFalse(reloaded.elideMarks.isEmpty)

        defaults.set(Data("not-json".utf8), forKey: EchoProjection.primaryKey)
        try? Data("broken".utf8).write(to: directory.appendingPathComponent("echo.v1.json"), options: .atomic)
        let recovered = await projection.load()
        XCTAssertGreaterThanOrEqual(recovered.works.count, 1)

        defaults.set(Data("{".utf8), forKey: EchoProjection.primaryKey)
        defaults.set(Data("{".utf8), forKey: EchoProjection.backupKey)
        try? FileManager.default.removeItem(at: directory.appendingPathComponent("echo.v1.json"))
        try? FileManager.default.removeItem(at: directory.appendingPathComponent("echo.v1.json.backup"))
        let empty = await projection.load()
        XCTAssertEqual(empty.works.count, 0)
        XCTAssertEqual(empty.echo, .idle)

        defaults.removePersistentDomain(forName: suite)
    }

    func testResetAllDataClearsMemory() async {
        let store = makeStore(works: [shelfWork(index: 0, fold: .idle)])
        _ = store.echoLine()
        store.resetAllData()
        XCTAssertEqual(store.works.count, 0)
        XCTAssertEqual(store.echo, .idle)
    }

    func testCatalogRequestIdentityAndEmptyQuerySkipsNetwork() async throws {
        let transport = RecordingTransport()
        let client = CatalogClient(transport: transport)
        let empty = try await client.search(query: "   ")
        XCTAssertTrue(empty.isEmpty)
        let recorded = await transport.requests
        XCTAssertTrue(recorded.isEmpty)

        let request = await client.searchRequest(query: "manet", page: 2, pageSize: 10)
        XCTAssertEqual(request?.url?.host, "query.wikidata.org")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "User-Agent"), CatalogClient.userAgent)
        XCTAssertTrue(request?.url?.query?.contains("format=json") == true)
        XCTAssertTrue(request?.url?.absoluteString.contains("query") == true)
        XCTAssertFalse(request?.url?.absoluteString.contains("openfoodfacts") == true)
        XCTAssertFalse(request?.url?.absoluteString.contains("cgi/search.pl") == true)

        let entity = await client.entityRequest(qid: "Q1889113")
        XCTAssertTrue(entity?.url?.absoluteString.contains("Special:EntityData/Q1889113.json") == true)
    }

    func testCatalogDecodeMapsDTOAndNotFound() async {
        let transport = ScriptedTransport(responses: [
            .success(Self.sparqlJSON),
            .success(Self.entityJSON)
        ])
        let client = CatalogClient(transport: transport)
        do {
            let works = try await client.search(query: "bar")
            XCTAssertEqual(works.first?.identity, "P.1932.SC.193")
            XCTAssertEqual(works.first?.objectID, "Q1889113")
            XCTAssertEqual(works.first?.title, "A Bar at the Folies Bergere")
        } catch {
            XCTFail("search should map")
        }

        let missing = ScriptedTransport(responses: [
            .http(404, Data())
        ])
        let failClient = CatalogClient(transport: missing)
        do {
            _ = try await failClient.resolve(qid: "Q0")
            XCTFail("expected not found")
        } catch let failure as CatalogFailure {
            XCTAssertEqual(failure, .notFound)
        } catch {
            XCTFail("typed error")
        }
    }

    func testMalformedJSONIsHandled() async {
        let transport = ScriptedTransport(responses: [.success(Data("[]".utf8))])
        let client = CatalogClient(transport: transport)
        do {
            _ = try await client.search(query: "manet")
            XCTFail("decoding")
        } catch let failure as CatalogFailure {
            XCTAssertEqual(failure, .decoding)
        } catch {
            XCTFail("typed")
        }
    }

    func testEchoRouteParsesSchemeAndSitePaths() {
        XCTAssertEqual(EchoRoute.parse(URL(string: "epizeuxis://quiz")!), .quiz)
        XCTAssertEqual(EchoRoute.parse(URL(string: "epizeuxis://explore")!), .explore)
        XCTAssertEqual(EchoRoute.parse(URL(string: "https://epizeuxis-echo.pro/saved")!), .saved)
        XCTAssertEqual(EchoRoute.parse(URL(string: "https://epizeuxis-echo.pro/settings")!), .settings)
        XCTAssertEqual(EchoRoute.parse(URL(string: "epizeuxis://echoLine")!), .echoLine)
        XCTAssertNil(EchoRoute.parse(URL(string: "https://example.com/quiz")!))
    }

    func testReviewScreenKeysAreNotTabs() {
        XCTAssertEqual(ReviewScreenKey.parse(arguments: ["-ReviewScreen", "today"]), .today)
        XCTAssertEqual(ReviewScreenKey.parse(arguments: ["-ReviewScreen", "log"]), .log)
        XCTAssertEqual(ReviewScreenKey.parse(arguments: ["-ReviewScreen", "goals"]), .goals)
        XCTAssertEqual(ReviewScreenKey.parse(arguments: ["-ReviewScreen", "explore"]), .explore)
        XCTAssertEqual(ReviewScreenKey.parse(arguments: ["-ReviewScreen", "saved"]), .saved)
        XCTAssertEqual(ReviewScreenKey.parse(arguments: ["-ReviewScreen", "settings"]), .settings)
        XCTAssertNil(ReviewScreenKey.parse(arguments: ["-ReviewScreen"]))
        XCTAssertNotEqual(ReviewScreenKey.today, ReviewScreenKey.log)
        XCTAssertNotEqual(ReviewScreenKey.log, ReviewScreenKey.goals)
        XCTAssertNotEqual(ReviewScreenKey.today, ReviewScreenKey.goals)
    }

    func testReviewScreenHookOpensThreeDifferentScreensOnce() {
        let today = EchoRouter()
        today.consumeReviewArguments(["-ReviewScreen", "today"])
        XCTAssertNil(today.sheet)
        today.consumeReviewArguments(["-ReviewScreen", "log"])
        XCTAssertNil(today.sheet)

        let log = EchoRouter()
        log.consumeReviewArguments(["-ReviewScreen", "log"])
        XCTAssertEqual(log.sheet, .saved)

        let goals = EchoRouter()
        goals.consumeReviewArguments(["-ReviewScreen", "goals"])
        XCTAssertEqual(goals.sheet, .settings)

        let explore = EchoRouter()
        explore.consumeReviewArguments(["-ReviewScreen", "explore"])
        XCTAssertEqual(explore.sheet, .explore)

        let saved = EchoRouter()
        saved.consumeReviewArguments(["-ReviewScreen", "saved"])
        XCTAssertEqual(saved.sheet, .saved)
    }

    func testSeedNeverStartsPlainAndUsesDistinctTokens() {
        let document = EchoSeed.make(daykey: 20_260_921)
        XCTAssertNotEqual(document.echo, .plain)
        XCTAssertEqual(document.echo, .echoed)
        XCTAssertTrue(document.onboardingComplete)
        XCTAssertGreaterThanOrEqual(document.works.count, 4)
        XCTAssertGreaterThanOrEqual(document.botchMarks.count, 2)
        XCTAssertNotNil(document.card)
        let texts = document.card?.line.tokens.map(\.text) ?? []
        XCTAssertGreaterThanOrEqual(Set(texts).count, 2)
        let adjacent = texts.indices.dropLast().contains { texts[$0] == texts[$0 + 1] }
        XCTAssertTrue(adjacent)
    }

    func testDayKeyFoldsStartOfDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = calendar.date(from: DateComponents(year: 2026, month: 9, day: 21, hour: 18))!
        XCTAssertEqual(DayKey.fold(date, calendar: calendar), 20_260_921)
    }

    private func makeStore(works: [Work] = []) -> EchoStore {
        let suite = "epz.mem.\(UUID().uuidString)"
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("epz-mem-\(UUID().uuidString)", isDirectory: true)
        let projection = EchoProjection(suiteName: suite, directory: directory)
        var document = EchoDocument.empty()
        document.works = works
        return EchoStore(projection: projection, document: document, writeDelayNanoseconds: 1)
    }

    private func shelfWork(index: Int, fold: WorkEcho) -> Work {
        var work = CourtauldShelf.works(daykey: 20_260_921)[index]
        work.fold = fold
        return work
    }

    private static let sparqlJSON = Data(
        """
        {"results":{"bindings":[{"item":{"type":"uri","value":"http://www.wikidata.org/entity/Q1889113"}}]}}
        """.utf8
    )

    private static let entityJSON = Data(
        """
        {"entities":{"Q1889113":{"id":"Q1889113","labels":{"en":{"value":"A Bar at the Folies Bergere"}},"claims":{"P170":[{"mainsnak":{"datavalue":{"type":"wikibase-entityid","value":{"id":"Q40599"}}}}],"P1476":[{"mainsnak":{"datavalue":{"type":"monolingualtext","value":{"text":"A Bar at the Folies Bergere","language":"en"}}}}],"P217":[{"mainsnak":{"datavalue":{"type":"string","value":"P.1932.SC.193"}}}],"P18":[{"mainsnak":{"datavalue":{"type":"string","value":"Edouard_Manet.jpg"}}}]}}}}
        """.utf8
    )
}

private actor RecordingTransport: CatalogTransport {
    var requests: [URLRequest] = []

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requests.append(request)
        throw URLError(.notConnectedToInternet)
    }
}

private enum ScriptedResult: Sendable {
    case success(Data)
    case http(Int, Data)
}

private actor ScriptedTransport: CatalogTransport {
    private var responses: [ScriptedResult]

    init(responses: [ScriptedResult]) {
        self.responses = responses
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let fallback = URL(string: "https://query.wikidata.org/sparql")
        let url = request.url ?? fallback ?? URL(fileURLWithPath: "/tmp")
        guard !responses.isEmpty else {
            throw URLError(.badServerResponse)
        }
        let next = responses.removeFirst()
        switch next {
        case .success(let data):
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            return (data, response ?? URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil))
        case .http(let code, let data):
            let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)
            return (data, response ?? URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil))
        }
    }
}
