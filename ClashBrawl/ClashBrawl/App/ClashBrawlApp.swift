import SwiftUI

@main
struct ClashBrawlApp: App {
    @State private var gameState = GameState()

    var body: some Scene {
        WindowGroup {
            Group {
                switch gameState.currentScreen {
                case .mainMenu:
                    MainMenuView(gameState: gameState)
                        .transition(.opacity)
                case .deckSelection:
                    DeckSelectionView(gameState: gameState)
                        .transition(.move(edge: .trailing))
                case .matchmaking:
                    MatchmakingView(gameState: gameState)
                        .transition(.opacity)
                case .battle:
                    BattleView(gameState: gameState)
                        .transition(.scale)
                case .progression:
                    ProgressionView(gameState: gameState)
                        .transition(.move(edge: .trailing))
                case .settings:
                    SettingsView(gameState: gameState)
                        .transition(.move(edge: .trailing))
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                // Initialize network service based on saved settings
                if gameState.settings.useMockBackend {
                    NetworkManager.shared.setService(MockNetworkService())
                } else {
                    NetworkManager.shared.setService(OracleNetworkService())
                }
            }
        }
    }
}
