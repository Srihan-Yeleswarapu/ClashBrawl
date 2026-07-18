import Foundation

/// Oracle Cloud backend configuration.
/// Replace the placeholder values below with your actual Oracle Cloud details
/// before attempting to connect to a live backend.
///
/// To obtain values:
/// 1. Create an compute instance in your Oracle Cloud Free Tier account.
/// 2. Note the public IP or hostname, region, and any API key/token.
/// 3. Update the constants in this file or set them via build settings / environment.
enum OracleConfig {
    // MARK: - Server Base URL
    /// Example: "https://123.45.67.89" or "https://your-instance.oraclecloud.com"
    static let serverBaseURL: String = "https://YOUR_ORACLE_SERVER_IP_OR_HOST"

    // MARK: - API Key / Token
    /// Authentication token or API key issued by your Oracle backend.
    static let apiKey: String = "YOUR_ORACLE_API_KEY_OR_TOKEN"

    // MARK: - Region / Host
    /// Oracle Cloud region identifier, e.g., "us-ashburn-1".
    static let region: String = "YOUR_ORACLE_REGION"

    // MARK: - Endpoints
    /// REST endpoint prefix. The full URL will be constructed as:
    /// serverBaseURL + restEndpointPrefix + route
    static let restEndpointPrefix: String = "/api/v1"

    /// WebSocket endpoint prefix for real-time match communication.
    static let socketEndpointPrefix: String = "/ws/v1"

    // MARK: - Matchmaking
    static let matchmakingEndpoint: String = "/matchmaking/find"
    static let matchStatusEndpoint: String = "/matchmaking/status"

    // MARK: - Player / Progression
    static let playerProfileEndpoint: String = "/player/profile"
    static let playerProgressionEndpoint: String = "/player/progression"
    static let deckSaveEndpoint: String = "/player/deck"

    // MARK: - Derived URLs (do not edit directly)
    static var baseRestURL: String { serverBaseURL + restEndpointPrefix }
    static var baseSocketURL: String {
        // Convert http -> ws, https -> wss
        let scheme = serverBaseURL.hasPrefix("https") ? "wss" : "ws"
        let host = serverBaseURL.replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
        return "\(scheme)://\(host)\(socketEndpointPrefix)"
    }
}
