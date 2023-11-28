//
//  TicketViewModel.swift
//  DiscovertTree
//
//  Created by Keith Staines on 27/11/2023.
//

import SwiftUI
import DiscoveryTreeCore

final class TicketViewModel: ObservableObject {
    
    @Published var ticketTitle: String
    @Published var ticketCreatedDate: Date
    
    let tree: Tree<Ticket>?
    
    func insertNewNodeAbove(_ node: Tree<Ticket>? = nil) throws {
        
    }
    
    init(_ tree: Tree<Ticket>) {
        self.tree = tree
        self.ticketTitle = tree.content?.title ?? ""
        self.ticketCreatedDate = tree.content?.createdDate ?? .now
    }
    
}
