//
//  NodeRelativePosition.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 02/01/2024.
//

enum NodeRelativePosition {
    case top
    case leading
    case trailing
    case bottom
}

struct NodeDropAcceptance {
    let id: TreeId
    
    func canAcceptDrops(_ position: NodeRelativePosition) -> Bool {
        return true
    }
}
