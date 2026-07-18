import Foundation

/// Central configuration for game balance, timers, and tuning values.
/// Adjust these to tweak match pacing, elixir generation, unit stats, etc.
enum GameConfig {
    // MARK: - Match
    static let matchDuration: TimeInterval = 180.0
    static let overtimeDuration: TimeInterval = 60.0
    static let suddenDeathHealthThreshold: Double = 0.30

    // MARK: - Elixir / Mana
    static let maxElixir: Double = 10.0
    static let elixirPerSecond: Double = 1.0 / 2.8  // ~0.357 elixir/sec => 10 elixir in 28s
    static let elixirCostScale: Double = 1.0

    // MARK: - Battlefield
    static let arenaWidth: CGFloat = 1000.0
    static let arenaHeight: CGFloat = 1600.0
    static let laneCount: Int = 2

    // MARK: - Physics
    static let physicsTickRate: TimeInterval = 1.0 / 60.0
    static let maxUnitsPerPlayer: Int = 30

    // MARK: - Progression
    static let startingGems: Int = 100
    static let startingGold: Int = 500
    static let xpPerCommonCard: Int = 4
    static let xpPerRareCard: Int = 20
    static let xpPerEpicCard: Int = 100
}
