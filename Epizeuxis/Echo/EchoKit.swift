import SwiftUI
import UIKit

/// Colour, type, space, and radius live behind one accessor each.
enum EchoColor {
    /// Screen background #FAF7F5
    static let background = Color("epzBackground")
    /// Cards and rows #FEFEFD
    static let surface = Color("epzSurface")
    /// Primary text #392818
    static let ink = Color("epzInk")
    /// Primary action #CC6D19
    static let accent = Color("epzAccent")
    /// Secondary text #816C5A
    static let muted = Color("epzMuted")
}

enum EchoType {
    static let display = Font.system(.title2, design: .default).weight(.bold)
    static let title = Font.system(.title3, design: .default).weight(.semibold)
    static let headline = Font.system(.headline, design: .default)
    static let body = Font.system(.body, design: .default)
    static let caption = Font.system(.subheadline, design: .default).weight(.medium)
    static let micro = Font.system(.footnote, design: .default)

    static func display(for size: DynamicTypeSize) -> Font {
        if size >= .accessibility3 {
            return title
        }
        return Font.system(.title2, design: .default).weight(.bold)
    }

    static func elide(for size: DynamicTypeSize) -> Font {
        if size >= .accessibility3 {
            return body
        }
        return headline
    }
}

enum EchoSpace {
    static let unit: CGFloat = 8
    static let tight: CGFloat = 4
    static let small: CGFloat = 8
    static let item: CGFloat = 16
    static let section: CGFloat = 24
    static let block: CGFloat = 32
}

enum EchoRadius {
    static let card: CGFloat = 20
    static let small: CGFloat = 12
}

/// One soft drop shadow. Only the quiz photo-tile uses it.
enum EchoShadow {
    static let radius: CGFloat = 16
    static let y: CGFloat = 8
    static let color = EchoColor.ink.opacity(0.16)
}

enum EchoMotion {
    static let pressDuration: Double = 0.16
    static let sheetDuration: Double = 0.2

    static func pressAnimation(reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: pressDuration)
    }

    static func sheetAnimation(reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: sheetDuration)
    }
}

enum EchoFigure {
    static func countText(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }

    static func daykeyText(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
}

enum EchoHaptic {
    @MainActor
    static func elideSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
