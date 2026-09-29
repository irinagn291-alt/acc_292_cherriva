import Foundation

protocol CatalogTransport: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

struct URLSessionCatalogTransport: CatalogTransport {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(for: request)
    }
}

enum CatalogFailure: Error, Equatable, Sendable {
    case emptyQuery
    case cancelled
    case transport
    case decoding
    case notFound
    case httpStatus(Int)
}

/// Owns Wikidata SPARQL search and EntityData hydrate. cgi search pl maps onto query, json, page, page_size.
actor CatalogClient {
    static let userAgent = "Epizeuxis/1.0 (iOS; +https://epizeuxis-echo.pro)"
    static let searchHost = "query.wikidata.org"
    static let searchURL = URL(string: "https://query.wikidata.org/sparql")
    static let entityRoot = "https://www.wikidata.org/wiki/Special:EntityData/"

    private let transport: any CatalogTransport
    private let decoder: JSONDecoder
    private var searchTask: Task<[Work], Error>?

    init(transport: any CatalogTransport = URLSessionCatalogTransport()) {
        self.transport = transport
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder = decoder
    }

    func searchDebounced(
        query: String,
        page: Int = 1,
        pageSize: Int = 20,
        delayNanoseconds: UInt64 = 500_000_000
    ) async throws -> [Work] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        searchTask?.cancel()
        let work = Task {
            try await Task.sleep(nanoseconds: delayNanoseconds)
            try Task.checkCancellation()
            return try await self.performSearch(query: trimmed, page: page, pageSize: pageSize)
        }
        searchTask = work
        do {
            return try await work.value
        } catch is CancellationError {
            throw CatalogFailure.cancelled
        }
    }

    func cancelSearch() {
        searchTask?.cancel()
        searchTask = nil
    }

    func search(query: String, page: Int = 1, pageSize: Int = 20) async throws -> [Work] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        searchTask?.cancel()
        let work = Task {
            try await self.performSearch(query: trimmed, page: page, pageSize: pageSize)
        }
        searchTask = work
        do {
            return try await work.value
        } catch is CancellationError {
            throw CatalogFailure.cancelled
        }
    }

    func resolve(qid: String) async throws -> Work {
        try await hydrate(qid: qid)
    }

    func searchRequest(query: String, page: Int, pageSize: Int) -> URLRequest? {
        guard let searchURL = Self.searchURL else { return nil }
        var parts = URLComponents(url: searchURL, resolvingAgainstBaseURL: false)
        let offset = max(page - 1, 0) * pageSize
        parts?.queryItems = [
            URLQueryItem(name: "query", value: sparql(query: query, limit: pageSize, offset: offset)),
            URLQueryItem(name: "format", value: "json")
        ]
        guard let url = parts?.url else { return nil }
        return identifiedRequest(url)
    }

    func entityRequest(qid: String) -> URLRequest? {
        let clean = qid.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard !clean.isEmpty,
              let url = URL(string: "\(Self.entityRoot)\(clean).json") else { return nil }
        return identifiedRequest(url)
    }

    private func identifiedRequest(_ url: URL) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private func sparql(query: String, limit: Int, offset: Int) -> String {
        let safe = query
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        return """
        SELECT DISTINCT ?item WHERE {
          ?item wdt:P195 wd:Q1138087 .
          ?item wdt:P170 ?maker .
          ?item wdt:P18 ?image .
          OPTIONAL { ?item wdt:P1476 ?title . }
          ?item rdfs:label ?label .
          FILTER(LANG(?label) = "en")
          FILTER(CONTAINS(LCASE(STR(?label)), LCASE("\(safe)")) || CONTAINS(LCASE(STR(?title)), LCASE("\(safe)")))
        }
        LIMIT \(limit) OFFSET \(offset)
        """
    }

    private func performSearch(query: String, page: Int, pageSize: Int) async throws -> [Work] {
        try Task.checkCancellation()
        guard let request = searchRequest(query: query, page: page, pageSize: pageSize) else {
            throw CatalogFailure.transport
        }
        let data = try await fetch(request)
        try Task.checkCancellation()
        let payload: SparqlDTO
        do {
            payload = try decoder.decode(SparqlDTO.self, from: data)
        } catch {
            throw CatalogFailure.decoding
        }
        var works: [Work] = []
        for binding in payload.results?.bindings ?? [] {
            try Task.checkCancellation()
            guard let qid = binding.item?.qid else { continue }
            if let work = try? await hydrate(qid: qid) {
                works.append(work)
            }
        }
        return works
    }

    private func hydrate(qid: String) async throws -> Work {
        guard let request = entityRequest(qid: qid) else { throw CatalogFailure.transport }
        let data = try await fetch(request)
        let box: EntityDataDTO
        do {
            box = try decoder.decode(EntityDataDTO.self, from: data)
        } catch {
            throw CatalogFailure.decoding
        }
        guard let entity = box.entities?.values.first else {
            throw CatalogFailure.notFound
        }
        guard let work = WikidataMap.work(from: entity, fallbackQID: qid) else {
            throw CatalogFailure.notFound
        }
        return work
    }

    private func fetch(_ request: URLRequest) async throws -> Data {
        try await fetch(request, allowRetry: true)
    }

    private func fetch(_ request: URLRequest, allowRetry: Bool) async throws -> Data {
        try Task.checkCancellation()
        do {
            let (data, response) = try await transport.data(for: request)
            if let http = response as? HTTPURLResponse {
                if http.statusCode == 404 {
                    throw CatalogFailure.notFound
                }
                if http.statusCode == 0 {
                    throw CatalogFailure.notFound
                }
                if !(200...299).contains(http.statusCode) {
                    throw CatalogFailure.httpStatus(http.statusCode)
                }
            }
            return data
        } catch let failure as CatalogFailure {
            throw failure
        } catch is CancellationError {
            throw CatalogFailure.cancelled
        } catch {
            if allowRetry, isTransient(error) {
                return try await fetch(request, allowRetry: false)
            }
            throw CatalogFailure.transport
        }
    }

    private func isTransient(_ error: Error) -> Bool {
        let urlError = error as? URLError
        switch urlError?.code {
        case .timedOut, .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost:
            return true
        default:
            return false
        }
    }
}

struct SparqlDTO: Decodable, Sendable {
    struct Results: Decodable, Sendable {
        let bindings: [Binding]?
    }

    struct Binding: Decodable, Sendable {
        let item: Node?
    }

    struct Node: Decodable, Sendable {
        let type: String?
        let value: String?

        var qid: String? {
            guard let value else { return nil }
            return value.split(separator: "/").last.map(String.init)
        }
    }

    let results: Results?
}

struct EntityDataDTO: Decodable, Sendable {
    let entities: [String: EntityDTO]?
}

struct EntityDTO: Decodable, Sendable {
    let id: String?
    let labels: [String: LabelDTO]?
    let claims: ClaimsDTO?
}

struct LabelDTO: Decodable, Sendable {
    let value: String?
}

struct ClaimsDTO: Decodable, Sendable {
    let P170: [ClaimDTO]?
    let P1476: [ClaimDTO]?
    let P217: [ClaimDTO]?
    let P18: [ClaimDTO]?
}

struct ClaimDTO: Decodable, Sendable {
    let mainsnak: SnakDTO?
}

struct SnakDTO: Decodable, Sendable {
    let datavalue: DataValueDTO?
}

struct DataValueDTO: Decodable, Sendable {
    let type: String?
    let value: FlexibleValue?
}

enum FlexibleValue: Decodable, Sendable {
    case text(String)
    case entity(EntityValue)
    case mono(MonoValue)
    case unknown

    struct EntityValue: Decodable, Sendable {
        let id: String?
    }

    struct MonoValue: Decodable, Sendable {
        let text: String?
        let language: String?
    }

    init(from decoder: Decoder) throws {
        if let keyed = try? decoder.container(keyedBy: ObjectKeys.self) {
            if let text = try keyed.decodeIfPresent(String.self, forKey: .text), !text.isEmpty {
                self = .mono(MonoValue(text: text, language: try keyed.decodeIfPresent(String.self, forKey: .language)))
                return
            }
            if let id = try keyed.decodeIfPresent(String.self, forKey: .id), !id.isEmpty {
                self = .entity(EntityValue(id: id))
                return
            }
        }
        let container = try decoder.singleValueContainer()
        if let text = try? container.decode(String.self) {
            self = .text(text)
            return
        }
        self = .unknown
    }

    private enum ObjectKeys: String, CodingKey {
        case text
        case language
        case id
    }

    var string: String? {
        switch self {
        case .text(let text): return text
        case .entity(let entity): return entity.id
        case .mono(let mono): return mono.text
        case .unknown: return nil
        }
    }
}

enum WikidataMap {
    static func work(from entity: EntityDTO, fallbackQID: String) -> Work? {
        let qid = entity.id ?? fallbackQID
        let accession = firstString(entity.claims?.P217) ?? qid
        let makerID = firstString(entity.claims?.P170)
        let title = firstString(entity.claims?.P1476) ?? entity.labels?["en"]?.value ?? ""
        let file = firstString(entity.claims?.P18) ?? ""
        let maker = makerID.map { $0.hasPrefix("Q") ? $0 : $0 } ?? ""
        let makerName = maker.isEmpty ? (entity.labels?["en"]?.value ?? "") : maker
        let resolvedMaker = makerName
        guard !resolvedMaker.isEmpty || !title.isEmpty else { return nil }
        let field = Work.pickField(maker: resolvedMaker, title: title)
        let usableMaker = resolvedMaker.isEmpty ? title : resolvedMaker
        let usableTitle = title.isEmpty ? resolvedMaker : title
        guard field != nil || Line.hasPairwiseDistinctTokens(usableMaker) || Line.hasPairwiseDistinctTokens(usableTitle) else {
            return Work(
                identity: accession,
                objectID: qid,
                maker: usableMaker,
                title: usableTitle,
                imageFile: file,
                thumbURL: file.isEmpty ? "" : Work.commonsThumb(file: file),
                fold: .idle,
                chosenField: .title,
                daykey: DayKey.fold(Date())
            )
        }
        return Work(
            identity: accession,
            objectID: qid,
            maker: usableMaker,
            title: usableTitle,
            imageFile: file,
            thumbURL: file.isEmpty ? "" : Work.commonsThumb(file: file),
            fold: .idle,
            chosenField: field ?? .title,
            daykey: DayKey.fold(Date())
        )
    }

    private static func firstString(_ claims: [ClaimDTO]?) -> String? {
        for claim in claims ?? [] {
            if let value = claim.mainsnak?.datavalue?.value?.string, !value.isEmpty {
                return value
            }
        }
        return nil
    }
}
