//
//  DocumentViewModel.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//

import SwiftUI
import DiscoveryTreeCore

final class DocumentViewModel: ObservableObject {
    
    var tree: TicketTree
    var nodes: [TreeId: TicketTree]
    lazy var root: TreeViewModel = {
        TreeViewModel(treeId: tree.id, delegate: self)
    }()
    
    init() {
        tree = makeTestTree()
        nodes = tree.insertIntoDictionary([:])
    }
}

extension DocumentViewModel: TreeViewModelDelegate {
    func insertAbove(_ id: TreeId) {
        do {
            let ticket = Ticket(title: "New Ticket")
            let node = try node(with: id)
            let newNode = try node.insertNewTreeAbove()
            
            newNode.content = ticket
            if newNode.parent == nil {
                tree = newNode
            }
            nodes[newNode.id] = newNode
            root = TreeViewModel(treeId: tree.id, delegate: self)
            objectWillChange.send()
        } catch {
            print("Unexpected error")
        }
    }
    
    func insertLeading(_ id: TreeId) {
        do {
            let ticket = Ticket(title: "New Ticket")
            let newNode = Tree<Ticket>()
            newNode.content = ticket
            let node = try node(with: id)
            guard let parent = node.parent else { throw AppError.nodeDoesNotExist }
            let index = node.childIndex() ?? 0
            try parent.insertChild(newNode, at: index)
            nodes[newNode.id] = newNode
            root = TreeViewModel(treeId: tree.id, delegate: self)
            objectWillChange.send()
        } catch {
            
        }
    }
    
    func insertTrailing(_ id: TreeId) {
        do {
            let ticket = Ticket(title: "New Ticket")
            let node = try node(with: id)
            let newNode = Tree<Ticket>()
            newNode.content = ticket
            guard let parent = node.parent else { throw AppError.nodeDoesNotExist }
            let children = parent.children
            let index = node.childIndex() ?? 0
            if index >= children.endIndex {
                try parent.appendChild(newNode)
            } else {
                try parent.insertChild(newNode, at: index + 1)
            }
            nodes[newNode.id] = newNode
            root = TreeViewModel(treeId: tree.id, delegate: self)
            objectWillChange.send()
        } catch {
            
        }
    }
    
    func insertChild(_ id: TreeId) {
        do {
            let ticket = Ticket(title: "New Ticket")
            let node = try node(with: id)
            let newNode = Tree<Ticket>()
            newNode.content = ticket
            try node.insertChild(newNode, at: 0)
            nodes[newNode.id] = newNode
            root = TreeViewModel(treeId: tree.id, delegate: self)
            objectWillChange.send()
        } catch {
            
        }
    }
    
    func ticketFor(_ id: TreeId) throws -> Ticket? {
        try node(with: id).content
    }
    
    func node(with id: TreeId) throws -> TicketTree {
        guard let node = nodes[id] else { throw AppError.nodeDoesNotExist }
        return node
    }
    
    func childrenOf(_ id: TreeId) throws -> [TreeId] {
        try node(with: id).children.compactMap { $0.id }
    }
}




