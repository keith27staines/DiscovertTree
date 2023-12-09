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
    
    enum AddButtonPosition {
        case top
        case leading
        case trailing
        case bottom
    }
    
    func showAddButton(_ position: AddButtonPosition) -> Bool {
        switch position {
        case .top: return !tree.isRoot
        case .leading: return !tree.isRoot
        case .trailing: return !tree.isRoot
        case .bottom: return tree.isLeaf
        }
    }
    
    func addButtonTapped(position: AddButtonPosition) {
        switch position {
        case .top: insertAbove()
        case .leading: insertLeading()
        case .trailing: insertTrailing()
        case .bottom: insertChild()
        }
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
    
    func setTitle(_ new: String) {
        guard let old = ticket?.title else { return }
        setTitle(new: new, old: old)
    }
    
    func titleDidLoseFocus() {
        setTitle(new: title, old: ticket?.title ?? "")
    }
    
    func setTitle(new: String, old: String) {
        guard new != old, var ticket = ticket else { return }
        ticket.title = new
        tree.content = ticket
        title = new
        undoManager.registerUndo(withTarget: self) { vm in
            vm.undoSetTitle(new: new, old: old)
        }
        delegate?.ticketViewModelDidChange(self)
    }
    
    func undoSetTitle(new: String, old: String) {
        guard var ticket = ticket else { return }
        ticket.title = old
        tree.content = ticket
        title = old
        undoManager.registerUndo(withTarget: self) { vm in
            vm.setTitle(new: new, old: old)
        }
        delegate?.ticketViewModelDidChange(self)
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
