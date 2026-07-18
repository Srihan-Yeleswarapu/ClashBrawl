import Foundation

/// Represents the player's persistent profile and progression.
struct PlayerProfile: Codable, Identifiable {
    let id: PlayerID
    var username: String
    var level: Int
    var xp: Int
    var trophies: Int
    var gold: Int
    var gems: Int
    var unlockedCardIDs: [CardID]
    var unlockedHeroIDs: [HeroID]
    var cardLevels: [CardID: Int]
    var heroLevels: [HeroID: Int]
    var selectedHeroID: HeroID
    var selectedDeckID: String
    var ownedDecks: [Deck]
    var arena: Int
    var matchesPlayed: Int
    var matchesWon: Int

    static func new(id: PlayerID = UUID().uuidString, username: String = "Brawler") -> PlayerProfile {
        let starterCards = CardData.allCards.filter { $0.unlockArena == 0 }.map { $0.id }
        let starterHeroes = HeroData.allHeroes.filter { $0.unlockArena == 0 }.map { $0.id }
        let starterDeck = Deck(id: "deck_1", name: "Starter Deck", cardIDs: Array(starterCards.prefix(8)))
        return PlayerProfile(
            id: id,
            username: username,
            level: 1,
            xp: 0,
            trophies: 0,
            gold: GameConfig.startingGold,
            gems: GameConfig.startingGems,
            unlockedCardIDs: starterCards,
            unlockedHeroIDs: starterHeroes,
            cardLevels: [:],
            heroLevels: [:],
            selectedHeroID: starterHeroes.first ?? "h001",
            selectedDeckID: starterDeck.id,
            ownedDecks: [starterDeck],
            arena: 0,
            matchesPlayed: 0,
            matchesWon: 0
        )
    }

    mutating func addXP(_ amount: Int) {
        xp += amount
        let newLevel = (xp / 1000) + 1
        if newLevel > level {
            level = newLevel
        }
    }

    mutating func recordMatch(won: Bool) {
        matchesPlayed += 1
        if won {
            matchesWon += 1
            trophies += 10
        } else {
            trophies = max(0, trophies - 5)
        }
    }

    func selectedDeck() -> Deck? {
        ownedDecks.first { $0.id == selectedDeckID }
    }
}

/// A deck of cards selected by the player.
struct Deck: Codable, Identifiable, Hashable {
    let id: String
    var name: String
    var cardIDs: [CardID]

    var cards: [CardData] {
        cardIDs.compactMap { CardData.card(by: $0) }
    }

    var averageElixirCost: Double {
        let costs = cards.map { Double($0.elixirCost) }
        return costs.isEmpty ? 0 : costs.reduce(0, +) / Double(costs.count)
    }

    static func == (lhs: Deck, rhs: Deck) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
