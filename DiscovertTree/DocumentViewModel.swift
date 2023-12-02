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
            objectWillChange.send()
            let node = try node(with: id)
            let newNode = try node.insertNewTreeAbove()
            nodes[newNode.id] = newNode
            newNode.content = Ticket(title: "New Ticket")
            if newNode.parent == nil {
                tree = newNode
                root = TreeViewModel(treeId: tree.id, delegate: self)
            }
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




