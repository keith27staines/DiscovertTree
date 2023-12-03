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
        delegate?.insertLeading(tree.id)
    }
    
    func insertTrailing() {
        delegate?.insertTrailing(tree.id)
    }
    
    func insertChild() {
        delegate?.insertChild(tree.id)
    }
    
    func insertAbove() {
        delegate?.insertAbove(tree.id)
    }
    
}

protocol TreeViewModelDelegate: AnyObject {
    func childrenOf(_ id: TreeId) throws -> [TreeId]
    func ticketFor(_ id: TreeId) throws -> Ticket?
    func insertAbove(_ id: TreeId)
    func insertLeading(_ id: TreeId)
    func insertTrailing(_ id: TreeId)
    func insertChild(_ id: TreeId)
}

protocol TicketDelegate: AnyObject {
    func insertAbove() -> ()
    func insertLeading() -> ()
    func insertTrailing() -> ()
    func insertChild() -> ()
}
