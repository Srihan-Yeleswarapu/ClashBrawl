import Foundation
import SwiftUI

/// Types of visual effects that can occur in battle.
enum VisualEffectType: String, Codable {
    case hit
    case explosion
    case muzzleFlash
    case heal
    case spawn
    case levelUp
}

/// A single visual effect event in the battle.
struct VisualEffectEvent: Identifiable {
    let id = UUID()
    var position: CGPoint
    let type: VisualEffectType
    var duration: TimeInterval
    var elapsed: TimeInterval = 0
    var scale: CGFloat = 1.0
    var color: Color = .white

    var progress: CGFloat {
        guard duration > 0 else { return 1 }
        return CGFloat(min(1, elapsed / duration))
    }

    var isComplete: Bool { elapsed >= duration }
}

/// Manages a pool of active visual effects and updates them.
final class VisualEffectManager: ObservableObject {
    @Published var effects: [VisualEffectEvent] = []

    func add(_ effect: VisualEffectEvent) {
        effects.append(effect)
    }

    func update(delta: TimeInterval) {
        for index in effects.indices {
            effects[index].elapsed += delta
        }
        effects.removeAll { $0.isComplete }
    }

    func clear() {
        effects.removeAll()
    }
}

// MARK: - SwiftUI View Modifiers for Polish

/// Adds a premium card-like appearance with shadow, border, and gradient.
struct CardStyle: ViewModifier {
    var color: Color = .blue
    var intensity: Double = 0.3

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: [color.opacity(0.2), color.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.6), lineWidth: 2)
            )
            .shadow(color: color.opacity(intensity), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func cardStyle(color: Color = .blue, intensity: Double = 0.3) -> some View {
        modifier(CardStyle(color: color, intensity: intensity))
    }
}

/// Adds a subtle pulse animation to a view.
struct PulseAnimation: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear { isPulsing = true }
    }
}

extension View {
    func pulse() -> some View {
        modifier(PulseAnimation())
    }
}
