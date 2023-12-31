//
//  View+extensions.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 31/12/2023.
//

import SwiftUI

extension View {
    @ViewBuilder
    func glow(
        isGlowing: Bool,
        color: Color = .red,
        radius: CGFloat = 20
    ) -> some View {
        switch isGlowing {
        case false:
            self
        case true:
            self
                .shadow(color: color, radius: radius / 3)
                .shadow(color: color, radius: radius / 3)
                .shadow(color: color, radius: radius / 3)
        }
    }
    
    @ViewBuilder
    func glowWithBlur(
        isGlowing: Bool,
        color: Color = .red,
        radius: CGFloat = 20
    ) -> some View {
        switch isGlowing {
        case false:
            self
        case true:
            self
                .blur(radius: radius / 6)
                .glow(isGlowing: true, color: color, radius: radius)
        }
        
    }
    
    @ViewBuilder
    func multicolorGlow(isGlowing: Bool) -> some View {
        switch isGlowing {
        case false:
            self
        case true:
            ZStack {
                ForEach(0..<2) { i in
                    Rectangle()
                        .fill(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center))
                        .frame(width: 400, height: 300)
                        .mask(self.blur(radius: 20))
                        .overlay(self.blur(radius: 5 - CGFloat(i * 5)))
                }
            }
        }
    }
}


