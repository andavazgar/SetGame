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
    @State private var cardsToDiscard = [String]()
    
    @Namespace private var dealNamespace
    @Namespace private var discardPileNamespace
    
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
        AspectVGrid(items: game.cardsOnTable, minimumWidth: Constants.cardMinimumWidth, aspectRatio: Constants.cardAspectRatio, bottomPadding: Constants.cardHeight) { card in
            if isInDeck(card) || isDiscarded(card) {
                Color.clear
            } else {
                ShapeSetCardView(card, flipped: dealtCards[card.id]!, isHinted: hintedCards?.elements.contains(card.id) ?? false)
                    .matchedGeometryEffect(id: card.id, in: dealNamespace)
                    .matchedGeometryEffect(id: card.id, in: discardPileNamespace, isSource: true)
                    .zIndex(Double(indexInDeck(of: card)))
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
                    .onTapGesture {
                        // Discards to cards to the discard pile
                        if game.matchedCards.count == 3 {
                            withAnimation(.linear(duration: Constants.durationToDiscardCards)) {
                                discardCards(game.matchedCards)
                            }
                            
                            // Removes the empty spaces and rearranges the cards (increasing their size if necessary)
                            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.durationToDiscardCards) {
                                withAnimation(.linear(duration: Constants.durationToRearrangeCards)) {
                                    game.discardMatchedCards()
                                    cardsToDiscard.removeAll(keepingCapacity: true)
                                }
                            }
                        } else {
                            game.choose(card)
                        }
                    }
            }
        }
        .onAppear {
            dealCards()
        }
    }
    
    private var footer: some View {
        ZStack {
            HStack {
                deckOfCards
                Spacer()
                discardPile
            }
        }
    }
    
    private var deckOfCards: some View {
        ZStack {
            ForEach(game.deck.filter(isInDeck)) { card in
                let indexOfCard = indexInDeck(of: card)
                
                ShapeSetCardView(card)
                    .matchedGeometryEffect(id: card.id, in: dealNamespace, isSource: true)
                    .frame(width: Constants.cardWidth, height: Constants.cardHeight)
                    .zIndex(-Double(indexOfCard))
                    .offset(x: 0, y: 0.15 * Double(indexOfCard))  // Allows to show the depth of the deck
                    .rotation3DEffect(.degrees(5), axis: (1, 0, 0))
            }
        }
        .padding(.horizontal)
        .onTapGesture {
            var durationOfAnimation = 0.35
            
            // Checks if there are cards to be discarded
            if game.matchedCards.count == 3 {
                durationOfAnimation = Constants.durationToDiscardCards
            }
            
            withAnimation(.linear(duration: durationOfAnimation)) {
                discardCards(game.matchedCards)
                game.draw3CardsFromDeck()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + durationOfAnimation) {
                dealCards()
            }
        }
    }
    
    private var discardPile: some View {
        ZStack {
            ForEach(game.discardPile) { card in
                let indexOfCard = game.discardPile.firstIndex(where: { $0.id == card.id })!
                
                ShapeSetCardView(card, flipped: true)
                    .matchedGeometryEffect(id: card.id, in: discardPileNamespace)
                    .frame(width: Constants.cardWidth, height: Constants.cardHeight)
                    .zIndex(Double(indexOfCard - game.discardPile.count))
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
                    .offset(x: offset(forIndex: indexOfCard), y: 0.15 * Double(indexOfCard))
                    .rotationEffect(rotation(forIndex: indexOfCard), anchor: .bottom)
            }
            .offset(x: Constants.discardPile.xOffset, y: 0)
        }
    }
    
    
    // MARK: - Methods
    private func dealCards() {
        let cardsToDeal = game.deck[dealtCards.count..<game.numberOfCardsDealt]
        
        for (index, card) in cardsToDeal.enumerated() {
            withAnimation(dealAnimation(for: card, withIndex: index)) {
                dealCard(card)
            }
            withAnimation(dealAnimation(for: card, withIndex: index, durationPercentage: 0.5, delayOffset: 1)) {
                flipCard(card)
            }
        }
    }
    
    private func dealCard(_ card: SetCard) {
        dealtCards[card.id] = false
    }
    
    private func flipCard(_ card: SetCard) {
        dealtCards[card.id] = true
    }
    
    private func discardCards(_ cards: [SetCard]) {
        cardsToDiscard.append(contentsOf: cards.map({ $0.id }))
        game.addToDiscardPile(game.matchedCards)
    }
    
    // Needed for discard pile
    private func rotation(forIndex index: Int) -> Angle {
        switch index {
        case let i where i % 3 == 0:
            return Angle.degrees(-Constants.discardPile.cardsRotationAngle)
        case let i where i % 3 == 1:
            return .zero
        case let i where i % 3 == 2:
            return Angle.degrees(Constants.discardPile.cardsRotationAngle)
        default:
            return .zero
        }
    }
    
    // Needed for discard pile
    private func offset(forIndex index: Int) -> CGFloat {
        switch index {
        case let i where i % 3 == 0:
            return -Constants.discardPile.cardsXOffset
        case let i where i % 3 == 1:
            return 0
        case let i where i % 3 == 2:
            return Constants.discardPile.cardsXOffset
        default:
            return 0
        }
    }
    
    private func isInDeck(_ card: SetCard) -> Bool {
        !dealtCards.keys.contains(card.id)
    }
    
    private func isDiscarded(_ card: SetCard) -> Bool {
        cardsToDiscard.contains(card.id)
    }
    
    private func indexInDeck(of card: SetCard) -> Int {
        game.deck.firstIndex(where: { $0.id == card.id }) ?? -1
    }
    
    private func dealAnimation(for card: SetCard, withIndex index: Int, durationPercentage: Double = 1, delayOffset: Double = 0) -> Animation {
        let delay = Constants.durationToDealOneCard * (Double(index) + delayOffset)
        return Animation.linear(duration: Constants.durationToDealOneCard * durationPercentage).delay(delay)
    }
    
    
    // MARK: - Constants
    private struct Constants {
        static let cardAspectRatio: Double = 2/3
        static let cardHeight = 120.0
        static let cardMinimumWidth = 65.0
        static let cardWidth = cardHeight * cardAspectRatio
        static let discardPile = (
            cardsRotationAngle: 16.0,
            cardsXOffset: 16.0,
            xOffset: -16.0 * 3
        )
        static let durationToDealOneCard = 0.75
        static let durationToDiscardCards = 1.0
        static let durationToRearrangeCards = 0.5
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
