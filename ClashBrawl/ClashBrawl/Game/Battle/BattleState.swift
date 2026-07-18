import Foundation
import SwiftUI

/// Represents the current phase of a battle.
enum BattlePhase: String, Codable {
    case waiting
    case countdown
    case inProgress
    case overtime
    case finished
}

/// Holds all runtime state for an active battle.
@Observable
final class BattleState {
    var phase: BattlePhase = .waiting
    var elapsedTime: TimeInterval = 0
    var blueTowerHealth: Double = 1.0
    var redTowerHealth: Double = 1.0
    var elixir: Double = GameConfig.maxElixir / 2.0
    var winner: Team?
    var isSuddenDeath: Bool = false

    let localTeam: Team
    let matchID: GameID
    let opponentName: String

    var entityManager = EntityManager()
    var projectiles: [Projectile] = []
    var effects: [VisualEffectEvent] = []

    init(localTeam: Team = .blue, matchID: GameID = UUID().uuidString, opponentName: String = "Opponent") {
        self.localTeam = localTeam
        self.matchID = matchID
        self.opponentName = opponentName
    }

    func start() {
        phase = .countdown
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.phase = .inProgress
        }
    }

    func update(delta: TimeInterval) {
        guard phase == .inProgress || phase == .overtime else { return }

        elapsedTime += delta
        elixir = min(GameConfig.maxElixir, elixir + GameConfig.elixirPerSecond * delta)

        if phase == .inProgress && elapsedTime >= GameConfig.matchDuration {
            phase = .overtime
        }

        if phase == .overtime && elapsedTime >= GameConfig.matchDuration + GameConfig.overtimeDuration {
            finishMatch()
        }

        // Sudden death when a tower is below threshold
        if blueTowerHealth <= GameConfig.suddenDeathHealthThreshold || redTowerHealth <= GameConfig.suddenDeathHealthThreshold {
            isSuddenDeath = true
        }
    }

    func spendElixir(_ amount: Double) -> Bool {
        guard elixir >= amount else { return false }
        elixir -= amount
        return true
    }

    func damageTower(team: Team, amount: Double) {
        if team == .blue {
            blueTowerHealth = max(0, blueTowerHealth - amount)
        } else {
            redTowerHealth = max(0, redTowerHealth - amount)
        }
        if blueTowerHealth <= 0 || redTowerHealth <= 0 {
            finishMatch()
        }
    }

    private func finishMatch() {
        guard phase != .finished else { return }
        phase = .finished
        if blueTowerHealth > redTowerHealth {
            winner = .blue
        } else if redTowerHealth > blueTowerHealth {
            winner = .red
        } else {
            winner = nil // Draw
        }
    }
}

/// Tracks all in-game entities for both teams.
@Observable
final class EntityManager {
    var entities: [Entity] = []

    func add(_ entity: Entity) {
        entities.append(entity)
    }

    func remove(_ entity: Entity) {
        entities.removeAll { $0.id == entity.id }
    }

    func removeDead() {
        entities.removeAll { !$0.isAlive }
    }

    func enemies(of team: Team) -> [Entity] {
        entities.filter { $0.team != team && $0.isAlive }
    }

    func allies(of team: Team) -> [Entity] {
        entities.filter { $0.team == team && $0.isAlive }
    }
}
