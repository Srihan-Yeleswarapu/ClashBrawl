import SwiftUI

struct SettingsView: View {
    @Bindable var gameState: GameState

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Button(action: { gameState.navigate(to: .mainMenu) }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Settings")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 16) {
                    Toggle("Use Mock Backend (Offline)", isOn: $gameState.settings.useMockBackend)
                        .foregroundColor(.white)
                        .onChange(of: gameState.settings.useMockBackend) { _, newValue in
                            if newValue {
                                NetworkManager.shared.setService(MockNetworkService())
                            } else {
                                NetworkManager.shared.setService(OracleNetworkService())
                            }
                            gameState.save()
                        }

                    Toggle("Haptic Feedback", isOn: $gameState.settings.hapticEnabled)
                        .foregroundColor(.white)

                    VStack(alignment: .leading) {
                        Text("Music Volume")
                            .foregroundColor(.white)
                        Slider(value: $gameState.settings.musicVolume, in: 0...1)
                    }

                    VStack(alignment: .leading) {
                        Text("SFX Volume")
                            .foregroundColor(.white)
                        Slider(value: $gameState.settings.sfxVolume, in: 0...1)
                    }
                }
                .padding()
                .cardStyle(color: .gray)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Oracle Backend Configuration")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Edit ClashBrawl/Config/OracleConfig.swift to set your Oracle Cloud server details.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Base URL: \(OracleConfig.serverBaseURL)")
                        Text("Region: \(OracleConfig.region)")
                        Text("API Key: \(maskedAPIKey)")
                    }
                    .font(.caption2)
                    .foregroundColor(.cyan)
                }
                .padding()
                .cardStyle(color: .cyan)
                .padding(.horizontal)

                Spacer()
            }
        }
    }

    private var maskedAPIKey: String {
        let key = OracleConfig.apiKey
        guard key.count > 4 else { return "****" }
        return String(key.prefix(2)) + String(repeating: "*", count: key.count - 4) + String(key.suffix(2))
    }
}

#Preview {
    SettingsView(gameState: GameState())
}
