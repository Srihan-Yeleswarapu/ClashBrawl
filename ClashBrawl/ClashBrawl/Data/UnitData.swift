import Foundation
import SwiftUI

/// Static stats and behavior definition for a deployable unit.
struct UnitData: Identifiable, Codable, Hashable {
    let id: UnitID
    let name: String
    let hitpoints: Double
    let damage: Double
    let attackSpeed: TimeInterval  // seconds between attacks
    let movementSpeed: CGFloat       // points per second
    let range: CGFloat               // attack range in points
    let targetType: TargetType
    let canFly: Bool
    let attackPattern: AttackPattern
    let spawnCount: Int              // For swarm cards
    let projectileSpeed: CGFloat?
    let deathExplosionRadius: CGFloat?
    let deathExplosionDamage: Double?

    enum AttackPattern: String, Codable {
        case melee
        case ranged
        case splash
        case buff
    }

    static func == (lhs: UnitData, rhs: UnitData) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension UnitData {
    static let allUnits: [UnitData] = [
        UnitData(id: "u001", name: "Brawler", hitpoints: 800, damage: 120, attackSpeed: 1.2,
                 movementSpeed: 160, range: 60, targetType: .ground, canFly: false,
                 attackPattern: .melee, spawnCount: 1, projectileSpeed: nil,
                 deathExplosionRadius: nil, deathExplosionDamage: nil),
        UnitData(id: "u002", name: "Sharpshooter", hitpoints: 280, damage: 90, attackSpeed: 0.8,
                 movementSpeed: 120, range: 320, targetType: .groundAndAir, canFly: false,
                 attackPattern: .ranged, spawnCount: 1, projectileSpeed: 500,
                 deathExplosionRadius: nil, deathExplosionDamage: nil),
        UnitData(id: "u003", name: "Tank", hitpoints: 2200, damage: 150, attackSpeed: 1.8,
                 movementSpeed: 90, range: 70, targetType: .ground, canFly: false,
                 attackPattern: .melee, spawnCount: 1, projectileSpeed: nil,
                 deathExplosionRadius: nil, deathExplosionDamage: nil),
        UnitData(id: "u004", name: "Sky Drone", hitpoints: 350, damage: 70, attackSpeed: 0.9,
                 movementSpeed: 180, range: 280, targetType: .groundAndAir, canFly: true,
                 attackPattern: .ranged, spawnCount: 1, projectileSpeed: 600,
                 deathExplosionRadius: nil, deathExplosionDamage: nil),
        UnitData(id: "u005", name: "Mini Minion", hitpoints: 120, damage: 45, attackSpeed: 1.0,
                 movementSpeed: 200, range: 50, targetType: .ground, canFly: false,
                 attackPattern: .melee, spawnCount: 3, projectileSpeed: nil,
                 deathExplosionRadius: nil, deathExplosionDamage: nil)
    ]

    static func unit(by id: UnitID) -> UnitData? {
        allUnits.first { $0.id == id }
    }
}
