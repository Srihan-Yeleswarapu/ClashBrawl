import Foundation

/// Represents the result of a network operation.
enum NetworkResult<T> {
    case success(T)
    case failure(NetworkError)
}

/// Errors that can occur during network communication.
enum NetworkError: Error {
    case invalidURL
    case noConnection
    case unauthorized
    case serverError(Int)
    case decodingError
    case timeout
    case unknown
}

/// Protocol defining all backend interactions.
/// Implement this for Oracle Cloud or any other backend.
protocol NetworkService {
    func findMatch(playerID: PlayerID, completion: @escaping (NetworkResult<MatchFoundResponse>) -> Void)
    func fetchPlayerProfile(playerID: PlayerID, completion: @escaping (NetworkResult<PlayerProfile>) -> Void)
    func saveDeck(deck: Deck, playerID: PlayerID, completion: @escaping (NetworkResult<Deck>) -> Void)
    func sendMatchAction(_ action: MatchAction, completion: @escaping (NetworkResult<Void>) -> Void)
    func connectToMatchSocket(matchID: GameID, playerID: PlayerID, delegate: MatchSocketDelegate?)
    func disconnectFromMatchSocket()
}

/// Delegate for real-time match socket events.
protocol MatchSocketDelegate: AnyObject {
    func didReceiveMatchEvent(_ event: MatchEvent)
    func didDisconnect(error: NetworkError?)
}

/// Response from matchmaking.
struct MatchFoundResponse: Codable {
    let matchID: GameID
    let opponentName: String
    let opponentTrophies: Int
    let mapName: String
    let team: Team.RawValue
}

/// An action sent during a match (deploy card, move hero, use ability).
struct MatchAction: Codable {
    let matchID: GameID
    let playerID: PlayerID
    let type: MatchActionType
    let cardID: CardID?
    let position: CGPoint?
    let timestamp: TimeInterval
}

enum MatchActionType: String, Codable {
    case deployCard
    case moveHero
    case useAbility
    case emote
}

/// An event received from the server during a match.
struct MatchEvent: Codable {
    let type: MatchEventType
    let payload: Data?
    let timestamp: TimeInterval
}

enum MatchEventType: String, Codable {
    case stateUpdate
    case opponentAction
    case matchStarted
    case matchEnded
    case error
}

/// Central manager that routes network calls to the active service.
final class NetworkManager {
    static let shared = NetworkManager()

    private var service: NetworkService

    init(service: NetworkService = MockNetworkService()) {
        self.service = service
    }

    func setService(_ service: NetworkService) {
        self.service = service
    }

    // MARK: - Proxy Methods
    func findMatch(playerID: PlayerID, completion: @escaping (NetworkResult<MatchFoundResponse>) -> Void) {
        service.findMatch(playerID: playerID, completion: completion)
    }

    func fetchPlayerProfile(playerID: PlayerID, completion: @escaping (NetworkResult<PlayerProfile>) -> Void) {
        service.fetchPlayerProfile(playerID: playerID, completion: completion)
    }

    func saveDeck(deck: Deck, playerID: PlayerID, completion: @escaping (NetworkResult<Deck>) -> Void) {
        service.saveDeck(deck: deck, playerID: playerID, completion: completion)
    }

    func sendMatchAction(_ action: MatchAction, completion: @escaping (NetworkResult<Void>) -> Void) {
        service.sendMatchAction(action, completion: completion)
    }

    func connectToMatchSocket(matchID: GameID, playerID: PlayerID, delegate: MatchSocketDelegate?) {
        service.connectToMatchSocket(matchID: matchID, playerID: playerID, delegate: delegate)
    }

    func disconnectFromMatchSocket() {
        service.disconnectFromMatchSocket()
    }
}
