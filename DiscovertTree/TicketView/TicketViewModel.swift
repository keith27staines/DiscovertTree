//
//  TicketViewModel.swift
//  DiscovertTree
//
//  Created by Keith Staines on 27/11/2023.
//

import SwiftUI
import Combine
import DiscoveryTreeCore

final class TicketViewModel: ObservableObject, Identifiable  {
    
    @Published public var title: String
    @Published public var createdDate: Date
    @Published public var ticketState: TicketState
    @Published public var offset = CGSize.zero
    
    public var treeId: TreeId { tree.id }
    public var isStatePickingDisabled: Bool { tree.isRoot }
    public var isDeleteButtonDisabled: Bool { tree.isRoot }
    public var offsetFromRoot: Int { tree.offsetFromRoot() }
    public var depthFromRoot:  Int { tree.depthFromRoot() }
    
    private let tree: TicketTree
    private let undoManager: UndoManager
    private weak var delegate: TreeViewModelDelegate?
    private var cancellables = Set<AnyCancellable>()
    private var ticket: Ticket? { tree.content }
    
    public enum AddButtonPosition {
        case top
        case leading
        case trailing
        case bottom
    }
    
    public func setState(_ new: TicketState) {
        guard let old = ticket?.state else { return }
        setState(new: new, old: old)
    }
    
    public func hasAddButtonAtPosition(_ position: AddButtonPosition) -> Bool {
        switch position {
        case .top: return !tree.isRoot
        case .leading: return !tree.isRoot
        case .trailing: return !tree.isRoot
        case .bottom: return tree.isLeaf
        }
    }
    
    public func onAddButtonTapped(position: AddButtonPosition) {
        switch position {
        case .top: insertAbove()
        case .leading: insertLeading()
        case .trailing: insertTrailing()
        case .bottom: insertChild()
        }
    }
    
    public func onDeleteButtonTapped() {
        delete()
    }

    public init(tree: TicketTree, undoManager: UndoManager, delegate: TreeViewModelDelegate) {
        self.tree = tree
        self.undoManager = undoManager
        self.title = tree.content?.title ?? ""
        self.delegate = delegate
        self.createdDate = tree.content?.createdDate ?? Date.distantPast
        self.ticketState = tree.content?.state ?? .todo
        setupSinks()
    }
    
    public func titleDidLoseFocus() {
        setTitle(new: title, old: ticket?.title ?? "")
    }
}

// MARK: Implementation
extension TicketViewModel {
    
    private func setupSinks() {
        $ticketState
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] state in
                self?.setState(state)
            }
        .store(in: &cancellables)
    }
    
    private func setTitle(_ new: String) {
        guard let old = ticket?.title else { return }
        setTitle(new: new, old: old)
    }
    
    private func undoSetTitle(new: String, old: String) {
        guard var ticket = ticket else { return }
        ticket.title = old
        tree.content = ticket
        title = old
        undoManager.registerUndo(withTarget: self) { vm in
            vm.setTitle(new: new, old: old)
        }
        delegate?.ticketViewModelDidChange(self)
    }
    
    private func setState(new: TicketState, old: TicketState) {
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
    
    private func undoSetState(new: TicketState, old: TicketState) {
        guard var ticket = ticket else { return }
        ticket.state = old
        tree.content = ticket
        ticketState = old
        undoManager.registerUndo(withTarget: self) { vm in
            vm.setState(new: new, old: old)
        }
        delegate?.ticketViewModelDidChange(self)
    }
    
    private func insertLeading() {
        delegate?.insertNewNodeBefore(tree.id)
    }
    
    private func insertTrailing() {
        delegate?.insertNewNodeAfter(tree.id)
    }
    
    private func insertChild() {
        delegate?.insertChild(tree.id)
    }
    
    private func insertAbove() {
        delegate?.insertNewNodeAbove(tree.id)
    }
    
    private func delete() {
        delegate?.delete(tree.id)
    }
    
    private func setTitle(new: String, old: String) {
        guard new != old, var ticket = ticket else { return }
        ticket.title = new
        tree.content = ticket
        title = new
        undoManager.registerUndo(withTarget: self) { vm in
            vm.undoSetTitle(new: new, old: old)
        }
        delegate?.ticketViewModelDidChange(self)
    }
    
}
