import Foundation

/// Deep links and App Intent jobs. Not tabs.
enum EchoRoute: String, Sendable, Equatable {
    case quiz
    case explore
    case saved
    case settings
    case twist
    case echoLine = "echoline"
    case elideToken = "elidetoken"

    static func parse(_ url: URL) -> EchoRoute? {
        let host = url.host?.lowercased() ?? ""
        let parts = url.pathComponents.filter { $0 != "/" }.map { $0.lowercased() }
        let first = parts.first ?? host
        if url.scheme?.lowercased() == "epizeuxis" {
            return EchoRoute(rawValue: first) ?? EchoRoute(rawValue: host)
        }
        if host == "epizeuxis-echo.pro" || host == "www.epizeuxis-echo.pro" {
            return EchoRoute(rawValue: first)
        }
        return nil
    }
}

enum EchoSheet: String, Identifiable, Sendable, Equatable {
    case explore
    case saved
    case settings
    case twist

    var id: String { rawValue }
}

/// Shared seam so intents and URL jobs fold through one EchoStore.
@MainActor
enum EchoGate {
    static var store: EchoStore?
    static var router: EchoRouter?
}

@MainActor
@Observable
final class EchoRouter {
    var sheet: EchoSheet?
    var showsOnboarding = false
    private var didReadReview = false

    func consumeReviewArguments(_ arguments: [String] = ProcessInfo.processInfo.arguments) {
        guard !didReadReview else { return }
        didReadReview = true
        guard arguments.contains("-ReviewScreen") else { return }
        guard let key = ReviewScreenKey.parse(arguments: arguments) else { return }
        switch key {
        case .today, .quiz:
            sheet = nil
        case .log, .saved:
            sheet = .saved
        case .goals, .settings:
            sheet = .settings
        case .explore:
            sheet = .explore
        case .twist:
            sheet = .twist
        }
    }

    func open(_ route: EchoRoute?) {
        guard let route else { return }
        switch route {
        case .quiz:
            sheet = nil
        case .explore:
            sheet = .explore
        case .saved:
            sheet = .saved
        case .settings:
            sheet = .settings
        case .twist:
            sheet = .twist
        case .echoLine:
            _ = EchoGate.store?.echoLine()
        case .elideToken:
            if let tokenID = EchoGate.store?.card?.line.twinLeadingID {
                let outcome = EchoGate.store?.elideToken(tokenID)
                if outcome == .folded, EchoGate.store?.echo == .fair {
                    EchoHaptic.elideSuccess()
                }
            }
        }
    }
}
