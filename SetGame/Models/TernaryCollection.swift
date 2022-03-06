//
//  TernaryCollection.swift
//  SetGame
//
//  Created by Andres Vazquez on 2022-03-06.
//

import Foundation

struct TernaryCollection<T> {
    var element1: T
    var element2: T
    var element3: T
    var elements: [T] {
        [element1, element2, element3]
    }
    
    init(_ element1: T, _ element2: T, _ element3: T) {
        self.element1 = element1
        self.element2 = element2
        self.element3 = element3
    }
}
