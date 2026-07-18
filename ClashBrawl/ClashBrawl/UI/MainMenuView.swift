import SwiftUI

struct MainMenuView: View {
    @Bindable var gameState: GameState

    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(colors: [.purple.opacity(0.3), .black, .blue.opacity(0.3)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("CLASH BRAWL")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange, .red],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .shadow(color: .orange.opacity(0.6), radius: 12, x: 0, y: 4)
                    .pulse()

                Text("Battle. Build. Dominate.")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))

                Spacer()

                VStack(spacing: 16) {
                    MenuButton(title: "Battle", icon: "bolt.fill", color: .orange) {
                        gameState.navigate(to: .matchmaking)
                    }

                    MenuButton(title: "Deck", icon: "square.stack.3d.up.fill", color: .blue) {
                        gameState.navigate(to: .deckSelection)
                    }

                    MenuButton(title: "Progression", icon: "trophy.fill", color: .yellow) {
                        gameState.navigate(to: .progression)
                    }

                    MenuButton(title: "Settings", icon: "gearshape.fill", color: .gray) {
                        gameState.navigate(to: .settings)
                    }
                }
                .padding(.horizontal, 32)

                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                    Text("\(gameState.profile.trophies) Trophies")
                        .font(.headline)
                    Spacer()
                    Text("Lv. \(gameState.profile.level)")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Menu Button
struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.title3.bold())
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color, lineWidth: 2)
                    )
            )
            .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(MenuButtonStyle())
    }
}

struct MenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    MainMenuView(gameState: GameState())
}
