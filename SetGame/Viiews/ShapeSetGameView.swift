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
    
    var body: some View {
        VStack {
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
            
            AspectVGrid(items: game.cardsOnTable, minimumWidth: 65, aspectRatio: 2/3) { card in
                ShapeSetCardView(card: card, hinted: hintedCards?.elements.contains(card.id) ?? false)
                    .onTapGesture {
                        game.choose(card)
                    }
            }
            
            HStack {
                Button {
                    game.restartGame()
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                            .foregroundStyle(.blue)
                        Text("New Game")
                    }
                    .padding()
                    .background(Capsule().fill(.gray))
                }
                
                if !game.deckIsEmpty {
                    Button {
                        game.deal3cards()
                    } label: {
                        Label("Deal 3 cards", systemImage: "plus.rectangle.portrait.fill")
                            .padding()
                            .background(Capsule().fill(.gray))
                    }
                }
            }
            .font(.title2)
            .symbolRenderingMode(.multicolor)
            .foregroundColor(.white)
            .shadow(color: .black, radius: 1)
        }
        .padding(8)
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
