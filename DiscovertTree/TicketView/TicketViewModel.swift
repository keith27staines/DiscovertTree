//
//  TicketViewModel.swift
//  DiscovertTree
//
//  Created by Keith Staines on 27/11/2023.
//

import SwiftUI
import Combine
import DiscoveryTreeCore

final class TicketViewModel: ObservableObject, Identifiable {
    
    @Published var title: String
    @Published var createdDate: Date
    @Published var ticketState: TicketState
    @Published var offset = CGSize.zero
    
    let tree: TicketTree
    let undoManager: UndoManager
    weak var delegate: TreeViewModelDelegate?
    var cancellables = Set<AnyCancellable>()
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
        setupSinks()
    }
    
    func setupSinks() {
        $ticketState
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] state in
                self?.setState(state)
            }
        .store(in: &cancellables)
    }
    
    func setState(_ new: TicketState) {
        guard let old = ticket?.state else { return }
        setState(new: new, old: old)
    }
    
    func setState(new: TicketState, old: TicketState) {
        guard new != old, var ticket = ticket else { return }
        ticket.state = new
        tree.content = ticket
        ticketState = new
        undoManager.registerUndo(withTarget: self) { vm in
            vm.undoSetState(new: new, old: old)
        }
        delegate?.ticketViewModelDidChange(self)
        print(undoManager.canUndo)
    }
    
    func undoSetState(new: TicketState, old: TicketState) {
        guard var ticket = ticket else { return }
        ticket.state = old
        tree.content = ticket
        ticketState = old
        undoManager.registerUndo(withTarget: self) { vm in
            vm.setState(new: new, old: old)
        }
        delegate?.ticketViewModelDidChange(self)
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
    func ticketViewModelDidChange(_ vm: TicketViewModel)
}
