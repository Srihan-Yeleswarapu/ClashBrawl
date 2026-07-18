import Foundation
import SwiftUI

// MARK: - Type Aliases
typealias GameID = String
typealias PlayerID = String
typealias CardID = String
typealias UnitID = String
typealias HeroID = String

// MARK: - Rarity
enum Rarity: String, Codable, CaseIterable {
    case common = "Common"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"

    var color: Color {
        switch self {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
}

// MARK: - Team
enum Team: Int, Codable, CaseIterable {
    case blue = 0
    case red = 1

    var color: Color {
        switch self {
        case .blue: return .blue
        case .red: return .red
        }
    }
}

// MARK: - Target Type
enum TargetType: String, Codable {
    case ground
    case air
    case groundAndAir = "ground_and_air"
}

// MARK: - Helpers
extension CGFloat {
    static func lerp(from: CGFloat, to: CGFloat, t: CGFloat) -> CGFloat {
        return from + (to - from) * t
    }
}

extension TimeInterval {
    static func clamped(_ value: TimeInterval, min: TimeInterval, max: TimeInterval) -> TimeInterval {
        return Swift.max(min, Swift.min(max, value))
    }
}
