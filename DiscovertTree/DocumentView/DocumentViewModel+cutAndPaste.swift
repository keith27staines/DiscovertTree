//
//  DocumentViewModel+cutAndPaste.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 28/12/2023.
//

import Foundation

extension DocumentViewModel {
    
    func cutChild(
        _ child: TicketTree,
        at index: Int,
        from parent: TicketTree,
        undoManager: UndoManager?
    ) throws {
        child.removeFromParent()
        undoManager?.registerUndo(withTarget: self) { [weak self] vm in
            guard let self = self else { return }
            do {
                try vm.pasteChild(
                    child,
                    at: index,
                    under: parent,
                    undoManager: undoManager
                )
                setOffsets()
            } catch {
                undoManager?.removeAllActions(withTarget: self)
            }
        }
    }
    
    func pasteChild(
        _ child: TicketTree,
        at index: Int,
        under parent: TicketTree,
        undoManager: UndoManager?
    ) throws {
        try parent.insertChild(child, at: index)
        undoManager?.registerUndo(withTarget: self) { [weak self] vm in
            guard let self = self else { return }
            do {
                try vm.cutChild(
                    child,
                    at: index,
                    from: parent,
                    undoManager: undoManager
                )
                setOffsets()
            } catch {
                undoManager?.removeAllActions(withTarget: self)
            }
        }
    }
}
