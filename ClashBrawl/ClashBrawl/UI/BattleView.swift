import SwiftUI

/// Main battle screen. Renders the arena, units, effects, cards, and HUD.
struct BattleView: View {
    @Bindable var gameState: GameState
    @State private var battleState: BattleState
    @State private var combatLogic: CombatLogic
    @State private var particleSystem = ParticleSystem()
    @State private var visualEffectManager = VisualEffectManager()
    @State private var gameDeck: GameDeck
    @State private var timer: Timer?
    @State private var selectedCard: CardData?
    @State private var dragPosition: CGPoint?
    @State private var heroPosition: CGPoint = CGPoint(x: GameConfig.arenaWidth / 2, y: GameConfig.arenaHeight * 0.15)
    @State private var joystickOffset: CGSize = .zero
    @State private var matchResultTitle: String?
    @State private var showMatchResult = false

    init(gameState: GameState) {
        self.gameState = gameState
        let state = BattleState(localTeam: .blue, opponentName: "Opponent")
        _battleState = State(initialValue: state)
        _combatLogic = State(initialValue: CombatLogic(battleState: state))
        let deck = gameState.profile.selectedDeck() ?? gameState.profile.ownedDecks.first!
        _gameDeck = State(initialValue: GameDeck(deck: deck))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                topHUD
                arenaView
                bottomControls
            }
        }
        .onAppear { startBattle() }
        .onDisappear { endBattle() }
        .alert("Match Over", isPresented: $showMatchResult) {
            Button("OK") {
                showMatchResult = false
                gameState.navigate(to: .mainMenu)
            }
        } message: {
            Text(matchResultTitle ?? "")
        }
        .onChange(of: battleState.winner) { _, winner in
            if let winner = winner {
                matchResultTitle = winner == .blue ? "Victory!" : "Defeat!"
                showMatchResult = true
            }
        }
    }

    // MARK: - Top HUD
    private var topHUD: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("YOU")
                        .font(.caption.bold())
                        .foregroundColor(.blue)
                    Spacer()
                    Text("\(Int(battleState.blueTowerHealth * 100))%")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                }
                ProgressView(value: battleState.blueTowerHealth)
                    .tint(.blue)
            }

            VStack(spacing: 2) {
                Text(formatTime(battleState.elapsedTime))
                    .font(.title3.bold())
                    .foregroundColor(.white)
                Text(battleState.phase == .overtime ? "OVERTIME" : "")
                    .font(.caption)
                    .foregroundColor(.orange)
            }

            VStack(alignment: .trailing, spacing: 4) {
                HStack {
                    Text("\(Int(battleState.redTowerHealth * 100))%")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                    Spacer()
                    Text("FOE")
                        .font(.caption.bold())
                        .foregroundColor(.red)
                }
                ProgressView(value: battleState.redTowerHealth)
                    .tint(.red)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    // MARK: - Arena
    private var arenaView: some View {
        GeometryReader { geometry in
            let scale = min(geometry.size.width / GameConfig.arenaWidth, geometry.size.height / GameConfig.arenaHeight)
            ZStack {
                // Arena background
                Canvas { context, size in
                    drawArena(in: &context, size: size)
                }
                .frame(width: GameConfig.arenaWidth * scale, height: GameConfig.arenaHeight * scale)
                .background(
                    LinearGradient(colors: [.green.opacity(0.2), .blue.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                )
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )

                // Entities
                ForEach(battleState.entityManager.entities) { entity in
                    EntityView(entity: entity)
                        .position(
                            x: entity.position.x * scale,
                            y: (GameConfig.arenaHeight - entity.position.y) * scale
                        )
                }

                // Projectiles
                ForEach(battleState.projectiles) { projectile in
                    Circle()
                        .fill(projectile.team == .blue ? Color.blue : Color.red)
                        .frame(width: 12, height: 12)
                        .position(
                            x: projectile.position.x * scale,
                            y: (GameConfig.arenaHeight - projectile.position.y) * scale
                        )
                }

                // Effects
                ForEach(visualEffectManager.effects) { effect in
                    EffectView(effect: effect)
                        .position(
                            x: effect.position.x * scale,
                            y: (GameConfig.arenaHeight - effect.position.y) * scale
                        )
                }

                // Particles
                ForEach(particleSystem.particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(
                            x: particle.position.x * scale,
                            y: (GameConfig.arenaHeight - particle.position.y) * scale
                        )
                        .opacity(particle.alpha)
                }

                // Drag ghost
                if let card = selectedCard, let dragPosition = dragPosition {
                    CardView(card: card, scale: 0.8)
                        .position(dragPosition)
                        .opacity(0.8)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragPosition = value.location
                    }
                    .onEnded { value in
                        deployCard(at: value.location, scale: scale)
                        dragPosition = nil
                    }
            )
        }
    }

    private func drawArena(in context: inout GraphicsContext, size: CGSize) {
        // Draw lanes
        let laneHeight = size.height / CGFloat(GameConfig.laneCount)
        for i in 0..<GameConfig.laneCount {
            let rect = CGRect(x: 0, y: CGFloat(i) * laneHeight, width: size.width, height: laneHeight)
            context.fill(Path(rect), with: .color(i % 2 == 0 ? .green.opacity(0.05) : .green.opacity(0.1)))
        }

        // Draw towers
        let towerSize: CGFloat = 60
        let blueTower = CGRect(x: size.width / 2 - towerSize / 2, y: size.height - towerSize, width: towerSize, height: towerSize)
        let redTower = CGRect(x: size.width / 2 - towerSize / 2, y: 0, width: towerSize, height: towerSize)
        context.fill(Path(blueTower), with: .color(.blue))
        context.fill(Path(redTower), with: .color(.red))
    }

    // MARK: - Bottom Controls
    private var bottomControls: some View {
        VStack(spacing: 8) {
            // Elixir bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(colors: [.purple, .pink, .orange], startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: geometry.size.width * CGFloat(battleState.elixir / GameConfig.maxElixir))
                }
            }
            .frame(height: 16)
            .padding(.horizontal)

            // Hand
            HStack(spacing: 8) {
                ForEach(gameDeck.currentHand()) { card in
                    CardView(card: card, isSelected: selectedCard?.id == card.id, scale: 0.9)
                        .onTapGesture {
                            selectedCard = card
                        }
                }
            }
            .padding(.horizontal)

            // Hero joystick area
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 120, height: 120)
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 40, height: 40)
                        .offset(joystickOffset)
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let maxRadius: CGFloat = 60
                            let translation = value.translation
                            let distance = sqrt(translation.width * translation.width + translation.height * translation.height)
                            let clampedDistance = min(distance, maxRadius)
                            let angle = atan2(translation.height, translation.width)
                            joystickOffset = CGSize(width: cos(angle) * clampedDistance, height: sin(angle) * clampedDistance)
                            moveHero(by: joystickOffset)
                        }
                        .onEnded { _ in
                            withAnimation(.easeOut) { joystickOffset = .zero }
                        }
                )
                Spacer()
            }
            .padding(.bottom)
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }

    // MARK: - Battle Loop
    private func startBattle() {
        battleState.start()
        spawnInitialHeroes()
        timer = Timer.scheduledTimer(withTimeInterval: GameConfig.physicsTickRate, repeats: true) { _ in
            tick(delta: GameConfig.physicsTickRate)
        }
    }

    private func endBattle() {
        timer?.invalidate()
        timer = nil
        NetworkManager.shared.disconnectFromMatchSocket()
    }

    private func tick(delta: TimeInterval) {
        battleState.update(delta: delta)
        combatLogic.update(delta: delta)
        particleSystem.update(delta: delta)
        visualEffectManager.update(delta: delta)

        // Spawn bot units occasionally
        if Int.random(in: 0...300) == 0 {
            spawnBotUnit()
        }
    }

    private func spawnInitialHeroes() {
        if let heroData = HeroData.hero(by: gameState.profile.selectedHeroID) {
            let hero = HeroEntity(team: .blue, position: CGPoint(x: GameConfig.arenaWidth / 2, y: GameConfig.arenaHeight * 0.2), heroData: heroData)
            battleState.entityManager.add(hero)
        }

        let botHeroData = HeroData.allHeroes.randomElement()!
        let botHero = HeroEntity(team: .red, position: CGPoint(x: GameConfig.arenaWidth / 2, y: GameConfig.arenaHeight * 0.8), heroData: botHeroData)
        battleState.entityManager.add(botHero)
    }

    private func spawnBotUnit() {
        let card = CardData.allCards.randomElement()!
        guard let unitID = card.unitID, let unitData = UnitData.unit(by: unitID) else { return }
        let x = CGFloat.random(in: 100...(GameConfig.arenaWidth - 100))
        let unit = UnitEntity(team: .red, position: CGPoint(x: x, y: GameConfig.arenaHeight * 0.8), unitData: unitData)
        battleState.entityManager.add(unit)
    }

    // MARK: - Input Handling
    private func deployCard(at screenPoint: CGPoint, scale: CGFloat) {
        guard let card = selectedCard else { return }
        guard battleState.spendElixir(Double(card.elixirCost)) else { return }
        guard gameDeck.playCard(card) else { return }

        let arenaX = screenPoint.x / scale
        let arenaY = (GameConfig.arenaHeight * scale - screenPoint.y) / scale
        let position = CGPoint(x: arenaX, y: arenaY)

        if let unitID = card.unitID, let unitData = UnitData.unit(by: unitID) {
            for _ in 0..<unitData.spawnCount {
                let offset = CGPoint(x: position.x + CGFloat.random(in: -30...30), y: position.y + CGFloat.random(in: -30...30))
                let unit = UnitEntity(team: .blue, position: offset, unitData: unitData)
                battleState.entityManager.add(unit)
                particleSystem.emit(at: offset, count: 6, color: .blue)
            }
        }

        if card.heroID != nil {
            visualEffectManager.add(VisualEffectEvent(position: position, type: .explosion, duration: 0.5))
        }

        if let damage = card.spellDamage, card.spellRadius != nil {
            visualEffectManager.add(VisualEffectEvent(position: position, type: .explosion, duration: 0.6))
            if damage > 0 {
                for enemy in battleState.entityManager.enemies(of: .blue) where distance(enemy.position, position) < (card.spellRadius ?? 0) {
                    enemy.takeDamage(damage)
                    particleSystem.emitHit(at: enemy.position)
                }
            } else {
                for ally in battleState.entityManager.allies(of: .blue) where distance(ally.position, position) < (card.spellRadius ?? 0) {
                    ally.heal(-damage)
                    particleSystem.emitHeal(at: ally.position)
                }
            }
        }

        selectedCard = nil
    }

    private func moveHero(by offset: CGSize) {
        let speed: CGFloat = 200
        let dx = offset.width / 60 * speed * GameConfig.physicsTickRate
        let dy = -offset.height / 60 * speed * GameConfig.physicsTickRate
        heroPosition.x += dx
        heroPosition.y += dy
        heroPosition.x = max(0, min(GameConfig.arenaWidth, heroPosition.x))
        heroPosition.y = max(0, min(GameConfig.arenaHeight, heroPosition.y))

        if let hero = battleState.entityManager.entities.first(where: { $0.team == .blue && $0 is HeroEntity }) {
            hero.position = heroPosition
        }
    }

    // MARK: - Helpers
    private func formatTime(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return sqrt(dx * dx + dy * dy)
    }
}

// MARK: - Entity View
struct EntityView: View {
    let entity: Entity

    var body: some View {
        ZStack {
            Circle()
                .fill(entity.team == .blue ? Color.blue : Color.red)
                .frame(width: entitySize, height: entitySize)
                .shadow(color: entity.team.color.opacity(0.6), radius: 6)

            // Health bar
            VStack {
                Spacer()
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.black.opacity(0.5))
                        Rectangle()
                            .fill(entity.team == .blue ? Color.green : Color.orange)
                            .frame(width: geometry.size.width * CGFloat(entity.health / entity.maxHealth))
                    }
                }
                .frame(width: entitySize, height: 4)
            }
            .frame(width: entitySize, height: entitySize)
        }
    }

    private var entitySize: CGFloat {
        if entity is HeroEntity { return 50 }
        if let unit = entity as? UnitEntity {
            return max(24, CGFloat(unit.unitData.hitpoints) / 80)
        }
        return 30
    }
}

// MARK: - Effect View
struct EffectView: View {
    let effect: VisualEffectEvent

    var body: some View {
        Circle()
            .fill(effect.colorForType)
            .frame(width: 40 * (1 - effect.progress), height: 40 * (1 - effect.progress))
            .opacity(1.0 - Double(effect.progress))
    }
}

extension VisualEffectEvent {
    var colorForType: Color {
        switch type {
        case .hit: return .yellow
        case .explosion: return .orange
        case .heal: return .green
        default: return .white
        }
    }
}

#Preview {
    BattleView(gameState: GameState())
}
