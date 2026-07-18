import Foundation

/// Handles local persistence of player profile and settings.
/// Uses UserDefaults for simplicity; can be swapped for SwiftData or a file-based store.
final class SaveManager {
    static let shared = SaveManager()

    private let defaults = UserDefaults.standard
    private let profileKey = "com.clashbrawl.playerProfile"
    private let settingsKey = "com.clashbrawl.settings"

    private init() {}

    func save(profile: PlayerProfile) {
        do {
            let data = try JSONEncoder().encode(profile)
            defaults.set(data, forKey: profileKey)
        } catch {
            print("[SaveManager] Failed to encode profile: \(error)")
        }
    }

    func loadProfile() -> PlayerProfile? {
        guard let data = defaults.data(forKey: profileKey) else { return nil }
        do {
            return try JSONDecoder().decode(PlayerProfile.self, from: data)
        } catch {
            print("[SaveManager] Failed to decode profile: \(error)")
            return nil
        }
    }

    func loadOrCreateProfile(username: String = "Brawler") -> PlayerProfile {
        if let profile = loadProfile() {
            return profile
        }
        let profile = PlayerProfile.new(username: username)
        save(profile: profile)
        return profile
    }

    func resetProfile() {
        defaults.removeObject(forKey: profileKey)
    }

    // MARK: - Settings
    func save(settings: GameSettings) {
        do {
            let data = try JSONEncoder().encode(settings)
            defaults.set(data, forKey: settingsKey)
        } catch {
            print("[SaveManager] Failed to encode settings: \(error)")
        }
    }

    func loadSettings() -> GameSettings {
        guard let data = defaults.data(forKey: settingsKey) else { return GameSettings() }
        do {
            return try JSONDecoder().decode(GameSettings.self, from: data)
        } catch {
            return GameSettings()
        }
    }
}

/// Simple settings container.
struct GameSettings: Codable {
    var musicVolume: Double = 0.7
    var sfxVolume: Double = 0.8
    var hapticEnabled: Bool = true
    var useMockBackend: Bool = true
}
