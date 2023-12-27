//
//  DocumentViewModel+deleteChild.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 27/12/2023.
//

import Foundation

extension DocumentViewModel {
    
    func deleteChild(
        _ child: TicketTree,
        at index: Int,
        from parent: TicketTree,
        undoManager: UndoManager?
    ) throws {
        child.children.forEach { node in
            unregister(node)
        }
        child.removeFromParent()
        unregister(child)
        setOffsets()
        undoManager?.registerUndo(withTarget: self) { vm in
            do {
                try vm.addChild(
                    child,
                    to: parent,
                    at: index,
                    undoManager: undoManager
                )
            } catch {
                undoManager?.removeAllActions(withTarget: self)
            }
        }
    }
}
