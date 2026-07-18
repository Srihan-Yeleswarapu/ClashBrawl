import Foundation
import SwiftUI

/// Top-level observable game state shared across the app.
@Observable
final class GameState {
    var profile: PlayerProfile
    var settings: GameSettings
    var currentScreen: AppScreen = .mainMenu
    var isInMatch: Bool = false

    init(profile: PlayerProfile = SaveManager.shared.loadOrCreateProfile(),
         settings: GameSettings = SaveManager.shared.loadSettings()) {
        self.profile = profile
        self.settings = settings
    }

    func save() {
        SaveManager.shared.save(profile: profile)
        SaveManager.shared.save(settings: settings)
    }

    func navigate(to screen: AppScreen) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentScreen = screen
        }
    }
}

enum AppScreen: String, Identifiable {
    case mainMenu
    case deckSelection
    case matchmaking
    case battle
    case progression
    case settings

    var id: String { rawValue }
}
