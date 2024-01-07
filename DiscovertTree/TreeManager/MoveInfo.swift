//
//  MoveInfo.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 06/01/2024.
//

import DiscoveryTreeCore

struct MoveInfo {
    struct ParentChildIndex {
        let parent: TicketTree
        let childIndex: Int
    }
    let movingNode: TicketTree
    let currentParentChildIndex: ParentChildIndex?
    let proposedParentChildIndex: ParentChildIndex
    
    init(mover: TicketTree, proposedParentChildIndex: ParentChildIndex) {
        self.movingNode = mover
        self.proposedParentChildIndex = proposedParentChildIndex
        if
            let currentParent = mover.parent,
            let currentChildIndex = mover.childIndex() {
            self.currentParentChildIndex = ParentChildIndex(
                parent: currentParent,
                childIndex: currentChildIndex
            )
        } else {
            self.currentParentChildIndex = nil
        }
    }
    
    init (
        movingNode: TicketTree,
        targetNode: TicketTree,
        at dropPosition: NodeRelativePosition
    ) throws {
        
        let parent: TicketTree?
        var proposedChildIndex: Int
        switch dropPosition {
        case .top:
            guard !movingNode.hasMultipleLeaves() else {throw AppError.moveIsAmbiguous}
            parent = targetNode.parent
            proposedChildIndex = targetNode.childIndex() ?? 0
        case .leading:
            parent = targetNode.parent
            proposedChildIndex = targetNode.childIndex() ?? 0
            if parent == movingNode.parent && proposedChildIndex > (movingNode.childIndex() ?? 0) {
                // subtract one because we will be cutting the moving node from its parent
                // before inserting it at a higher index on the same parent
                proposedChildIndex -= 1
            }
        case .trailing:
            parent = targetNode.parent
            proposedChildIndex = (targetNode.childIndex() ?? 0) + 1
            if parent == movingNode.parent && proposedChildIndex > (movingNode.childIndex() ?? 0) {
                // subtract one because we will be cutting the moving node from its parent
                // before inserting it at a higher index on the same parent
                proposedChildIndex -= 1
            }
        case .bottom:
            parent = targetNode
            proposedChildIndex = 0
        }
        
        guard let proposedParent = parent
        else { throw AppError.parentNodeIsRequired }
        
        guard !movingNode.contains(proposedParent)
        else { throw AppError.nodeWouldContainSelf }
        
        self.init(
            mover: movingNode,
            proposedParentChildIndex: MoveInfo.ParentChildIndex(
                parent: proposedParent,
                childIndex: proposedChildIndex
            )
        )
    }

}
