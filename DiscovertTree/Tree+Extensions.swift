//
//  Tree+Extensions.swift
//  DiscovertTree
//
//  Created by Keith Staines on 02/12/2023.
//

import SwiftUI
import DiscoveryTreeCore

typealias TreeId = Id<TicketTree>

public typealias TicketTree = Tree<Ticket>

extension Tree {
    var x: Int { offsetFromRoot() }
    var y: Int { depthFromRoot() }
}

extension TicketTree {

    func writeToDictionary(_ dictionary: [TreeId:TicketTree] = [:]) -> [TreeId:TicketTree] {
        var dictionary = dictionary
        dictionary[id] = self
        for child in children {
            dictionary = child.writeToDictionary(dictionary)
        }
        return dictionary
    }
}

extension Tree: Equatable {
    public static func == (lhs: DiscoveryTreeCore.Tree<Content>, rhs: DiscoveryTreeCore.Tree<Content>) -> Bool {
        lhs.id == rhs.id
    }
}

extension Tree: Hashable  {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Tree {
    func hasMultipleLeaves() -> Bool {
        if children.count > 1 { return true }
        for child in children {
            if child.hasMultipleLeaves() { return true }
        }        
        return false
    }
    
    func ultimateLeaf() -> Tree<Content>? {
        guard children.count > 1 else { return nil }
        guard children.count > 0 else { return self }
        return children[0].ultimateLeaf()
    }
}
