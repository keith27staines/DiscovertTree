//
//  DocumentViewModel+intents.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 04/12/2023.
//

import Foundation
import DiscoveryTreeCore

extension DocumentViewModel: TreeViewModelDelegate {
    
    func ticketFor(_ id: TreeId) throws -> Ticket? {
        try node(with: id).content
    }
    
    func childrenOf(_ id: TreeId) throws -> [TreeId] {
        try node(with: id).children.compactMap { $0.id }
    }
    
    func insertAbove(_ id: TreeId) {
        do {
            let node = try node(with: id)
            let newNode = TicketTree(content: Ticket())
            insert(newNode, above: node)
        } catch {
            
        }
    }
    
    func insertLeading(_ id: TreeId) {
        do {
            let newNode = TicketTree()
            newNode.content = Ticket()
            let node = try node(with: id)
            guard let parent = node.parent 
            else { throw AppError.nodeDoesNotExist }
            let index = node.childIndex() ?? 0
            try parent.insertChild(newNode, at: index)
            register(newNode)
            setOffsets()
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
            register(newNode)
            setOffsets()
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
            register(newNode)
            setOffsets()
        } catch {
            
        }
    }
    
    func delete(_ id: TreeId) {
        
        do {
            let node = try node(with: id)
            guard !node.isRoot else { throw AppError.operationNotAllowedOnRoot }
            try deleteNode(node: node)
            setOffsets()
        } catch {
            
        }
        
        func deleteNode(node: TicketTree) throws {
            node.children.forEach { node in
                delete(node.id)
            }
            node.removeFromParent()
            unregister(node)
        }
    }
}
