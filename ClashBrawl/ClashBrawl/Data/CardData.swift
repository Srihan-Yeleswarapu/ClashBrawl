import Foundation
import SwiftUI

/// Represents a playable card in the player's deck.
struct CardData: Identifiable, Codable, Hashable {
    let id: CardID
    let name: String
    let description: String
    let rarity: Rarity
    let elixirCost: Int
    let unitID: UnitID?      // If the card spawns a unit
    let heroID: HeroID?      // If the card deploys a hero ability
    let spellDamage: Double? // If the card is a spell
    let spellRadius: CGFloat? // If the card is a spell
    let targetTags: [String]
    let unlockArena: Int
    let iconName: String     // Asset catalog image name (placeholder)

    static func == (lhs: CardData, rhs: CardData) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Card Database
extension CardData {
    static let allCards: [CardData] = [
        CardData(id: "c001", name: "Brawler", description: "Tough melee fighter.",
                 rarity: .common, elixirCost: 3, unitID: "u001", heroID: nil,
                 spellDamage: nil, spellRadius: nil, targetTags: ["ground"], unlockArena: 0, iconName: "card_brawler"),
        CardData(id: "c002", name: "Sharpshooter", description: "Ranged attacker with high damage.",
                 rarity: .common, elixirCost: 3, unitID: "u002", heroID: nil,
                 spellDamage: nil, spellRadius: nil, targetTags: ["ground"], unlockArena: 0, iconName: "card_sharpshooter"),
        CardData(id: "c003", name: "Tank", description: "Slow but very durable.",
                 rarity: .rare, elixirCost: 5, unitID: "u003", heroID: nil,
                 spellDamage: nil, spellRadius: nil, targetTags: ["ground"], unlockArena: 1, iconName: "card_tank"),
        CardData(id: "c004", name: "Sky Drone", description: "Flying unit, only targets ground.",
                 rarity: .rare, elixirCost: 4, unitID: "u004", heroID: nil,
                 spellDamage: nil, spellRadius: nil, targetTags: ["air"], unlockArena: 2, iconName: "card_drone"),
        CardData(id: "c005", name: "Heal Wave", description: "Restores health to nearby allies.",
                 rarity: .epic, elixirCost: 4, unitID: nil, heroID: nil,
                 spellDamage: -150, spellRadius: 120, targetTags: ["spell"], unlockArena: 3, iconName: "card_heal"),
        CardData(id: "c006", name: "Rocket Strike", description: "Deals heavy area damage.",
                 rarity: .epic, elixirCost: 6, unitID: nil, heroID: nil,
                 spellDamage: 400, spellRadius: 150, targetTags: ["spell"], unlockArena: 4, iconName: "card_rocket"),
        CardData(id: "c007", name: "Heroic Dash", description: "Hero dashes forward, damaging enemies.",
                 rarity: .legendary, elixirCost: 2, unitID: nil, heroID: "h001",
                 spellDamage: 200, spellRadius: 80, targetTags: ["hero_ability"], unlockArena: 5, iconName: "card_hero_dash"),
        CardData(id: "c008", name: "Mini Swarm", description: "Deploys three small minions.",
                 rarity: .common, elixirCost: 2, unitID: "u005", heroID: nil,
                 spellDamage: nil, spellRadius: nil, targetTags: ["ground"], unlockArena: 0, iconName: "card_swarm")
    ]

    static func card(by id: CardID) -> CardData? {
        allCards.first { $0.id == id }
    }
}
