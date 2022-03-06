//
//  SetGame.swift
//  SetGame
//
//  Created by Andres Vazquez on 2022-02-25.
//

import Foundation

struct SetGame {
    private var deck = [SetCard]()
    private(set) var cardsOnTable = [SetCard]()
    private(set) var numberOfMatches = 0
    private var numberOfCardsDrawn = 0
    private let initialNumberOfCards = 12
    private var selectedCards: [SetCard] { cardsOnTable.filter { $0.isSelected } }
    private var matchedCards: [SetCard] { cardsOnTable.filter { $0.isValidMatch == true } }
    var deckIsEmpty: Bool { numberOfCardsDrawn >= deck.count }
    
    init() {
        for numOfSymbols in 1...3 {
            for shape in 0..<3 {
                for shading in 0..<3 {
                    for color in 0..<3 {
                        deck.append(SetCard(numberOfSymbols: numOfSymbols, shape: shape, shading: shading, color: color))
                    }
                }
            }
        }
        
        startNewGame()
    }
    
    private mutating func startNewGame() {
        deck.shuffle()
        cardsOnTable = Array(deck.prefix(initialNumberOfCards))
        numberOfCardsDrawn = initialNumberOfCards
    }
    
    private func matchCards(_ setOfCards: [SetCard]) -> Bool {
        guard setOfCards.count == 3 else { return false }
        
        var isValidMatch = true
        let valuesToCheck = [
            "numberOfSymbols": setOfCards.map { $0.numberOfSymbols },
            "shapes": setOfCards.map { $0.shape },
            "shading": setOfCards.map { $0.shading },
            "color": setOfCards.map { $0.color }
        ]
        
        for (_, values) in valuesToCheck {
            let setOfValues = Set(values)
            // If they are all different: setOfValues.count == 3 is TRUE (there are no duplicates)
            // If they are all the same: setOfValues.count == 1 is TRUE (there are 2 duplicates)
            isValidMatch = isValidMatch && setOfValues.count != 2
        }
        
        return isValidMatch
    }
    
    private mutating func matchSelectedCards() {
        let setOfCards = selectedCards
        let isValidMatch = matchCards(setOfCards)
        
        // set isValidMatch property of the cards
        for index in cardsOnTable.indices {
            if setOfCards.contains(cardsOnTable[index]) {
                cardsOnTable[index].isValidMatch = isValidMatch
            }
        }
    }
    
    private mutating func replaceMatchedCards() {
        let matchedCards = matchedCards
        var newCards = draw3CardsFromDeck()
        
        for index in cardsOnTable.indices.reversed() {
            if matchedCards.contains(cardsOnTable[index]) {
                if let newCard = newCards?.removeFirst(), cardsOnTable.count == initialNumberOfCards {
                    cardsOnTable[index] = newCard
                } else {
                    cardsOnTable.remove(at: index)
                }
            }
        }
    }
    
    private mutating func draw3CardsFromDeck() -> [SetCard]? {
        if numberOfCardsDrawn < deck.count {
            let newCards = deck[numberOfCardsDrawn..<numberOfCardsDrawn + 3]
            numberOfCardsDrawn += 3
            
            return Array(newCards)
        }
        
        return nil
    }
    
    private mutating func resetSelections() {
        for index in cardsOnTable.indices {
            cardsOnTable[index].isSelected = false
            cardsOnTable[index].isValidMatch = nil
        }
    }
    
    
    // MARK: - Intents
    
    mutating func choose(_ card: SetCard) {
        if selectedCards.count == 3 {
            if selectedCards[0].isValidMatch == true {
                replaceMatchedCards()
                numberOfMatches += 1
            } else {
                resetSelections()
            }
        }
        
        if let chosenCardIndex = cardsOnTable.firstIndex(where: { $0.id == card.id }) {
            cardsOnTable[chosenCardIndex].isSelected.toggle()
            
            if selectedCards.count == 3 {
                matchSelectedCards()
            }
        }
    }
    
    mutating func deal3cards() {
        if matchedCards.count > 0 {
            replaceMatchedCards()
        } else if let newCards = draw3CardsFromDeck() {
            cardsOnTable.append(contentsOf: newCards)
        }
    }
    
    mutating func restartGame() {
        startNewGame()
    }
    
    func getAMatchingSet() -> TernaryCollection<String>? {
        for index in cardsOnTable.indices {
            if index + 2 < cardsOnTable.count {
                for index2 in index + 1..<cardsOnTable.count {
                    for index3 in index + 2..<cardsOnTable.count {
                        if matchCards([cardsOnTable[index], cardsOnTable[index2], cardsOnTable[index3]]) {
                            return TernaryCollection(cardsOnTable[index].id, cardsOnTable[index2].id, cardsOnTable[index3].id)
                        }
                    }
                }
            }
        }
        
        return nil
    }
}
