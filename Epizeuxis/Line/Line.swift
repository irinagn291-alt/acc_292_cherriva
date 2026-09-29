import Foundation

/// Artist XOR title with one token written a second time beside itself.
struct Line: Codable, Sendable, Equatable {
    let workID: String
    let field: ChosenField
    var tokens: [Token]
    let twinLeadingID: UUID
    let twinTrailingID: UUID

    var twinIDs: Set<UUID> {
        [twinLeadingID, twinTrailingID]
    }

    func isTwin(_ tokenID: UUID) -> Bool {
        tokenID == twinLeadingID || tokenID == twinTrailingID
    }

    static func splitField(_ raw: String) -> [String] {
        raw
            .split { $0.isWhitespace || $0 == "/" }
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
            .filter { !$0.isEmpty }
    }

    static func hasPairwiseDistinctTokens(_ raw: String) -> Bool {
        Set(splitField(raw)).count >= 2
    }

    static func echo(
        workID: String,
        field: ChosenField,
        raw: String,
        duplicateIndex: Int? = nil
    ) -> Line? {
        let parts = splitField(raw)
        guard Set(parts).count >= 2 else { return nil }
        let pick: Int
        if let duplicateIndex, parts.indices.contains(duplicateIndex) {
            pick = duplicateIndex
        } else if let firstDistinct = parts.indices.first(where: { index in
            parts.contains(where: { $0 != parts[index] })
        }) {
            pick = firstDistinct
        } else {
            return nil
        }
        var tokens: [Token] = []
        var leading = UUID()
        var trailing = UUID()
        for (index, part) in parts.enumerated() {
            let token = Token(text: part)
            tokens.append(token)
            if index == pick {
                leading = token.id
                let twin = Token(text: part)
                trailing = twin.id
                tokens.append(twin)
            }
        }
        return Line(
            workID: workID,
            field: field,
            tokens: tokens,
            twinLeadingID: leading,
            twinTrailingID: trailing
        )
    }

    mutating func cool(_ tokenID: UUID) {
        tokens = tokens.map { token in
            var next = token
            if next.id == tokenID { next.isCooled = true }
            return next
        }
    }

    mutating func reheat(_ tokenID: UUID) {
        tokens = tokens.map { token in
            var next = token
            if next.id == tokenID { next.isCooled = false }
            return next
        }
    }
}
