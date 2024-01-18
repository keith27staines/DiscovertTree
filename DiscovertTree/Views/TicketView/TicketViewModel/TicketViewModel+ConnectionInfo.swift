//
//  TicketViewModel+ConnectionInfo.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 18/01/2024.
//

import Foundation

extension TicketViewModel {
    public struct ConnectionInfo: Identifiable {
        
        let nodeType: NodeType
        let offset: OffsetInfo
        let id: String
        let ticketSize: CGSize
        let radius: CGFloat
        let endNodeHasChildren: Bool
        let endNodeIsSpacer: Bool
        
        init(dimensions: Dimensions, startNode: TicketTree, endNode: TicketTree) {
            let offset = OffsetInfo(
                dimensions: dimensions,
                startNode: startNode,
                endNode: endNode
            )
            self.id = offset.id
            self.offset = offset
            self.radius = dimensions.gutter / 2
            self.nodeType = endNode.content == nil ? .spacer : .ticket
            self.ticketSize = CGSize(
                width: dimensions.ticketWidth,
                height: dimensions.ticketHeight
            )
            self.endNodeHasChildren = !endNode.children.isEmpty
            self.endNodeIsSpacer = endNode.content == nil
        }
    }
}
