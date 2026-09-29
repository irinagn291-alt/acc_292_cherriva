import Foundation

/// A miss on the doubled Line. Keeps Echoed and cools that Token.
struct BotchMark: Identifiable, Codable, Sendable, Equatable {
    let id: UUID
    let workID: String
    let tokenID: UUID
    let tokenText: String
    let sequence: Int
    let daykey: Int

    init(
        id: UUID = UUID(),
        workID: String,
        tokenID: UUID,
        tokenText: String,
        sequence: Int,
        daykey: Int
    ) {
        self.id = id
        self.workID = workID
        self.tokenID = tokenID
        self.tokenText = tokenText
        self.sequence = sequence
        self.daykey = daykey
    }
}

/// Newest-first peel for Undo. Sequence is the only stored order.
enum EchoMark: Codable, Sendable, Equatable {
    case elide(ElideMark)
    case botch(BotchMark)

    var sequence: Int {
        switch self {
        case .elide(let mark): return mark.sequence
        case .botch(let mark): return mark.sequence
        }
    }
}
