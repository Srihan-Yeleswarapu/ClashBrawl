import Foundation
import SwiftUI

/// A single particle with position, velocity, life, and color.
struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var life: TimeInterval
    var maxLife: TimeInterval
    var size: CGFloat
    var color: Color
    var alpha: Double = 1.0

    var progress: CGFloat {
        return CGFloat(1.0 - (life / maxLife))
    }
}

/// Lightweight particle system for explosions, hits, and spawn effects.
final class ParticleSystem: ObservableObject {
    @Published var particles: [Particle] = []

    func emit(at position: CGPoint, count: Int = 10, color: Color = .orange, speed: CGFloat = 200, size: CGFloat = 6, life: TimeInterval = 0.6) {
        for _ in 0..<count {
            let angle = Double.random(in: 0...(2 * .pi))
            let velocity = CGVector(dx: cos(angle) * Double.random(in: 0.5...1.0) * speed,
                                    dy: sin(angle) * Double.random(in: 0.5...1.0) * speed)
            let particle = Particle(position: position,
                                    velocity: velocity,
                                    life: life * Double.random(in: 0.8...1.2),
                                    maxLife: life,
                                    size: size * CGFloat.random(in: 0.6...1.2),
                                    color: color)
            particles.append(particle)
        }
    }

    func emitExplosion(at position: CGPoint, color: Color = .orange) {
        emit(at: position, count: 24, color: color, speed: 300, size: 8, life: 0.7)
    }

    func emitHit(at position: CGPoint, color: Color = .yellow) {
        emit(at: position, count: 8, color: color, speed: 120, size: 4, life: 0.3)
    }

    func emitHeal(at position: CGPoint) {
        emit(at: position, count: 16, color: .green, speed: 80, size: 5, life: 0.8)
    }

    func update(delta: TimeInterval) {
        for index in particles.indices {
            particles[index].life -= delta
            particles[index].position.x += particles[index].velocity.dx * CGFloat(delta)
            particles[index].position.y += particles[index].velocity.dy * CGFloat(delta)
            particles[index].alpha = max(0, Double(particles[index].life / particles[index].maxLife))
        }
        particles.removeAll { $0.life <= 0 }
    }

    func clear() {
        particles.removeAll()
    }
}
