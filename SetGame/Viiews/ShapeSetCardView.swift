//
//  ShapeSetCardView.swift
//  SetGame
//
//  Created by Andres Vazquez on 2022-03-01.
//

import SwiftUI

struct ShapeSetCardView: View, Animatable {
    typealias CardShape = ShapesSetGame.CardShape
    typealias CardShading = ShapesSetGame.CardShading
    typealias CardColor = ShapesSetGame.CardColor
    
    // MARK: - Properties
    @Environment(\.colorScheme) private var colorScheme
    let card: SetCard
    var rotation = 0.0  // in degrees
    var isHinted = false
    
    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    private var shape: AnyShape {
        CardShape(rawValue: card.shape)!.getShape()
    }
    private var shadedShape: some View {
        CardShading(rawValue: card.shading)?.getShadedShape(shape: shape, color: color)
    }
    private var color: Color {
        CardColor(rawValue: card.color)?.getColor() ?? .primary
    }
    
    private var cardColorOpacity: Double { colorScheme == .light ? 0.2 : 0.5 }
    private var cardColor: Color {
        var cardColor = colorScheme == .light ? Color.white : .white.opacity(0.9)
        
        if card.isSelected {
            cardColor = .blue.opacity(cardColorOpacity)
            
            if card.isValidMatch == true {
                cardColor = .green.opacity(cardColorOpacity)
            } else if card.isValidMatch == false {
                cardColor = .red.opacity(cardColorOpacity)
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
    
    private let cardRectangle = RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
    
    // MARK: - Body View
    var body: some View {
        ZStack {
            if rotation < 90 {
                faceUpCard
            } else {
                backOfCard
            }
        }
        .rotation3DEffect(.degrees(rotation), axis: (0, 1, 0))
    }
    
    // MARK: - Subviews
    private var faceUpCard: some View {
        ZStack {
            cardRectangle
                .strokeBorder(getColor(cardBorderColor), lineWidth: Constants.cardBorderWidth)
                .background(cardRectangle.fill(getColor(cardColor)))
            
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
    
    private var backOfCard: some View {
        GeometryReader { geometry in
            let innerPadding = geometry.size.width * Constants.backOfCard.innerPaddingPercentage
            
            ZStack {
                cardRectangle
                    .strokeBorder(cardBorderColor, lineWidth: Constants.cardBorderWidth)
                    .background(cardRectangle.fill(cardColor))
                
                // Background color behind pattern
                cardRectangle
                    .fill(Constants.backOfCard.color.opacity(Constants.backOfCard.patternBackgroundColorOpacity))
                    .padding(innerPadding)
                
                // Pattern
                Group {
                    StripedFill(step: Constants.backOfCard.patternLinesStep, lineWidth: Constants.backOfCard.patternLinesWidth)
                        .rotation(.degrees(Constants.backOfCard.rotation))
                    
                    StripedFill(step: Constants.backOfCard.patternLinesStep, lineWidth: Constants.backOfCard.patternLinesWidth)
                        .rotation(.degrees(-Constants.backOfCard.rotation))
                }
                .scaleEffect(Constants.backOfCard.patternScaleFactor)
                .cornerRadius(Constants.cardCornerRadius)
                .padding(innerPadding)
                
                // Border around pattern
                cardRectangle
                    .strokeBorder(.red, lineWidth: Constants.backOfCard.patternBorderWidth)
                    .padding(innerPadding)
            }
        }
        .foregroundColor(.red)
        .padding(Constants.outerCardPadding)
    }
    
    init(_ card: SetCard, flipped: Bool = false, isHinted: Bool = false) {
        self.card = card
        self.rotation = flipped ? 0 : 180
        self.isHinted = isHinted
    }
    
    private func getColor(_ color: Color) -> Color {
        if isHinted && !card.isSelected {
            return .orange.opacity(0.3)
        } else {
            return color
        }
    }
    
    private struct Constants {
        static let backOfCard = (
            color: Color.red,
            innerPaddingPercentage: 0.15,
            patternBackgroundColorOpacity: 0.3,
            patternBorderWidth: cardBorderWidth * 1.5,
            patternLinesStep: 0.1,
            patternLinesWidth: 2.0,
            patternScaleFactor: 1.5,
            rotation: 45.0
        )
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
            ShapeSetCardView(card1, flipped: true)
            ShapeSetCardView(card2, flipped: true)
            ShapeSetCardView(card3, flipped: true)
            ShapeSetCardView(card1)
        }
        .previewLayout(.fixed(width: 200, height: 300))
    }
}
