import Foundation

/// A saved Courtauld painting. Identity is accession, else Q-id.
struct Work: Identifiable, Codable, Sendable, Equatable, Hashable {
    var id: String { identity }
    var identity: String
    var objectID: String
    var maker: String
    var title: String
    var imageFile: String
    var thumbURL: String
    var fold: WorkEcho
    var chosenField: ChosenField
    var daykey: Int

    var chosenRaw: String {
        switch chosenField {
        case .maker: return maker
        case .title: return title
        }
    }

    var canEcho: Bool {
        fold != .fair && Line.hasPairwiseDistinctTokens(chosenRaw)
    }

    static func pickField(maker: String, title: String) -> ChosenField? {
        if Line.hasPairwiseDistinctTokens(maker) { return .maker }
        if Line.hasPairwiseDistinctTokens(title) { return .title }
        return nil
    }

    static func commonsThumb(file: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        let encoded = file.addingPercentEncoding(withAllowedCharacters: allowed) ?? file
        return "https://commons.wikimedia.org/wiki/Special:FilePath/\(encoded)?width=960"
    }
}

/// QuizCard named in the echo lexicon: the live doubled caption on one Work.
struct EchoCard: Codable, Sendable, Equatable {
    var line: Line
    var workID: String { line.workID }
}

typealias QuizCard = EchoCard
