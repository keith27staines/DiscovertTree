//
//  Tree+Extensions.swift
//  DiscovertTree
//
//  Created by Keith Staines on 02/12/2023.
//

import SwiftUI
import DiscoveryTreeCore

typealias TreeId = Id<TicketTree>

typealias TicketTree = Tree<Ticket>

extension TicketTree {
    var x: Int { offsetFromRoot() }
    var y: Int { depthFromRoot() }
    
    func insertIntoDictionary(_ dictionary: [TreeId:TicketTree] = [:]) -> [TreeId:TicketTree] {
        var dictionary = dictionary
        dictionary[id] = self
        for child in children {
            dictionary = child.insertIntoDictionary(dictionary)
        }
        return dictionary
    }
}
