//
//  DocumentViewModel+intents.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 04/12/2023.
//

import SwiftUI
import DiscoveryTreeCore

extension DocumentViewModel: TicketViewModelDelegate {
    
    func ticketFor(_ id: TreeId) throws -> Ticket? {
        try treeManager.node(with: id).content
    }
    
    func childrenOf(_ id: TreeId) throws -> [TreeId] {
        try treeManager.node(with: id).children.compactMap { $0.id }
    }
    
    func move(_ id: TreeId, to newParentId: TreeId, undoManager: UndoManager?) {
        do {
            try treeManager.move(id, to: newParentId, undoManager: undoManager)
        } catch {
            print("uh oh")
        }
        setOffsets()
    }
    
    func onNodeDidChangeFocus(_ id: TreeId, hadFocus: Bool, hasFocus: Bool) {
        guard let node = try? treeManager.node(with: id) else { return }
        let canSubTreeReceiveDrops = !hasFocus
        treeManager.recursivelySetNodeDropAcceptance(
            node: node,
            value: canSubTreeReceiveDrops
        )
    }

    func insertNewNodeAbove(_ id: TreeId, undoManager: UndoManager?) {
        do {
            try treeManager.insertNewNodeAbove(id, undoManager: undoManager)
        } catch {
            print("uh oh")
        }
        setOffsets()
    }
    
    func insertNewNodeBefore(_ id: TreeId, undoManager: UndoManager?) {
        insertNewNodeBefore(id, undoManager: undoManager, type: ticketInsertMode)
    }
    
    func insertNewNodeBefore(_ id: TreeId, undoManager: UndoManager?, type: NodeType) {
        do {
            try treeManager.insertNewNodeBefore(id, undoManager: undoManager, type: type)
        } catch {
            print("uh oh")
        }
        setOffsets()
    }
    
    func insertNewNodeAfter(_ id: TreeId, undoManager: UndoManager?) {
        do {
            try treeManager.insertNewNodeAfter(id, undoManager: undoManager)
        } catch {
            print("uh oh")
        }
        setOffsets()
    }
    
    func insertChild(_ id: TreeId, undoManager: UndoManager?) {
        do {
            try treeManager.insertChild(id, undoManager: undoManager)
        } catch {
            print("uh oh")
        }
        setOffsets()
    }
    
    func delete(_ id: TreeId, undoManager: UndoManager?) {
        do {
            try treeManager.delete(id, undoManager: undoManager)
        } catch {
            print("uh oh")
        }
        setOffsets()
    }
    
    func ticketViewModelDidChange(_ vm: TicketViewModel) {
        objectWillChange.send()
    }
    
    func backgroundColorFor(_ state: TicketState) -> Color {
        legend.states.first { adapter in
            adapter.ticketState == state
        }?.backgroundColor ?? .clear
    }
}
