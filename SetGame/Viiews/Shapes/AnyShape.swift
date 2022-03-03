//
//  AnyShape.swift
//  SetGame
//
//  Created by Andres Vazquez on 2022-03-01.
//

import SwiftUI

struct AnyShape: Shape {
    private let makePath: (CGRect) -> Path
    
    init<S: Shape>(_ shape: S) {
        self.makePath = shape.path(in:)
    }
    
    func path(in rect: CGRect) -> Path {
        makePath(rect)
    }
}
