//
//  Dimensions.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 12/12/2023.
//

import SwiftUI
import Combine

final class Dimensions {
    
    var scale: CGFloat
    
    var ticketWidth: CGFloat { _ticketWidth * scale }
    var ticketHeight: CGFloat { _ticketHeight * scale }
    var ticketCornerRadius: CGFloat { _ticketCornerRadius * scale }
    var gutter: CGFloat { _gutter * scale }
    
    var horizontalStride: CGFloat { ticketWidth + gutter }
    var verticalStride: CGFloat { ticketHeight + gutter }
    
    private let _gutter = CGFloat(32)
    private let _ticketHeight = CGFloat(100)
    private let _ticketWidth = CGFloat(100 * 1.618)
    private let _ticketCornerRadius = CGFloat(10)

    var cancellables =  Set<AnyCancellable>()
    
    init(scale: CGFloat) {
        self.scale = 1 + scale
    }
}
