import Foundation

/// Mock network service for offline development and testing.
/// Simulates latency and returns deterministic fake responses.
final class MockNetworkService: NetworkService {
    private var socketTimer: Timer?
    private var socketDelegate: MatchSocketDelegate?
    private var currentMatchID: GameID?

    // MARK: - Matchmaking
    func findMatch(playerID: PlayerID, completion: @escaping (NetworkResult<MatchFoundResponse>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + simulatedLatency()) {
            let response = MatchFoundResponse(
                matchID: UUID().uuidString,
                opponentName: "Bot_" + String(format: "%04d", Int.random(in: 1000...9999)),
                opponentTrophies: Int.random(in: 0...4000),
                mapName: "Neon Arena",
                team: Team.blue.rawValue
            )
            DispatchQueue.main.async { completion(.success(response)) }
        }
    }

    // MARK: - Player Profile
    func fetchPlayerProfile(playerID: PlayerID, completion: @escaping (NetworkResult<PlayerProfile>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + simulatedLatency()) {
            let profile = SaveManager.shared.loadOrCreateProfile(username: "Player")
            DispatchQueue.main.async { completion(.success(profile)) }
        }
    }

    // MARK: - Deck Save
    func saveDeck(deck: Deck, playerID: PlayerID, completion: @escaping (NetworkResult<Deck>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + simulatedLatency()) {
            DispatchQueue.main.async { completion(.success(deck)) }
        }
    }

    // MARK: - Match Actions
    func sendMatchAction(_ action: MatchAction, completion: @escaping (NetworkResult<Void>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + simulatedLatency()) {
            DispatchQueue.main.async { completion(.success(())) }
        }
    }

    // MARK: - WebSocket Simulation
    func connectToMatchSocket(matchID: GameID, playerID: PlayerID, delegate: MatchSocketDelegate?) {
        currentMatchID = matchID
        socketDelegate = delegate

        // Simulate match start event
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            let event = MatchEvent(type: .matchStarted, payload: nil, timestamp: Date().timeIntervalSince1970)
            self?.socketDelegate?.didReceiveMatchEvent(event)
        }

        // Simulate periodic state updates
        socketTimer?.invalidate()
        socketTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            let event = MatchEvent(type: .stateUpdate, payload: nil, timestamp: Date().timeIntervalSince1970)
            self?.socketDelegate?.didReceiveMatchEvent(event)
        }
    }

    func disconnectFromMatchSocket() {
        socketTimer?.invalidate()
        socketTimer = nil
        socketDelegate?.didDisconnect(error: nil)
        socketDelegate = nil
        currentMatchID = nil
    }

    // MARK: - Helpers
    private func simulatedLatency() -> TimeInterval {
        return TimeInterval.random(in: 0.2...0.8)
    }
}
