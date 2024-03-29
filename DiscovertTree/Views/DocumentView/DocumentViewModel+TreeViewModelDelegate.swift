//
//  DocumentViewModel+intents.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 04/12/2023.
//

import SwiftUI
import DiscoveryTreeCore

extension DocumentViewModel: TicketViewModelDelegate {
    
    func ticketDidRegisterUndo() {
        objectWillChange.send()
    }
    
    var maxExtents: CGPoint {
        CGPoint(
            x: CGFloat(maxX),
            y: CGFloat(maxY)
        )
    }
    
    func importTree(_ node: TicketTree) {

    }
    
    func viewModelsForSubtree(node: TicketTree) throws -> [TicketViewModel] {
        let nodes = treeManager.nodesFrom(node)
        return nodes.map { viewModelForNode($0) }
    }
    
    func ticketFor(_ id: TreeId) throws -> Ticket? {
        try treeManager.node(with: id).content
    }
    
    func childrenOf(_ id: TreeId) throws -> [TreeId] {
        try treeManager.node(with: id).children.compactMap { $0.id }
    }
    
    func move(
        _ id: TreeId,
        to newParentId: TreeId,
        position: NodeRelativePosition,
        undoManager: UndoManager?
    ) {
        do {
            try treeManager.move(
                id,
                to: newParentId,
                position: position,
                undoManager: undoManager
            )
        } catch {
            print("uh oh")
        }
        setOffsets()
    }
    
    enum SelectedObject {
        case none
        case ticket(TicketViewModel)
        case document
    }
    
    func onNodeDidChangeFocus(_ id: TreeId, hadFocus: Bool, hasFocus: Bool) {
        guard hasFocus && !hadFocus else { return }
        guard let subtree = try? treeManager.node(with: id) else { return }
        let vm = viewModelForNode(subtree)
        let canSubTreeReceiveDrops = !hasFocus
        let treeManager = self.treeManager
        selectedObject = .ticket(vm)
        treeManager.recursivelySetNodeDropAcceptance(
            node: subtree.root(),
            value: { node in
                if node.isOrHasAncestor(node: subtree) {
                    return canSubTreeReceiveDrops
                } else {
                    return true
                }
            }
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
            try treeManager.insertNewNodeBefore(
                id,
                undoManager: undoManager,
                type: type
            )
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
    
    func undoActionWasRegistered() {
        objectWillChange.send()
    }
}
