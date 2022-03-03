//
//  SetCard.swift
//  SetGame
//
//  Created by Andres Vazquez on 2022-02-25.
//

import Foundation

struct SetCard: Identifiable, Hashable {
    var id = UUID().uuidString
    let numberOfSymbols: Int
    let shape: Int
    let shading: Int
    let color: Int
    var isSelected = false
    var isValidMatch: Bool?
    
    init(numberOfSymbols: Int, shape: Int, shading: Int, color: Int) {
        self.numberOfSymbols = (1...3).contains(numberOfSymbols) ? numberOfSymbols : 1
        self.shape = (0...2).contains(shape) ? shape : 0
        self.shading = (0...2).contains(shading) ? shading : 0
        self.color = (0...2).contains(color) ? color : 0
    }
}
