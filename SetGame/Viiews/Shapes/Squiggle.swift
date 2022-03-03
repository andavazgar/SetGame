//
//  Squiggle.swift
//  SetGame
//
//  Created by Andres Vazquez on 2022-02-25.
//

import SwiftUI

struct Squiggle: Shape {
    func path(in rect: CGRect) -> Path {
        let width: (CGFloat) -> CGFloat = { rect.width * $0 }
        let height: (CGFloat) -> CGFloat = { rect.height * $0 }
        
        let curves: [Curve] = [
            Curve(point: (x: 0.85, y: 0.08), ctrl1: (x: 0.18, y: -0.6), ctrl2: (x: 0.55, y: 0.68)),
            Curve(point: (x: 0.7, y: 0.9), ctrl1: (x: 1.02, y: -0.3), ctrl2: (x: 1.12, y: 0.8)),
            Curve(point: (x: 0.2, y: 0.9), ctrl1: (x: 0.5, y: 1), ctrl2: (x: 0.4, y: 0.55)),
            Curve(point: (x: 0, y: 0.55), ctrl1: (x: -0.05, y: 1.25), ctrl2: (x: 0, y: 0.55)),
        ]
        
        
        var path = Path()
        path.move(to: CGPoint(x: width(0), y: height(0.55)))
        
        for curve in curves {
            path.addCurve(
                to: CGPoint(x: width(curve.point.x), y: height(curve.point.y)),
                control1: CGPoint(x: width(curve.ctrl1.x), y: height(curve.ctrl1.y)),
                control2: CGPoint(x: width(curve.ctrl2.x), y: height(curve.ctrl2.y))
            )
        }
        
        return path
    }
    
    private struct Curve {
        let point: (x: CGFloat, y: CGFloat)
        let ctrl1: (x: CGFloat, y: CGFloat)
        let ctrl2: (x: CGFloat, y: CGFloat)
    }
}

struct Squiggle_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Squiggle()
                .stroke(lineWidth: 3)
                .padding()
        }
        .previewLayout(.fixed(width: 300, height: 150))
    }
}
