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

    func insertIntoDictionary(_ dictionary: [TreeId:TicketTree] = [:]) -> [TreeId:TicketTree] {
        var dictionary = dictionary
        dictionary[id] = self
        for child in children {
            dictionary = child.insertIntoDictionary(dictionary)
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
