//
//  Diamond.swift
//  SetGame
//
//  Created by Andres Vazquez on 2022-02-25.
//

import SwiftUI

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
    
}

struct Diamond_Previews: PreviewProvider {
    static var previews: some View {
        Diamond()
            .previewLayout(.fixed(width: 300, height: 300))
            .aspectRatio(2, contentMode: .fit)
    }
}
