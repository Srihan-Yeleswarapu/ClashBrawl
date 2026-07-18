import SwiftUI

struct ProgressionView: View {
    @Bindable var gameState: GameState

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    header

                    // Profile card
                    VStack(spacing: 12) {
                        Text(gameState.profile.username)
                            .font(.title.bold())
                            .foregroundColor(.white)

                        HStack(spacing: 16) {
                            StatBadge(title: "Level", value: "\(gameState.profile.level)", color: .blue)
                            StatBadge(title: "Trophies", value: "\(gameState.profile.trophies)", color: .yellow)
                            StatBadge(title: "XP", value: "\(gameState.profile.xp)", color: .green)
                        }
                    }
                    .padding()
                    .cardStyle(color: .purple)

                    // Resources
                    HStack(spacing: 16) {
                        ResourceBadge(name: "Gold", amount: gameState.profile.gold, color: .yellow, icon: "dollarsign.circle.fill")
                        ResourceBadge(name: "Gems", amount: gameState.profile.gems, color: .cyan, icon: "diamond.fill")
                    }
                    .padding(.horizontal)

                    // Match stats
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Battle Record")
                            .font(.headline)
                            .foregroundColor(.white)
                        HStack {
                            StatBadge(title: "Played", value: "\(gameState.profile.matchesPlayed)", color: .gray)
                            StatBadge(title: "Won", value: "\(gameState.profile.matchesWon)", color: .green)
                            StatBadge(title: "Win Rate", value: winRate, color: .orange)
                        }
                    }
                    .padding()
                    .cardStyle(color: .blue)

                    // Unlocks
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Unlocked Cards")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("\(gameState.profile.unlockedCardIDs.count) / \(CardData.allCards.count)")
                            .foregroundColor(.white.opacity(0.7))
                        ProgressView(value: Double(gameState.profile.unlockedCardIDs.count), total: Double(CardData.allCards.count))
                            .tint(.green)
                    }
                    .padding()
                    .cardStyle(color: .green)

                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
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
            Text("Progression")
                .font(.title2.bold())
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal)
    }

    private var winRate: String {
        guard gameState.profile.matchesPlayed > 0 else { return "0%" }
        let rate = Double(gameState.profile.matchesWon) / Double(gameState.profile.matchesPlayed) * 100
        return String(format: "%.0f%%", rate)
    }
}

struct StatBadge: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
            Text(title)
                .font(.caption)
        }
        .foregroundColor(.white)
        .frame(minWidth: 70)
        .padding(.vertical, 8)
        .background(color.opacity(0.2))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color, lineWidth: 1))
    }
}

struct ResourceBadge: View {
    let name: String
    let amount: Int
    let color: Color
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            VStack(alignment: .leading) {
                Text(name)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                Text("\(amount)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding()
        .background(color.opacity(0.15))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color, lineWidth: 1))
    }
}

#Preview {
    ProgressionView(gameState: GameState())
}
