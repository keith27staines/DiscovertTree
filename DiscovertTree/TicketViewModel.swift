//
//  TicketViewModel.swift
//  DiscovertTree
//
//  Created by Keith Staines on 27/11/2023.
//

import SwiftUI
import DiscoveryTreeCore

final class TicketViewModel: ObservableObject, Identifiable {
    
    @Published var title: String
    @Published var createdDate: Date
    @Published var ticketState: TicketState
    @Published var offset = CGSize()
    
    let tree: TicketTree
    weak var delegate: TreeViewModelDelegate?
    
    var ticket: Ticket {
        Ticket(title: title, createdDate: createdDate, state: ticketState)
    }
    
    init(tree: TicketTree, delegate: TreeViewModelDelegate) {
        self.tree = tree
        self.title = tree.content?.title ?? "New Ticket"
        self.delegate = delegate
        self.createdDate = tree.content?.createdDate ?? Date()
        self.ticketState = tree.content?.state ?? .todo
    }
}

extension TicketViewModel {
    func insertLeading() {
        delegate?.insertNewNodeBefore(tree.id)
    }
    
    func insertTrailing() {
        delegate?.insertNewNodeAfter(tree.id)
    }
    
    func insertChild() {
        delegate?.insertChild(tree.id)
    }
    
    func insertAbove() {
        delegate?.insertNewNodeAbove(tree.id)
    }
    
    func delete() {
        delegate?.delete(tree.id)
    }
    
}

protocol TreeViewModelDelegate: AnyObject {
    func childrenOf(_ id: TreeId) throws -> [TreeId]
    func ticketFor(_ id: TreeId) throws -> Ticket?
    func insertNewNodeAbove(_ id: TreeId)
    func insertNewNodeBefore(_ id: TreeId)
    func insertNewNodeAfter(_ id: TreeId)
    func insertChild(_ id: TreeId)
    func delete(_ id: TreeId)
}

protocol TicketDelegate: AnyObject {
    func insertAbove() -> Void
    func insertLeading() -> Void
    func insertTrailing() -> Void
    func insertChild() -> Void
    func delete() -> Void
}
