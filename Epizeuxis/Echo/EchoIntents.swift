import AppIntents
import Foundation

struct OpenQuizIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Quiz"
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run { EchoGate.router?.open(.quiz) }
        return .result()
    }
}

struct OpenExploreIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Explore"
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run { EchoGate.router?.open(.explore) }
        return .result()
    }
}

struct OpenSavedIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Saved"
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run { EchoGate.router?.open(.saved) }
        return .result()
    }
}

struct OpenSettingsIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Settings"
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run { EchoGate.router?.open(.settings) }
        return .result()
    }
}

struct EchoLineIntent: AppIntent {
    static let title: LocalizedStringResource = "Echo a line"
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run { EchoGate.router?.open(.echoLine) }
        return .result()
    }
}

struct ElideTokenIntent: AppIntent {
    static let title: LocalizedStringResource = "Elide the twin"
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run { EchoGate.router?.open(.elideToken) }
        return .result()
    }
}

struct EchoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: EchoLineIntent(),
            phrases: ["Echo a line in \(.applicationName)"],
            shortTitle: "Echo",
            systemImageName: "text.badge.plus"
        )
        AppShortcut(
            intent: ElideTokenIntent(),
            phrases: ["Elide the twin in \(.applicationName)"],
            shortTitle: "Elide",
            systemImageName: "eraser"
        )
    }
}
