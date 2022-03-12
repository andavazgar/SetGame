//
//  ShapeSetGameView.swift
//  SetGame
//
//  Created by Andres Vazquez on 2022-02-25.
//

import SwiftUI

struct ShapeSetGameView: View {
    @ObservedObject var game: ShapesSetGame
    @State private var hintedCards: TernaryCollection<String>?
    @State private var dealtCards = [String: Bool]()
    @State private var discardPile = Set<String>()
    @Namespace private var dealNamespace
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                header
                cardsInPlay
            }
            footer
        }
        .padding(8)
    }
    
    
    // MARK: - Subviews
    private var header: some View {
        HStack {
            Button {
                hintedCards = game.getAMatchingSet()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "eye.circle.fill")
                        .symbolRenderingMode(.multicolor)
                        .foregroundStyle(.gray)
                        .font(.title2)
                    
                    Text("Show matching set")
                }
            }
            
            Spacer()
            Text("Matches: \(game.numberOfMatches)")
        }
        .font(.headline)
        .padding(8)
    }
    
    private var cardsInPlay: some View {
        AspectVGrid(items: game.cardsOnTable, minimumWidth: 65, aspectRatio: 2/3) { card in
            if isInDeck(card) {
                Color.clear
            } else {
                ShapeSetCardView(card, flipped: dealtCards[card.id]!, isHinted: hintedCards?.elements.contains(card.id) ?? false)
                    .matchedGeometryEffect(id: card.id, in: dealNamespace)
                    .zIndex(-Double(indexInDeck(of: card)))
                    .transition(.asymmetric(insertion: .identity, removal: .opacity))
                    .onTapGesture {
                        game.choose(card)
                    }
            }
        }
        .onAppear {
            for card in game.deck[0..<game.initialNumberOfCards] {
                withAnimation(dealAnimation(for: card)) {
                    dealCard(card)
                }
                withAnimation(dealAnimation(for: card, durationPercentage: 0.5, delayOffset: 1)) {
                    flipCard(card)
                }
            }
        }
    }
    
    private var footer: some View {
        ZStack {
            deckOfCards
//            Button {
//                game.restartGame()
//            } label: {
//                HStack {
//                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
//                        .foregroundStyle(.blue)
//                    Text("New Game")
//                }
//                .padding()
//                .background(Capsule().fill(.gray))
//                .font(.title2)
//                .symbolRenderingMode(.multicolor)
//                .foregroundColor(.white)
//                .shadow(color: .black, radius: 1)
//            }
        }
    }
    
    private var deckOfCards: some View {
        ZStack {
            ForEach(game.deck.filter(isInDeck)) { card in
                ShapeSetCardView(card)
                    .matchedGeometryEffect(id: card.id, in: dealNamespace)
                    .zIndex(-Double(indexInDeck(of: card)))
//                    .transition(.asymmetric(insertion: .opacity, removal: .identity))
                    .frame(width: Constants.cardWidth, height: Constants.cardHeight)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Methods
    private func dealCard(_ card: SetCard) {
        dealtCards[card.id] = false
    }
    
    private func flipCard(_ card: SetCard) {
        dealtCards[card.id] = true
    }
    
    private func isInDeck(_ card: SetCard) -> Bool {
        !dealtCards.keys.contains(card.id)
    }
    
    private func indexInDeck(of card: SetCard) -> Int {
        game.deck.firstIndex(where: { $0.id == card.id }) ?? -1
    }
    
    private func dealAnimation(for card: SetCard, durationPercentage: Double = 1, delayOffset: Double = 0) -> Animation {
        let delay = Constants.durationToDealOneCard * (Double(indexInDeck(of: card)) + delayOffset)
        return Animation.linear(duration: Constants.durationToDealOneCard * durationPercentage).delay(delay)
    }
    
    
    // MARK: - Constants
    private struct Constants {
        static let cardAspectRatio: Double = 2/3
        static let cardHeight = 120.0
        static let cardWidth = cardHeight * cardAspectRatio
        static let durationToDealOneCard = 1.0
    }
}

struct ShapeSetGameView_Previews: PreviewProvider {
    static var previews: some View {
        let game = ShapesSetGame()
        
        Group {
            ShapeSetGameView(game: game)
            ShapeSetGameView(game: game)
                .preferredColorScheme(.dark)
        }
    }
}
