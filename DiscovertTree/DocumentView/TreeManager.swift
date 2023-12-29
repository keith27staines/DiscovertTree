//
//  TreeManager.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 29/12/2023.
//

import Foundation

protocol TreeManagerDelegate: AnyObject {
    func viewModelForNode(_ node: TicketTree) -> TicketViewModel
    func onNodeDidRegister(_ node: TicketTree)
    func onNodeDidUnregister(_ node: TicketTree)
    func onTreeDidChange() 
}

protocol TreeManaging: AnyObject {
    var tree: TicketTree { get }
    var activeNodesDictionary: [TreeId: TicketTree] { get }
    func node(with id: TreeId) throws -> TicketTree 
    func move(_ id: TreeId, to newParentId: TreeId, undoManager: UndoManager?) throws
    func insertNewNodeAbove(_ id: TreeId, undoManager: UndoManager?) throws
    func insertNewNodeBefore(_ id: TreeId, undoManager: UndoManager?, type: NodeType) throws
    func insertNewNodeAfter(_ id: TreeId, undoManager: UndoManager?) throws
    func insertChild(_ id: TreeId, undoManager: UndoManager?) throws
    func delete(_ id: TreeId, undoManager: UndoManager?) throws
}

final class TreeManager: TreeManaging {
    
    var tree: TicketTree
    var activeNodesDictionary: [TreeId: TicketTree]
    var allNodesDictionary: [TreeId: TicketTree]
    weak var delegate: TreeManagerDelegate?
    
    init(tree: TicketTree) {
        self.tree = tree
        activeNodesDictionary = tree.writeToDictionary([:])
        allNodesDictionary = tree.writeToDictionary([:])
    }
    
    func node(with id: TreeId) throws -> TicketTree {
        guard let node = allNodesDictionary[id]
        else { throw AppError.nodeDoesNotExist }
        return node
    }
    
    func move(_ id: TreeId, to newParentId: TreeId, undoManager: UndoManager?) throws {
        let mover = try node(with: id)
        guard mover.id != newParentId else { return }
        guard mover.parent?.id != newParentId else { return }
        let newParent = try node(with: newParentId)
        guard !mover.contains(newParent) else { return }
        guard let oldParent = mover.parent, let oldChildIndex = mover.childIndex()
        else { throw AppError.parentNodeIsRequired}
        undoManager?.beginUndoGrouping()
        try cutChild(mover, at: oldChildIndex, from: oldParent, undoManager: undoManager)
        try pasteChild(mover, at: 0, under: newParent, undoManager: undoManager)
        resolveCollisions(undoManager: undoManager)
        undoManager?.endUndoGrouping()
        delegate?.onTreeDidChange()
    }
    
    func insertNewNodeAbove(_ id: TreeId, undoManager: UndoManager?) throws {
        let node = try node(with: id)
        let ticket = Ticket()
        let newNode = TicketTree(content: ticket)
        undoManager?.beginUndoGrouping()
        insertNewParent(newNode, above: node, undoManager: undoManager)
        resolveCollisions(undoManager: undoManager)
        undoManager?.endUndoGrouping()
        delegate?.onTreeDidChange()
    }
    
    func insertNewNodeBefore(_ id: TreeId, undoManager: UndoManager?) throws {
        try insertNewNodeBefore(id, undoManager: undoManager, type: .ticket)
    }
    
    func insertNewNodeBefore(_ id: TreeId, undoManager: UndoManager?, type: NodeType) throws {
        let node = try node(with: id)
        guard let parent = node.parent, let index = node.childIndex()
        else { throw AppError.parentNodeIsRequired }
        let ticket = type == .ticket ? Ticket() : nil
        let newNode = TicketTree(content: ticket)
        undoManager?.beginUndoGrouping()
        try addChild(newNode, to: parent, at: index, undoManager: undoManager)
        resolveCollisions(undoManager: undoManager)
        undoManager?.endUndoGrouping()
        delegate?.onTreeDidChange()
    }
    
    func insertNewNodeAfter(_ id: TreeId, undoManager: UndoManager?) throws {
        let node = try node(with: id)
        guard let parent = node.parent, let index = node.childIndex()
        else { throw AppError.parentNodeIsRequired }
        let ticket = Ticket()
        let newNode = TicketTree(content: ticket)
        undoManager?.beginUndoGrouping()
        try addChild(newNode, to: parent, at: index + 1, undoManager: undoManager)
        resolveCollisions(undoManager: undoManager)
        undoManager?.endUndoGrouping()
        delegate?.onTreeDidChange()
    }
    
    func insertChild(_ id: TreeId, undoManager: UndoManager?) throws {
        let parent = try node(with: id)
        let ticket = Ticket()
        let newNode = TicketTree(content: ticket)
        undoManager?.beginUndoGrouping()
        try addChild(newNode, to: parent, at: 0, undoManager: undoManager)
        resolveCollisions(undoManager: undoManager)
        undoManager?.endUndoGrouping()
        delegate?.onTreeDidChange()
    }
    
    func delete(_ id: TreeId, undoManager: UndoManager?) throws {
        let node = try node(with: id)
        guard let parent = node.parent, let index = node.childIndex()
        else { throw AppError.operationNotAllowedOnRoot }
        undoManager?.beginUndoGrouping()
        try deleteChild(node, at: index, from: parent, undoManager: undoManager)
        resolveCollisions(undoManager: undoManager)
        undoManager?.endUndoGrouping()
        delegate?.onTreeDidChange()
    }
}

extension TreeManager {
    
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
                delegate?.onTreeDidChange()
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
                delegate?.onTreeDidChange()
            } catch {
                undoManager?.removeAllActions(withTarget: self)
            }
        }
    }
    
    private func makeOccupancyMap() -> OccupancyMap<Ticket> {
        OccupancyMap(root: tree)
    }
    
    private func register(_ node: TicketTree) {
        activeNodesDictionary[node.id] = node
        allNodesDictionary[node.id] = node
        delegate?.onNodeDidRegister(node)
        node.children.forEach { register($0) }
    }
    
    private func unregister(_ node: TicketTree) {
        activeNodesDictionary[node.id] = nil
        delegate?.onNodeDidUnregister(node)
        node.children.forEach { node in
            unregister(node)
        }
    }
    
    private func resolveCollisions(undoManager: UndoManager?) {
        var map = makeOccupancyMap()
        guard let node = map.priorityCollidingNode() else {
            pruneSpacers(undoManager: undoManager)
            return
        }
        guard let parent = node.parent else { return }
        try? insertNewNodeBefore(parent.id, undoManager: undoManager, type: .spacer)
        map = makeOccupancyMap()
        if map.hasCollisions() {
            resolveCollisions(undoManager: undoManager)
        } else {
            pruneSpacers(undoManager: undoManager)
        }
        return
    }
    
    private func pruneSpacers(undoManager: UndoManager?) {
        for node in activeNodesDictionary.values {
            guard
                node.content == nil,
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

extension TreeManager {
    func insertNewParent(
        _ newParent: TicketTree,
        above node: TicketTree,
        undoManager: UndoManager?
    ) {
        do {
            try node.insertAbove(newParent)
            if newParent.parent == nil { tree = newParent }
            register(newParent)
            delegate?.onTreeDidChange()
            
            undoManager?.registerUndo(withTarget: self) { [weak self] _ in
                guard let self = self else { return }
                undoInsertNewParent(
                    newParent,
                    above: node,
                    undoManager: undoManager
                )
            }
        } catch {
            
        }
    }
    
    func undoInsertNewParent(
        _ newParent: TicketTree,
        above node: TicketTree,
        undoManager: UndoManager?
    ) {
        do {
            if let index = newParent.childIndex() {
                node.removeFromParent()
                _ = try newParent
                    .parent?
                    .replaceChild(at: index, with: node)
            } else {
                node.removeFromParent()
                tree = node
            }
            unregister(newParent)
            delegate?.onTreeDidChange()
            undoManager?.registerUndo(withTarget: self) { vm in
                vm.insertNewParent(
                    newParent,
                    above: node,
                    undoManager: undoManager
                )
            }
        } catch {
            print(error)
        }
    }
    
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
        delegate?.onTreeDidChange()
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
    
    func addChild(
        _ child: TicketTree,
        to parent: TicketTree,
        at index: Int,
        undoManager: UndoManager?
    ) throws {
        undoManager?.beginUndoGrouping()
        try parent.insertChild(child, at: index)
        register(child)
        delegate?.onTreeDidChange()
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
        delegate?.onTreeDidChange()
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
