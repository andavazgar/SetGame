//
//  SetGameViewModel.swift
//  SetGame
//
//  Created by Andres Vazquez on 2022-03-01.
//

import SwiftUI

class ShapesSetGame: ObservableObject {
    @Published private var gameModel = SetGame()
    var deck: [SetCard] { gameModel.deck }
    var cardsOnTable: [SetCard] { gameModel.cardsOnTable }
    var numberOfCardsDealt: Int { gameModel.numberOfCardsDealt }
    var initialNumberOfCards: Int { gameModel.initialNumberOfCards }
    var numberOfMatches: Int { gameModel.numberOfMatches }
    var deckIsEmpty: Bool { gameModel.deckIsEmpty }
    
    
    // MARK: - Intents
    func choose(_ card: SetCard) {
        gameModel.choose(card)
    }
    
    func dealCard(_ card: SetCard) {
        gameModel.dealCard(card)
    }
    
    func deal3cards() {
        gameModel.deal3cards()
    }
    
    func restartGame() {
        gameModel.restartGame()
    }
    
    func getAMatchingSet() -> TernaryCollection<String>? {
        gameModel.getAMatchingSet()
    }
    
    // MARK: - Shapes, shading and color interpretation
    
    enum CardShape: Int {
        case diamond, squiggle, oval
        
        func getShape() -> AnyShape {
            switch self {
            case .diamond:
                return AnyShape(Diamond())
            case .squiggle:
                return AnyShape(Squiggle())
            case .oval:
                return AnyShape(Capsule())
            }
        }
    }
    
    enum CardShading<S: Shape>: Int {
        case solid, striped, open
        
        @ViewBuilder
        func getShadedShape(shape: S, color: Color) -> some View {
            switch self {
            case .solid:
                shape.fill(color)
            case .striped:
                shape.stroke(color, lineWidth: 2)
                    .background(StripedFill().stroke(color).clipShape(shape))
            case .open:
                shape.stroke(color, lineWidth: 2)
            }
        }
    }
    
    enum CardColor: Int {
        case red, green, purple
        
        func getColor() -> Color {
            switch self {
            case .red:
                return Color.red
            case .green:
                return Color.green
            case .purple:
                return Color.purple
            }
        }
    }
}
