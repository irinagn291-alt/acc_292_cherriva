import Foundation

/// Closed algebraic fold for the live echo. Plain is a write, not a Work case.
enum Echo: String, Codable, Sendable, Equatable {
    case idle
    case echoed
    case fair
    case plain
}

/// Per-work fold. Fair-ness lives here, never as a parallel bool.
enum WorkEcho: String, Codable, Sendable, Equatable {
    case idle
    case echoed
    case fair
}

/// Artist XOR title: the Line uses exactly one field.
enum ChosenField: String, Codable, Sendable, Equatable {
    case maker
    case title
}

enum EchoRefuse: Equatable, Sendable {
    case secondEchoWhileEchoed
    case elideWhileIdle
    case emptyOrThinField
    case noLiveLine
}

enum EchoOutcome: Equatable, Sendable {
    case folded
    case wrotePlain
    case refused(EchoRefuse)
    case focusedExisting
}
