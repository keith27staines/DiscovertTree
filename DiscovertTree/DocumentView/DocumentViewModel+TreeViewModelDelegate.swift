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
        try node(with: id).content
    }
    
    func childrenOf(_ id: TreeId) throws -> [TreeId] {
        try node(with: id).children.compactMap { $0.id }
    }
    
    func move(_ id: TreeId, to newParentId: TreeId, undoManager: UndoManager?) -> Bool {
        do {
            let mover = try node(with: id)
            guard mover.id != newParentId else { return false }
            guard mover.parent?.id != newParentId else { return false }
            let newParent = try node(with: newParentId)
            guard !mover.contains(newParent) else { return false }
            guard let oldParent = mover.parent, let oldChildIndex = mover.childIndex()
            else { throw AppError.parentNodeIsRequired}
            undoManager?.beginUndoGrouping()
            try cutChild(mover, at: oldChildIndex, from: oldParent, undoManager: undoManager)
            try pasteChild(mover, at: 0, under: newParent, undoManager: undoManager)
            resolveCollisions(undoManager: undoManager)
            setOffsets()
            undoManager?.endUndoGrouping()
            return true
        } catch {
            print("uh oh")
            return false
        }
    }
    
    func insertNewNodeAbove(_ id: TreeId, undoManager: UndoManager?) {
        do {
            let node = try node(with: id)
            let ticket = ticketInsertMode == .ticket ? Ticket() : nil
            let newNode = TicketTree(content: ticket)
            undoManager?.beginUndoGrouping()
            insertNewParent(newNode, above: node, undoManager: undoManager)
            resolveCollisions(undoManager: undoManager)
            undoManager?.endUndoGrouping()
        } catch {
            print("uh oh")
        }
    }
    
    func insertNewNodeBefore(_ id: TreeId, undoManager: UndoManager?) {
        insertNewNodeBefore(id, undoManager: undoManager, type: ticketInsertMode)
    }
    
    func insertNewNodeBefore(_ id: TreeId, undoManager: UndoManager?, type: NodeType) {
        do {
            let node = try node(with: id)
            guard let parent = node.parent, let index = node.childIndex()
            else { throw AppError.parentNodeIsRequired }
            let ticket = type == .ticket ? Ticket() : nil
            let newNode = TicketTree(content: ticket)
            undoManager?.beginUndoGrouping()
            try addChild(newNode, to: parent, at: index, undoManager: undoManager)
            resolveCollisions(undoManager: undoManager)
            undoManager?.endUndoGrouping()
        } catch {
            print("uh oh")
        }
    }
    
    func insertNewNodeAfter(_ id: TreeId, undoManager: UndoManager?) {
        do {
            let node = try node(with: id)
            guard let parent = node.parent, let index = node.childIndex()
            else { throw AppError.parentNodeIsRequired }
            let ticket = ticketInsertMode == .ticket ? Ticket() : nil
            let newNode = TicketTree(content: ticket)
            undoManager?.beginUndoGrouping()
            try addChild(newNode, to: parent, at: index + 1, undoManager: undoManager)
            resolveCollisions(undoManager: undoManager)
            undoManager?.endUndoGrouping()
        } catch {
            print("uh oh")
            undoManager?.endUndoGrouping()
        }
    }
    
    func insertChild(_ id: TreeId, undoManager: UndoManager?) {
        do {
            let parent = try node(with: id)
            let ticket = ticketInsertMode == .ticket ? Ticket() : nil
            let newNode = TicketTree(content: ticket)
            undoManager?.beginUndoGrouping()
            try addChild(newNode, to: parent, at: 0, undoManager: undoManager)
            resolveCollisions(undoManager: undoManager)
            undoManager?.endUndoGrouping()
        } catch {
            print("uh oh")
        }
    }
    
    func delete(_ id: TreeId, undoManager: UndoManager?) {
        do {
            let node = try node(with: id)
            guard let parent = node.parent, let index = node.childIndex()
            else { throw AppError.operationNotAllowedOnRoot }
            undoManager?.beginUndoGrouping()
            try deleteChild(node, at: index, from: parent, undoManager: undoManager)
            resolveCollisions(undoManager: undoManager)
            undoManager?.endUndoGrouping()
        } catch {
            print("uh oh")
        }
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
