import SwiftUI

struct DeckSelectionView: View {
    @Bindable var gameState: GameState
    @State private var selectedDeck: Deck
    @State private var showSaveConfirmation = false

    init(gameState: GameState) {
        self.gameState = gameState
        _selectedDeck = State(initialValue: gameState.profile.selectedDeck() ?? gameState.profile.ownedDecks.first!)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                header

                Text("Average Elixir: \(String(format: "%.1f", selectedDeck.averageElixirCost))")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                // Current deck
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                    ForEach(selectedDeck.cards) { card in
                        CardView(card: card, scale: 1.0)
                            .onTapGesture {
                                removeCard(card)
                            }
                    }
                }
                .padding()

                Divider()
                    .background(Color.white.opacity(0.2))

                // Available cards
                Text("Available Cards")
                    .font(.headline)
                    .foregroundColor(.white)

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                        ForEach(availableCards) { card in
                            CardView(card: card, scale: 1.0)
                                .onTapGesture {
                                    addCard(card)
                                }
                        }
                    }
                    .padding()
                }

                Spacer()
            }
        }
        .alert("Deck Saved", isPresented: $showSaveConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your deck has been updated.")
        }
    }

    private var header: some View {
        HStack {
            Button(action: { gameState.navigate(to: .mainMenu) }) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            Spacer()

            Text("Edit Deck")
                .font(.title2.bold())
                .foregroundColor(.white)

            Spacer()

            Button(action: saveDeck) {
                Text("Save")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }

    private var availableCards: [CardData] {
        CardData.allCards.filter { gameState.profile.unlockedCardIDs.contains($0.id) }
    }

    private func addCard(_ card: CardData) {
        guard selectedDeck.cardIDs.count < 8 else { return }
        guard !selectedDeck.cardIDs.contains(card.id) else { return }
        selectedDeck.cardIDs.append(card.id)
    }

    private func removeCard(_ card: CardData) {
        selectedDeck.cardIDs.removeAll { $0 == card.id }
    }

    private func saveDeck() {
        if let index = gameState.profile.ownedDecks.firstIndex(where: { $0.id == selectedDeck.id }) {
            gameState.profile.ownedDecks[index] = selectedDeck
        } else {
            gameState.profile.ownedDecks.append(selectedDeck)
        }
        gameState.profile.selectedDeckID = selectedDeck.id
        gameState.save()

        NetworkManager.shared.saveDeck(deck: selectedDeck, playerID: gameState.profile.id) { _ in
            showSaveConfirmation = true
        }
    }
}

#Preview {
    DeckSelectionView(gameState: GameState())
}
