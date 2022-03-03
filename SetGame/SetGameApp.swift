//
//  SetGameApp.swift
//  SetGame
//
//  Created by Andres Vazquez on 2022-02-25.
//

import SwiftUI

@main
struct SetGameApp: App {
    private let game = ShapesSetGame()
    
    var body: some Scene {
        WindowGroup {
            ShapeSetGameView(game: game)
        }
    }
}
