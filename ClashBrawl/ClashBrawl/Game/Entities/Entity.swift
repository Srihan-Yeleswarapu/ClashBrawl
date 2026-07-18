import Foundation
import SwiftUI

/// Unique identifier for any in-game entity.
typealias EntityID = UUID

/// Represents a position, velocity, and team in the battle arena.
final class Entity: Identifiable, ObservableObject {
    let id: EntityID
    let team: Team
    var position: CGPoint
    var velocity: CGVector
    var health: Double
    var maxHealth: Double
    var isAlive: Bool { health > 0 }
    var targetID: EntityID?
    var attackTimer: TimeInterval = 0
    var abilityTimer: TimeInterval = 0
    var isStunned: TimeInterval = 0
    var isFlying: Bool = false
    var speedMultiplier: CGFloat = 1.0

    init(team: Team, position: CGPoint, health: Double) {
        self.id = EntityID()
        self.team = team
        self.position = position
        self.velocity = .zero
        self.health = health
        self.maxHealth = health
    }

    func takeDamage(_ amount: Double) {
        health = max(0, health - amount)
    }

    func heal(_ amount: Double) {
        health = min(maxHealth, health + amount)
    }

    func distance(to other: Entity) -> CGFloat {
        let dx = position.x - other.position.x
        let dy = position.y - other.position.y
        return sqrt(dx * dx + dy * dy)
    }

    func direction(to other: Entity) -> CGVector {
        let dx = other.position.x - position.x
        let dy = other.position.y - position.y
        let len = sqrt(dx * dx + dy * dy)
        guard len > 0 else { return .zero }
        return CGVector(dx: dx / len, dy: dy / len)
    }
}

/// A unit entity with stats from UnitData.
final class UnitEntity: Entity {
    let unitData: UnitData
    var level: Int

    init(team: Team, position: CGPoint, unitData: UnitData, level: Int = 1) {
        self.unitData = unitData
        self.level = level
        let scaledHealth = unitData.hitpoints * (1.0 + Double(level - 1) * 0.1)
        super.init(team: team, position: position, health: scaledHealth)
        self.isFlying = unitData.canFly
    }
}

/// A hero entity with stats from HeroData.
final class HeroEntity: Entity {
    let heroData: HeroData
    var level: Int
    var abilityReady: Bool = true

    init(team: Team, position: CGPoint, heroData: HeroData, level: Int = 1) {
        self.heroData = heroData
        self.level = level
        let scaledHealth = heroData.baseHitpoints * (1.0 + Double(level - 1) * 0.1)
        super.init(team: team, position: position, health: scaledHealth)
    }
}

/// A projectile fired by a ranged unit or ability.
final class Projectile: Identifiable {
    let id: EntityID
    let team: Team
    var position: CGPoint
    var direction: CGVector
    let speed: CGFloat
    let damage: Double
    let targetID: EntityID?
    let radius: CGFloat
    let isHoming: Bool

    init(team: Team, position: CGPoint, direction: CGVector, speed: CGFloat, damage: Double, targetID: EntityID? = nil, radius: CGFloat = 8, isHoming: Bool = false) {
        self.id = EntityID()
        self.team = team
        self.position = position
        self.direction = direction
        self.speed = speed
        self.damage = damage
        self.targetID = targetID
        self.radius = radius
        self.isHoming = isHoming
    }
}
