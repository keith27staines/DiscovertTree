//
//  DocumentViewModel+insertWithCollisionResolution.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 27/12/2023.
//

import Foundation

extension DocumentViewModel {
    
    func resolveCollisions(undoManager: UndoManager?) {
        var map = makeOccupancyMap()
        guard let node = map.priorityCollidingNode() else { return }
        guard let parent = node.parent else { return }
        insertNewNodeBefore(parent.id, undoManager: undoManager, type: .spacer)
        map = makeOccupancyMap()
        if map.hasCollisions() {
            resolveCollisions(undoManager: undoManager)
        }
        return
    }
}
