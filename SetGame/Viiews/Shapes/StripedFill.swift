//
//  StripedFill.swift
//  SetGame
//
//  Created by Andres Vazquez on 2022-03-04.
//

import SwiftUI

struct StripedFill: Shape {
    var step: CGFloat = 0.1
    var lineWidth: CGFloat = 1
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        for xValue in stride(from: 0, through: 1, by: step) {
            let xPosition = rect.maxX * xValue
            path.move(to: CGPoint(x: xPosition, y: 0))
            path.addLine(to: CGPoint(x: xPosition, y: rect.maxY))
        }
        
        return path.strokedPath(StrokeStyle(lineWidth: lineWidth))
    }
}

struct StrippedFill_Previews: PreviewProvider {
    static var previews: some View {
        StripedFill()
            .previewLayout(.fixed(width: 300, height: 300))
    }
}
