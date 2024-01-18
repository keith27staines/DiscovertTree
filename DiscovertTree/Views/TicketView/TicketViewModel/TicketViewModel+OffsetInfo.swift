//
//  TicketViewModel+OffsetInfo.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 18/01/2024.
//

import Foundation

extension TicketViewModel {
    
    struct OffsetInfo: Identifiable {
        var id: String
        var start: CGPoint
        var end: CGPoint
        
        init(
            dimensions: Dimensions,
            startNode: TicketTree,
            endNode: TicketTree
        ) {
            id = startNode.id.uuid.uuidString + endNode.id.uuid.uuidString
            let ticketWidth = dimensions.ticketWidth
            let ticketHeight = dimensions.ticketHeight
            let horizontalStride = dimensions.horizontalStride
            let verticalStride = dimensions.verticalStride
            start = CGPoint(
                x: ticketWidth/2,
                y: ticketHeight
            )
            end = CGPoint(
                x: CGFloat(endNode.offsetFromRoot() - startNode.offsetFromRoot())
                * horizontalStride + ticketWidth/2,
                y: verticalStride
            )
        }
    }
}
