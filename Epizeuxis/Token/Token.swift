import Foundation

/// One tappable word on the doubled Line.
struct Token: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: UUID
    let text: String
    var isCooled: Bool

    init(id: UUID = UUID(), text: String, isCooled: Bool = false) {
        self.id = id
        self.text = text
        self.isCooled = isCooled
    }
}
