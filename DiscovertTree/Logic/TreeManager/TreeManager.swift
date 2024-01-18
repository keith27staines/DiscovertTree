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
    func insertNewNodeAbove(_ id: TreeId, undoManager: UndoManager?) throws
    func insertNewNodeBefore(_ id: TreeId, undoManager: UndoManager?, type: NodeType) throws
    func insertNewNodeAfter(_ id: TreeId, undoManager: UndoManager?) throws
    func insertChild(_ id: TreeId, undoManager: UndoManager?) throws
    func delete(_ id: TreeId, undoManager: UndoManager?) throws
    func recursivelySetNodeDropAcceptance(node: TicketTree, value: (TicketTree) -> Bool)
    func nodesFrom(_ node: TicketTree) -> [TicketTree]
    func move(
        _ id: TreeId,
        to target: TreeId,
        position: NodeRelativePosition,
        undoManager: UndoManager?
    ) throws
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
    
    func nodesFrom(_ node: TicketTree) -> [TicketTree] {
        var nodes = [node]
        for child in node.children {
            nodes.append(contentsOf: nodesFrom(child))
        }
        return nodes
    }
    
    func recursivelySetNodeDropAcceptance(node: TicketTree, value: (TicketTree) -> Bool) {
        guard let delegate = delegate else { return }
        delegate.viewModelForNode(node).canAcceptDrops = value(node)
        for child in node.children {
            recursivelySetNodeDropAcceptance(node: child, value: value)
        }
    }
    
    func node(with id: TreeId) throws -> TicketTree {
        guard let node = allNodesDictionary[id]
        else { throw AppError.nodeDoesNotExist }
        return node
    }
    
    func move(
        _ movingId: TreeId,
        to targetId: TreeId,
        position: NodeRelativePosition,
        undoManager: UndoManager?
    ) throws {
        let mover = try node(with: movingId)
        let targetNode = try node(with: targetId)
        let info = try MoveInfo(movingNode: mover, targetNode: targetNode, at: position)

        undoManager?.beginUndoGrouping()
        if let currentParentChildIndex = info.currentParentChildIndex {
            try cutChild(
                info.movingNode,
                at: currentParentChildIndex.childIndex,
                from: currentParentChildIndex.parent,
                undoManager: undoManager
            )
        }
        if position == .top {
            let parent = info.proposedParentChildIndex.parent
            try cutChild(
                targetNode,
                at: targetNode.childIndex() ?? 0,
                from: parent,
                undoManager: undoManager
            )
        }
        
        try pasteChild(
            info.movingNode,
            at: info.proposedParentChildIndex.childIndex,
            under: info.proposedParentChildIndex.parent,
            undoManager: undoManager
        )
        
        if position == .top, let ultimateLeaf = mover.ultimateLeaf() {
            try pasteChild(
                targetNode,
                at: 0,
                under: ultimateLeaf,
                undoManager: undoManager
            )
        }
        
        if position == .bottom {
            for child in targetNode.children.reversed() {
                if child == mover { continue }
                try cutChild(child, at: 0, from: targetNode, undoManager: undoManager)
                try pasteChild(child, at: 0, under: mover, undoManager: undoManager)
            }
        }
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
    
    func insertNewNodeBefore(
        _ id: TreeId,
        undoManager: UndoManager?,
        type: NodeType
    ) throws {
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
        try? insertNewNodeBefore(
            parent.id,
            undoManager: undoManager,
            type: .spacer
        )
        map = makeOccupancyMap()
        if map.hasCollisions() {
            resolveCollisions(undoManager: undoManager)
        } else {
            pruneSpacers(undoManager: undoManager)
        }
        return
    }
    
    private func pruneSpacers(undoManager: UndoManager?) {
        var deletionsWerePerformed = false
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
                    deletionsWerePerformed = true
                }
            } catch {
                continue
            }
            
        }
        if deletionsWerePerformed { pruneSpacers(undoManager: undoManager) }
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
