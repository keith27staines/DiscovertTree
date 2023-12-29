//
//  DocumentViewModel+pruneSpacers.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 29/12/2023.
//

import Foundation

extension DocumentViewModel {
    func pruneSpacers(undoManager: UndoManager?) {
        for vm in ticketViewModels {
            guard
                vm.nodeType == .spacer,
                let node = try? node(with: vm.treeId),
                let index = node.childIndex(),
                let parent = node.parent
            else { continue }
            do {
                try deleteChild(node, at: index, from: parent, undoManager: nil)
                let map = makeOccupancyMap()
                let hasCollisions = map.hasCollisions()
                try addChild(node, to: parent, at: index, undoManager: nil)
                if !hasCollisions {
                    try deleteChild(node, at: index, from: parent, undoManager: undoManager)
                }
            } catch {
                continue
            }
            
        }
    }
}
