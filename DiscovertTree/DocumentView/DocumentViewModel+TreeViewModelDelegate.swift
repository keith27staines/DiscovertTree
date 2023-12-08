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
    
    func insertNewNodeAbove(_ id: TreeId) {
        do {
            let node = try node(with: id)
            let newNode = TicketTree(content: Ticket())
            insertNewParent(newNode, above: node)
        } catch {
            print("uh oh")
        }
    }
    
    func insertNewNodeBefore(_ id: TreeId) {
        do {
            let node = try node(with: id)
            guard let parent = node.parent, let index = node.childIndex()
            else { throw AppError.parentNodeIsRequired }
            let newSibling = TicketTree()
            newSibling.content = Ticket()
            try addChild(newSibling, to: parent, at: index)
        } catch {
            print("uh oh")
        }
    }
    
    func insertNewNodeAfter(_ id: TreeId) {
        do {
            let node = try node(with: id)
            guard let parent = node.parent, let index = node.childIndex()
            else { throw AppError.parentNodeIsRequired }
            let newSibling = TicketTree()
            newSibling.content = Ticket()
            try addChild(newSibling, to: parent, at: index + 1)
        } catch {
            print("uh oh")
        }
    }
    
    func insertChild(_ id: TreeId) {
        do {
            let parent = try node(with: id)
            let child = TicketTree()
            child.content = Ticket()
            try addChild(child, to: parent, at: 0)
        } catch {
            print("uh oh")
        }
    }
    
    func delete(_ id: TreeId) {
        do {
            let node = try node(with: id)
            guard let parent = node.parent, let index = node.childIndex()
            else { throw AppError.operationNotAllowedOnRoot }
            try deleteChild(node, at: index, from: parent)
        } catch {
            print("uh oh")
        }
    }
    
    func ticketViewModelDidChange(_ vm: TicketViewModel) {
        objectWillChange.send()
    }
}
