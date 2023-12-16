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
    
    func undoChild(
        _ child: TicketTree,
        at index: Int,
        from parent: TicketTree,
        undoManager: UndoManager?
    ) throws {
        do {
            try parent.insertChild(child, at: index)
            undoManager?.registerUndo(withTarget: self) { vm in
                do {
                    try vm.deleteChild(
                        child,
                        at: index,
                        from: parent,
                        undoManager: undoManager
                    )
                } catch {
                    undoManager?.removeAllActions(withTarget: self)
                }
            }
        } catch {
            undoManager?.removeAllActions(withTarget: self)
        }
    }
}

