//
//  DocumentViewModel+insertSibling.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 05/12/2023.
//

import Foundation

extension DocumentViewModel {
    
    func addChild(
        _ child: TicketTree,
        to parent: TicketTree,
        at index: Int,
        undoManager: UndoManager?
    ) throws {
        undoManager?.beginUndoGrouping()
        try parent.insertChild(child, at: index)
        register(child)
        setOffsets()
        undoManager?.registerUndo(withTarget: self) { vm in
            vm.undoAddChild(
                child,
                to: parent,
                at: index,
                undoManager: undoManager
            )
        }
        undoManager?.endUndoGrouping()
    }
    
    func undoAddChild(
        _ child: TicketTree,
        to parent: TicketTree,
        at index: Int,
        undoManager: UndoManager?
    ) {
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

