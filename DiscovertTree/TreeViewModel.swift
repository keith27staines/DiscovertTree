//
//  TreeViewModel.swift
//  DiscovertTree
//
//  Created by Keith Staines on 25/11/2023.
//

import Foundation
import Observation
import DiscoveryTreeCore

@Observable
class TreeViewModel {
    var title: String
    var tree: Tree<Ticket>
    
    init() {
        title = "Discovery Tree"
        tree = Tree()
        tree.content = Ticket(title: "Discovery Tree Project")
        try? tree.add(
            Tree(
                content: Ticket(title: "Make App project in Xcode")
            )
        )
        try? tree.add(
            Tree(
                content: Ticket(title: "Make Core library Swift package")
            )
        )
        
    }
}
