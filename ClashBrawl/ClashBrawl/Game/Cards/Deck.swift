import Foundation

/// Runtime deck used during a match.
/// Wraps the persistent Deck and provides shuffle/draw mechanics.
final class GameDeck {
    private var cards: [CardData]
    private var drawPile: [CardData]
    private var hand: [CardData]
    private var discardPile: [CardData]

    init(deck: Deck) {
        self.cards = deck.cards
        self.drawPile = []
        self.hand = []
        self.discardPile = []
        reset()
    }

    func reset() {
        drawPile = cards.shuffled()
        hand = []
        discardPile = []
        drawInitialHand()
    }

    private func drawInitialHand(count: Int = 4) {
        for _ in 0..<count {
            drawCard()
        }
    }

    @discardableResult
    func drawCard() -> CardData? {
        guard drawPile.isEmpty == false else {
            reshuffleDiscardIntoDraw()
            return nil
        }
        let card = drawPile.removeFirst()
        hand.append(card)
        return card
    }

    func playCard(_ card: CardData) -> Bool {
        guard let index = hand.firstIndex(where: { $0.id == card.id }) else { return false }
        let removed = hand.remove(at: index)
        discardPile.append(removed)
        drawCard()
        return true
    }

    func replaceCard(_ card: CardData) -> CardData? {
        guard let index = hand.firstIndex(where: { $0.id == card.id }) else { return nil }
        let removed = hand.remove(at: index)
        discardPile.append(removed)
        return drawCard()
    }

    func currentHand() -> [CardData] { hand }

    private func reshuffleDiscardIntoDraw() {
        drawPile.append(contentsOf: discardPile.shuffled())
        discardPile.removeAll()
    }
}
