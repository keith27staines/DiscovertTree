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
    @Published var offset = CGSize.zero
    
    let tree: TicketTree
    let undoManager: UndoManager
    weak var delegate: TreeViewModelDelegate?
    
    var ticket: Ticket? {
        tree.content
    }
    
    init(tree: TicketTree, undoManager: UndoManager, delegate: TreeViewModelDelegate) {
        self.tree = tree
        self.undoManager = undoManager
        self.title = tree.content?.title ?? ""
        self.delegate = delegate
        self.createdDate = tree.content?.createdDate ?? Date.distantPast
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
