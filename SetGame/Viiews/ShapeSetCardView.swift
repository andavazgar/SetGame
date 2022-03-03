//
//  ShapeSetCardView.swift
//  SetGame
//
//  Created by Andres Vazquez on 2022-03-01.
//

import SwiftUI

struct ShapeSetCardView: View {
    typealias CardShape = ShapesSetGame.CardShape
    typealias CardShading = ShapesSetGame.CardShading
    typealias CardColor = ShapesSetGame.CardColor
    
    @Environment(\.colorScheme) var colorScheme
    let card: SetCard
    private var shape: AnyShape {
        CardShape(rawValue: card.shape)!.getShape()
    }
    private var shadedShape: some View {
        CardShading(rawValue: card.shading)?.getShadedShape(shape: shape, color: color)
    }
    private var color: Color {
        CardColor(rawValue: card.color)?.getColor() ?? .primary
    }
    private var cardColor: Color {
        var cardColor = colorScheme == .light ? Color.white : .white.opacity(0.9)
        let opacity = colorScheme == .light ? 0.2 : 0.5
        
        if card.isSelected {
            cardColor = .blue.opacity(opacity)
            
            if card.isValidMatch == true {
                cardColor = .green.opacity(opacity)
            } else if card.isValidMatch == false {
                cardColor = .red.opacity(opacity)
            }
        }
        
        return cardColor
    }
    
    private var cardBorderColor: Color {
        var cardBorderColor = Color.primary
        
        if card.isSelected {
            cardBorderColor = .blue
            
            if card.isValidMatch == true {
                cardBorderColor = .green
            } else if card.isValidMatch == false {
                cardBorderColor = .red
            }
        }
        
        return cardBorderColor
    }
    
    init(_ card: SetCard) {
        self.card = card
    }
    
    var body: some View {
        let cardRectangle = RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
        
        ZStack {
            cardRectangle
                .strokeBorder(cardBorderColor, lineWidth: Constants.cardBorderWidth)
                .background(
                    cardRectangle
                        .fill(cardColor)
                )
            
            VStack {
                ForEach(0..<card.numberOfSymbols, id:\.self) { _ in
                    shadedShape
                        .aspectRatio(Constants.symbolsAspectRatio, contentMode: .fit)
                }
            }
            .padding(Constants.innerCardPadding)
        }
        .padding(Constants.outerCardPadding)
    }
    
    private struct Constants {
        static let cardCornerRadius: CGFloat = 10
        static let cardBorderWidth: CGFloat = 2
        static let innerCardPadding: CGFloat = 20
        static let outerCardPadding: CGFloat = 4
        static let symbolsAspectRatio: CGFloat = 2/1
    }
}

struct ShapeSetCardView_Previews: PreviewProvider {
    static var previews: some View {
        let card1 = SetCard(numberOfSymbols: 1, shape: 0, shading: 0, color: 0)
        let card2 = SetCard(numberOfSymbols: 2, shape: 1, shading: 1, color: 1)
        let card3 = SetCard(numberOfSymbols: 3, shape: 2, shading: 2, color: 2)
        
        Group {
            ShapeSetCardView(card1)
            ShapeSetCardView(card2)
            ShapeSetCardView(card3)
        }
        .previewLayout(.fixed(width: 200, height: 300))
    }
}