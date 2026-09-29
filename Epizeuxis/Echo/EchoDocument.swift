import Foundation

/// Codable projection of the in-memory echo. schemaVersion starts at 1.
struct EchoDocument: Codable, Sendable, Equatable {
    var schemaVersion: Int
    var echo: Echo
    var works: [Work]
    var card: EchoCard?
    var elideMarks: [ElideMark]
    var botchMarks: [BotchMark]
    var cachedWorks: [Work]
    var focusedWorkID: String?
    var onboardingComplete: Bool
    var loadWarning: String?

    static let currentSchema = 1

    static func empty() -> EchoDocument {
        EchoDocument(
            schemaVersion: currentSchema,
            echo: .idle,
            works: [],
            card: nil,
            elideMarks: [],
            botchMarks: [],
            cachedWorks: [],
            focusedWorkID: nil,
            onboardingComplete: false,
            loadWarning: nil
        )
    }

    var echoPool: [Work] {
        works.filter(\.canEcho)
    }

    var fairWorks: [Work] {
        works.filter { $0.fold == .fair }
    }

    var marksInOrder: [EchoMark] {
        let elides = elideMarks.map { EchoMark.elide($0) }
        let botches = botchMarks.map { EchoMark.botch($0) }
        return (elides + botches).sorted { $0.sequence < $1.sequence }
    }

    var nextSequence: Int {
        (marksInOrder.last?.sequence ?? 0) + 1
    }

    mutating func cacheResolved(_ incoming: [Work]) {
        var seen = Set(cachedWorks.map(\.identity))
        for work in incoming where seen.insert(work.identity).inserted {
            cachedWorks.append(work)
        }
    }
}

enum EchoDocumentCodec {
    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }

    static func encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    static func decode(_ data: Data) throws -> EchoDocument {
        let probe = try decoder().decode(SchemaProbe.self, from: data)
        switch probe.schemaVersion {
        case 1:
            return try decoder().decode(EchoDocument.self, from: data)
        default:
            throw EchoStorageError.unsupportedSchema(probe.schemaVersion)
        }
    }

    private struct SchemaProbe: Decodable {
        let schemaVersion: Int
    }
}

enum EchoStorageError: Error, Equatable {
    case unsupportedSchema(Int)
    case corrupt
}
