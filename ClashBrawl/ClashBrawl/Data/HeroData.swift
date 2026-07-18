import Foundation

/// Represents a playable hero with an ultimate ability and upgrade levels.
struct HeroData: Identifiable, Codable, Hashable {
    let id: HeroID
    let name: String
    let description: String
    let baseHitpoints: Double
    let baseDamage: Double
    let movementSpeed: CGFloat
    let range: CGFloat
    let abilityName: String
    let abilityDescription: String
    let abilityCooldown: TimeInterval
    let unlockArena: Int
    let iconName: String

    static func == (lhs: HeroData, rhs: HeroData) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension HeroData {
    static let allHeroes: [HeroData] = [
        HeroData(id: "h001", name: "Kael", description: "A swift duelist who leads from the front.",
                 baseHitpoints: 1600, baseDamage: 180, movementSpeed: 190, range: 80,
                 abilityName: "Heroic Dash", abilityDescription: "Dash forward, damaging enemies in path.",
                 abilityCooldown: 8.0, unlockArena: 0, iconName: "hero_kael"),
        HeroData(id: "h002", name: "Mira", description: "Tactical support hero who buffs nearby allies.",
                 baseHitpoints: 1400, baseDamage: 120, movementSpeed: 170, range: 260,
                 abilityName: "Inspire", abilityDescription: "Boosts attack speed of nearby allies.",
                 abilityCooldown: 12.0, unlockArena: 2, iconName: "hero_mira"),
        HeroData(id: "h003", name: "Brutus", description: "Heavy bruiser with a devastating slam.",
                 baseHitpoints: 2400, baseDamage: 200, movementSpeed: 140, range: 90,
                 abilityName: "Ground Slam", abilityDescription: "Stuns and damages nearby enemies.",
                 abilityCooldown: 15.0, unlockArena: 4, iconName: "hero_brutus")
    ]

    static func hero(by id: HeroID) -> HeroData? {
        allHeroes.first { $0.id == id }
    }
}
