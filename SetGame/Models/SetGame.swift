//
//  SetGame.swift
//  SetGame
//
//  Created by Andres Vazquez on 2022-02-25.
//

import Foundation

struct SetGame {
    private(set) var deck = [SetCard]()
    private(set) var cardsOnTable = [SetCard]()
    private(set) var discardPile = [SetCard]()
    private(set) var numberOfMatches = 0
    private(set) var numberOfCardsDealt = 0
    let initialNumberOfCards = 12
    var selectedCards: [SetCard] { cardsOnTable.filter { $0.isSelected } }
    var matchedCards: [SetCard] { cardsOnTable.filter { $0.isValidMatch == true } }
    var deckIsEmpty: Bool { numberOfCardsDealt >= deck.count }
    
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
        numberOfCardsDealt = initialNumberOfCards
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
    
    private mutating func resetSelections() {
        for index in cardsOnTable.indices {
            cardsOnTable[index].isSelected = false
            cardsOnTable[index].isValidMatch = nil
        }
    }
    
    private func resetStatus(ofCards cards: [SetCard]) -> [SetCard] {
        let cleanCards = cards.map { card -> SetCard in
            var card = card
            card.isSelected = false
            card.isValidMatch = nil
            return card
        }
        
        return cleanCards
    }
    
    
    // MARK: - Intents
    mutating func choose(_ card: SetCard) {
        if selectedCards.count == 3 {
            if selectedCards[0].isValidMatch == true {
                discardMatchedCards()
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
    
    mutating func discardMatchedCards() {
        guard matchedCards.count == 3 else { return }
        
        // Remove the discarded cards from the table
        cardsOnTable = cardsOnTable.filter { !matchedCards.contains($0) }
        numberOfMatches += 1
    }
    
    mutating func addToDiscardPile(_ cards: [SetCard]) {
        discardPile.append(contentsOf: resetStatus(ofCards: cards))
    }
    
    mutating func draw3CardsFromDeck() {
        guard numberOfCardsDealt + 3 < deck.count else { return }
        
        var newCards = deck[numberOfCardsDealt..<numberOfCardsDealt + 3]
        numberOfCardsDealt += 3
        
        if matchedCards.count == 3 {
            for index in cardsOnTable.indices {
                if matchedCards.contains(cardsOnTable[index]) {
                    cardsOnTable[index] = newCards.removeFirst()
                }
            }
        } else {
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
