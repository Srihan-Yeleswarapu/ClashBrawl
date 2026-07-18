import SwiftUI

/// Displays a single card with elixir cost, name, and rarity styling.
struct CardView: View {
    let card: CardData
    var isSelected: Bool = false
    var isDraggable: Bool = true
    var scale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(card.rarity.color.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(card.rarity.color, lineWidth: isSelected ? 3 : 1)
                    )

                VStack(spacing: 2) {
                    Image(systemName: "bolt.fill")
                        .font(.title2)
                        .foregroundColor(card.rarity.color)
                    Text(card.name)
                        .font(.caption.bold())
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 4)
                }
                .padding(6)

                Text("\(card.elixirCost)")
                    .font(.caption2.bold())
                    .foregroundColor(.white)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(Color.purple))
                    .padding(4)
            }
            .aspectRatio(3/4, contentMode: .fit)
        }
        .scaleEffect(scale)
        .shadow(color: card.rarity.color.opacity(isSelected ? 0.6 : 0.2), radius: isSelected ? 8 : 4)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    CardView(card: CardData.allCards[0])
        .frame(width: 120, height: 160)
}
