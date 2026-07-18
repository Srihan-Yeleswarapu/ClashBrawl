import Foundation

/// Network service implementation for an Oracle Cloud Free Tier backend.
///
/// Replace the placeholders in `OracleConfig.swift` with your actual Oracle server details.
/// This class uses URLSession for REST and URLSessionWebSocketTask for real-time sockets.
final class OracleNetworkService: NetworkService {
    private var socketTask: URLSessionWebSocketTask?
    private var socketDelegate: MatchSocketDelegate?

    // MARK: - Matchmaking
    func findMatch(playerID: PlayerID, completion: @escaping (NetworkResult<MatchFoundResponse>) -> Void) {
        let urlString = OracleConfig.baseRestURL + OracleConfig.matchmakingEndpoint
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(OracleConfig.apiKey, forHTTPHeaderField: "X-API-Key")

        let body = ["player_id": playerID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[Oracle] findMatch error: \(error)")
                completion(.failure(.noConnection))
                return
            }
            guard let data = data else {
                completion(.failure(.unknown))
                return
            }
            do {
                let match = try JSONDecoder().decode(MatchFoundResponse.self, from: data)
                completion(.success(match))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }

    // MARK: - Player Profile
    func fetchPlayerProfile(playerID: PlayerID, completion: @escaping (NetworkResult<PlayerProfile>) -> Void) {
        let urlString = OracleConfig.baseRestURL + OracleConfig.playerProfileEndpoint + "/" + playerID
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(OracleConfig.apiKey, forHTTPHeaderField: "X-API-Key")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[Oracle] fetchPlayerProfile error: \(error)")
                completion(.failure(.noConnection))
                return
            }
            guard let data = data else {
                completion(.failure(.unknown))
                return
            }
            do {
                let profile = try JSONDecoder().decode(PlayerProfile.self, from: data)
                completion(.success(profile))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }

    // MARK: - Deck Save
    func saveDeck(deck: Deck, playerID: PlayerID, completion: @escaping (NetworkResult<Deck>) -> Void) {
        let urlString = OracleConfig.baseRestURL + OracleConfig.deckSaveEndpoint
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(OracleConfig.apiKey, forHTTPHeaderField: "X-API-Key")

        struct DeckSaveBody: Codable {
            let player_id: PlayerID
            let deck: Deck
        }
        let body = DeckSaveBody(player_id: playerID, deck: deck)
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[Oracle] saveDeck error: \(error)")
                completion(.failure(.noConnection))
                return
            }
            completion(.success(deck))
        }.resume()
    }

    // MARK: - Match Actions
    func sendMatchAction(_ action: MatchAction, completion: @escaping (NetworkResult<Void>) -> Void) {
        let urlString = OracleConfig.baseRestURL + "/match/" + action.matchID + "/action"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(OracleConfig.apiKey, forHTTPHeaderField: "X-API-Key")
        request.httpBody = try? JSONEncoder().encode(action)

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("[Oracle] sendMatchAction error: \(error)")
                completion(.failure(.noConnection))
                return
            }
            completion(.success(()))
        }.resume()
    }

    // MARK: - WebSocket
    func connectToMatchSocket(matchID: GameID, playerID: PlayerID, delegate: MatchSocketDelegate?) {
        let urlString = OracleConfig.baseSocketURL + "/match/" + matchID + "/player/" + playerID
        guard let url = URL(string: urlString) else {
            delegate?.didDisconnect(error: .invalidURL)
            return
        }

        socketDelegate = delegate
        var request = URLRequest(url: url)
        request.setValue(OracleConfig.apiKey, forHTTPHeaderField: "X-API-Key")

        socketTask = URLSession.shared.webSocketTask(with: request)
        socketTask?.resume()
        listenForMessages()
    }

    func disconnectFromMatchSocket() {
        socketTask?.cancel(with: .normalClosure, reason: nil)
        socketTask = nil
        socketDelegate = nil
    }

    private func listenForMessages() {
        socketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("[Oracle] socket error: \(error)")
                self?.socketDelegate?.didDisconnect(error: .unknown)
            case .success(let message):
                if case .string(let text) = message,
                   let data = text.data(using: .utf8),
                   let event = try? JSONDecoder().decode(MatchEvent.self, from: data) {
                    self?.socketDelegate?.didReceiveMatchEvent(event)
                }
                self?.listenForMessages()
            }
        }
    }
}
