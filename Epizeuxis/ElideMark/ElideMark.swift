import Foundation

/// A successful tap on either identical neighbor. Folds Echoed to Fair.
struct ElideMark: Identifiable, Codable, Sendable, Equatable {
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
