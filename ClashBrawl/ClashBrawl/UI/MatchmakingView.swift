import SwiftUI

struct MatchmakingView: View {
    @Bindable var gameState: GameState
    @State private var isSearching = false
    @State private var statusText = "Finding opponent..."
    @State private var matchFound = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Text("MATCHMAKING")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 8)
                        .frame(width: 160, height: 160)

                    Circle()
                        .trim(from: 0, to: 0.3)
                        .stroke(
                            LinearGradient(colors: [.orange, .red]),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(isSearching ? 360 : 0))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isSearching)

                    Image(systemName: "bolt.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                }

                Text(statusText)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .animation(.easeInOut, value: statusText)

                Spacer()

                Button(action: {
                    if matchFound {
                        startMatch()
                    } else {
                        cancelMatchmaking()
                    }
                }) {
                    Text(matchFound ? "Enter Battle" : "Cancel")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 32)
            }
        }
        .onAppear { startSearch() }
        .onDisappear { isSearching = false }
    }

    private func startSearch() {
        isSearching = true
        statusText = "Finding opponent..."
        matchFound = false

        NetworkManager.shared.findMatch(playerID: gameState.profile.id) { result in
            switch result {
            case .success(let response):
                statusText = "Opponent found: \(response.opponentName)"
                matchFound = true
                isSearching = false
                // Auto-enter after short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    startMatch()
                }
            case .failure(let error):
                statusText = "Matchmaking failed: \(error)"
                isSearching = false
            }
        }
    }

    private func cancelMatchmaking() {
        isSearching = false
        gameState.navigate(to: .mainMenu)
    }

    private func startMatch() {
        gameState.navigate(to: .battle)
    }
}

#Preview {
    MatchmakingView(gameState: GameState())
}
