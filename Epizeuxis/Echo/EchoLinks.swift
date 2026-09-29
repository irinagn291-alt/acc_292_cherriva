import Foundation

/// Launch keys and Courtauld credit. Keys are not tabs.
enum ReviewScreenKey: String, Sendable, Equatable {
    case today
    case log
    case goals
    case explore
    case saved
    case settings
    case quiz
    case twist

    static func parse(arguments: [String]) -> ReviewScreenKey? {
        guard let flag = arguments.firstIndex(of: "-ReviewScreen") else { return nil }
        let next = arguments.index(after: flag)
        guard next < arguments.endIndex else { return nil }
        return ReviewScreenKey(rawValue: arguments[next].lowercased())
    }
}

enum EchoCredit {
    static let courtauldHome = URL(string: "https://courtauld.ac.uk")
    static let courtauldCollection = URL(string: "https://courtauld.ac.uk/gallery/collection/")
    static let wikidataGallery = URL(string: "https://www.wikidata.org/wiki/Q1138087")
    static let contact = URL(string: "https://epizeuxis-echo.pro/contact-us")
}
