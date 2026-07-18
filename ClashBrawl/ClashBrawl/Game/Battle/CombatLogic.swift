import Foundation
import SwiftUI

/// Handles all combat simulation for a battle.
final class CombatLogic {
    weak var battleState: BattleState?

    init(battleState: BattleState) {
        self.battleState = battleState
    }

    func update(delta: TimeInterval) {
        guard let state = battleState else { return }

        // Update entities
        for entity in state.entityManager.entities {
            updateEntity(entity, delta: delta, in: state)
        }

        // Update projectiles
        updateProjectiles(delta: delta, in: state)

        // Cleanup
        state.entityManager.removeDead()
    }

    private func updateEntity(_ entity: Entity, delta: TimeInterval, in state: BattleState) {
        if entity.isStunned > 0 {
            entity.isStunned -= delta
            return
        }

        // Find target
        let target = findTarget(for: entity, in: state)

        if let target = target {
            let dist = entity.distance(to: target)
            let attackRange = attackRange(for: entity)

            if dist <= attackRange {
                // Attack
                entity.attackTimer -= delta
                if entity.attackTimer <= 0 {
                    performAttack(entity: entity, target: target, in: state)
                    entity.attackTimer = attackSpeed(for: entity)
                }
                entity.velocity = .zero
            } else {
                // Move toward target
                let dir = entity.direction(to: target)
                let speed = movementSpeed(for: entity)
                entity.velocity = CGVector(dx: dir.dx * speed, dy: dir.dy * speed)
                entity.position.x += entity.velocity.dx * CGFloat(delta)
                entity.position.y += entity.velocity.dy * CGFloat(delta)
            }
        } else {
            // Move toward enemy tower
            moveTowardEnemyTower(entity: entity, delta: delta, in: state)
        }

        // Clamp to arena
        clampPosition(entity, in: state)
    }

    private func findTarget(for entity: Entity, in state: BattleState) -> Entity? {
        let enemies = state.entityManager.enemies(of: entity.team)
        let validTargets = enemies.filter { canTarget(attacker: entity, target: $0) }
        return validTargets.min { entity.distance(to: $0) < entity.distance(to: $1) }
    }

    private func canTarget(attacker: Entity, target: Entity) -> Bool {
        // Flying can only be hit by groundAndAir or other flyers
        if target.isFlying {
            if let unit = attacker as? UnitEntity {
                return unit.unitData.targetType == .groundAndAir
            }
            return true
        }
        return true
    }

    private func performAttack(entity: Entity, target: Entity, in state: BattleState) {
        if let unit = entity as? UnitEntity {
            switch unit.unitData.attackPattern {
            case .melee:
                target.takeDamage(unit.unitData.damage)
                spawnHitEffect(at: target.position, in: state)
            case .ranged:
                let projectile = Projectile(
                    team: entity.team,
                    position: entity.position,
                    direction: entity.direction(to: target),
                    speed: unit.unitData.projectileSpeed ?? 400,
                    damage: unit.unitData.damage,
                    targetID: target.id,
                    isHoming: true
                )
                state.projectiles.append(projectile)
            case .splash:
                applySplashDamage(at: target.position, radius: 80, damage: unit.unitData.damage, team: entity.team, in: state)
            case .buff:
                // Buff nearby allies
                let allies = state.entityManager.allies(of: entity.team)
                for ally in allies where ally.id != entity.id && ally.distance(to: entity) < 200 {
                    ally.speedMultiplier = 1.3
                }
            }
        } else if let hero = entity as? HeroEntity {
            target.takeDamage(hero.heroData.baseDamage)
            spawnHitEffect(at: target.position, in: state)
        }
    }

    private func updateProjectiles(delta: TimeInterval, in state: BattleState) {
        var projectilesToRemove: [Projectile.ID] = []

        for projectile in state.projectiles {
            if let targetID = projectile.targetID,
               let target = state.entityManager.entities.first(where: { $0.id == targetID }) {
                let dir = direction(from: projectile.position, to: target.position)
                projectile.direction = dir
            }

            projectile.position.x += projectile.direction.dx * CGFloat(projectile.speed) * CGFloat(delta)
            projectile.position.y += projectile.direction.dy * CGFloat(projectile.speed) * CGFloat(delta)

            // Collision check
            if let hit = state.entityManager.entities.first(where: { $0.id != projectile.targetID && $0.team != projectile.team && distance($0.position, projectile.position) < 30 }) {
                hit.takeDamage(projectile.damage)
                spawnHitEffect(at: projectile.position, in: state)
                projectilesToRemove.append(projectile.id)
            }
        }

        state.projectiles.removeAll { projectilesToRemove.contains($0.id) }

        // Remove projectiles that left the arena
        state.projectiles.removeAll { projectile in
            projectile.position.x < -100 || projectile.position.x > GameConfig.arenaWidth + 100 ||
            projectile.position.y < -100 || projectile.position.y > GameConfig.arenaHeight + 100
        }
    }

    private func applySplashDamage(at position: CGPoint, radius: CGFloat, damage: Double, team: Team, in state: BattleState) {
        for entity in state.entityManager.entities where entity.team != team && distance(entity.position, position) <= radius {
            entity.takeDamage(damage)
        }
        spawnExplosion(at: position, in: state)
    }

    private func moveTowardEnemyTower(entity: Entity, delta: TimeInterval, in state: BattleState) {
        let targetX: CGFloat = GameConfig.arenaWidth / 2
        let targetY: CGFloat = entity.team == .blue ? GameConfig.arenaHeight : 0
        let dx = targetX - entity.position.x
        let dy = targetY - entity.position.y
        let len = sqrt(dx * dx + dy * dy)
        guard len > 0 else { return }
        let speed = movementSpeed(for: entity)
        entity.position.x += (dx / len) * speed * CGFloat(delta)
        entity.position.y += (dy / len) * speed * CGFloat(delta)
    }

    private func clampPosition(_ entity: Entity, in state: BattleState) {
        entity.position.x = max(0, min(GameConfig.arenaWidth, entity.position.x))
        entity.position.y = max(0, min(GameConfig.arenaHeight, entity.position.y))
    }

    // MARK: - Helpers

    private func attackRange(for entity: Entity) -> CGFloat {
        if let unit = entity as? UnitEntity { return unit.unitData.range }
        if let hero = entity as? HeroEntity { return hero.heroData.range }
        return 60
    }

    private func attackSpeed(for entity: Entity) -> TimeInterval {
        if let unit = entity as? UnitEntity { return unit.unitData.attackSpeed }
        return 1.0
    }

    private func movementSpeed(for entity: Entity) -> CGFloat {
        var speed: CGFloat = 0
        if let unit = entity as? UnitEntity { speed = unit.unitData.movementSpeed }
        if let hero = entity as? HeroEntity { speed = hero.heroData.movementSpeed }
        return speed * entity.speedMultiplier
    }

    private func spawnHitEffect(at position: CGPoint, in state: BattleState) {
        state.effects.append(VisualEffectEvent(position: position, type: .hit, duration: 0.3))
    }

    private func spawnExplosion(at position: CGPoint, in state: BattleState) {
        state.effects.append(VisualEffectEvent(position: position, type: .explosion, duration: 0.6))
    }

    private func direction(from: CGPoint, to: CGPoint) -> CGVector {
        let dx = to.x - from.x
        let dy = to.y - from.y
        let len = sqrt(dx * dx + dy * dy)
        guard len > 0 else { return .zero }
        return CGVector(dx: dx / len, dy: dy / len)
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return sqrt(dx * dx + dy * dy)
    }
}
