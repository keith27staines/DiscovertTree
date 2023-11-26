//
//  DocumentViewModel.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//

import Observation
import DiscoveryTreeCore

@Observable
class DocumentViewModel {
    var tree = Tree<Ticket>()
    
    init() {
        tree = makeTestTree()
    }
    
    func makeTestTree() -> Tree<Ticket> {
        func ticket(x: Int, y: Int) -> Ticket {
            Ticket(title: "x: \(x), y:\(y)")
        }
        
        let t00 = Tree(content: ticket(x: 0, y: 0))
        let t01 = Tree(content: ticket(x: 0, y: 1))
        let t11 = Tree(content: ticket(x: 1, y: 1))
        let t21 = Tree(content: ticket(x: 2, y: 1))
        let t22 = Tree(content: ticket(x: 2, y: 2))
        try? t00.add(t01)
        try? t00.add(t11)
        try? t00.add(t21)
        try? t21.add(t22)
        return t00
    }
}

extension Tree {
    var x: Int { offsetFromRoot() }
    var y: Int { depthFromRoot() }
}

