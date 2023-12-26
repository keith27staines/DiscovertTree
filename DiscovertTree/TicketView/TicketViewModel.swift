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
    @Published public var offset = CGSize.zero
    @Published public var dimensions: Dimensions
    @Published public var ticketState: TicketState
    @Published public var insertMode: NodeType
    
    public var ticketWidth: CGFloat { dimensions.ticketWidth }
    public var ticketHeight: CGFloat { dimensions.ticketHeight }
    public var ticketCornerRadius: CGFloat { dimensions.ticketCornerRadius }
    public var gutter: CGFloat { dimensions.gutter }
    public var treeId: TreeId { tree.id }
    public var isStatePickingDisabled: Bool { tree.isRoot }
    public var isDeleteButtonDisabled: Bool { tree.isRoot }
    public var offsetFromRoot: Int { tree.offsetFromRoot() }
    public var depthFromRoot:  Int { tree.depthFromRoot() }
    public var nodeType: NodeType
    
    @Published public var backgroundColor: Color
    
    public struct ChildConnectionInfo: Identifiable {
        let nodeType: NodeType
        let offset: ChildOffset
        let id: String
        let ticketSize: CGSize
        let radius: CGFloat
        
        init(dimensions: Dimensions, parent: TicketTree, child: TicketTree) {
            let offset = ChildOffset(
                dimensions: dimensions,
                parent: parent,
                child: child
            )
            self.id = offset.id
            self.offset = offset
            self.radius = dimensions.gutter / 2
            self.nodeType = child.content == nil ? .spacer : .ticket
            self.ticketSize = CGSize(
                width: dimensions.ticketWidth,
                height: dimensions.ticketHeight
            )
        }
    }
    
    public var childConnectionInfo: [ChildConnectionInfo] {
        tree.children.map { node in
            ChildConnectionInfo(
                dimensions: dimensions,
                parent: tree,
                child: node
            )
        }
    }
    
    private let tree: TicketTree
    private weak var delegate: TicketViewModelDelegate?
    private var cancellables = Set<AnyCancellable>()
    private var ticket: Ticket? { tree.content }
    private var eventMonitor: Any?
    
    public enum AddButtonPosition {
        case top
        case leading
        case trailing
        case bottom
    }
    
    public func hasAddButtonAtPosition(_ position: AddButtonPosition) -> Bool {
        switch position {
        case .top: return !tree.isRoot
        case .leading: return !tree.isRoot
        case .trailing: return !tree.isRoot
        case .bottom: return tree.isLeaf
        }
    }
    
    public func onAddButtonTapped(
        position: AddButtonPosition,
        undoManager: UndoManager?
    ) {
        switch position {
        case .top: insertAbove(undoManager: undoManager)
        case .leading: insertLeading(undoManager: undoManager)
        case .trailing: insertTrailing(undoManager: undoManager)
        case .bottom: insertChild(undoManager: undoManager)
        }
    }
    
    public func onDeleteButtonTapped(undoManager: UndoManager?) {
        delete(undoManager: undoManager)
    }

    public init(
        dimensions: Dimensions,
        tree: TicketTree,
        delegate: TicketViewModelDelegate
    ) {
        self.dimensions = dimensions
        self.tree = tree
        self.title = tree.content?.title ?? ""
        self.delegate = delegate
        self.createdDate = tree.content?.createdDate ?? Date.distantPast
        self.ticketState = tree.content?.state ?? .todo
        self.insertMode = .ticket
        self.nodeType = tree.content == nil ? .spacer : .ticket
        self.backgroundColor = .clear
        if nodeType == .ticket {
            self.backgroundColor = delegate.backgroundColorFor(
                tree.content?.state ?? .todo
            )
        }
    }
    
    public func commitTitle(undoManager: UndoManager?) {
        setTitle(
            new: title,
            old: ticket?.title ?? "",
            undoManager: undoManager
        )
    }
}

// MARK: Implementation
extension TicketViewModel {
    
    struct ChildOffset: Identifiable {
        var id: String
        var start: CGPoint
        var end: CGPoint
        
        init(
            dimensions: Dimensions,
            parent: TicketTree,
            child: TicketTree
        ) {
            id = parent.id.uuid.uuidString + child.id.uuid.uuidString
            let ticketWidth = dimensions.ticketWidth
            let ticketHeight = dimensions.ticketHeight
            let horizontalStride = dimensions.horizontalStride
            let verticalStride = dimensions.verticalStride
            start = CGPoint(
                x: ticketWidth/2,
                y: ticketHeight
            )
            end = CGPoint(
                x: CGFloat(child.offsetFromRoot() - parent.offsetFromRoot())
                * horizontalStride + ticketWidth/2,
                y: verticalStride
            )
        }
    }
    
    private func setTitle(
        new: String,
        old: String,
        undoManager: UndoManager?
    ) {
        guard new != old, var ticket = ticket else { return }
        ticket.title = new
        tree.content = ticket
        title = new
        undoManager?.registerUndo(withTarget: self) { vm in
            vm.undoSetTitle(
                new: new,
                old: old,
                undoManager: undoManager
            )
        }
    }
    
    private func undoSetTitle(
        new: String,
        old: String,
        undoManager: UndoManager?
    ) {
        guard var ticket = ticket else { return }
        ticket.title = old
        tree.content = ticket
        title = old
        undoManager?.registerUndo(withTarget: self) { vm in
            vm.setTitle(
                new: new,
                old: old,
                undoManager: undoManager
            )
        }
    }
    
    func setState(
        new: TicketState,
        old: TicketState,
        undoManager: UndoManager?
    ) {
        guard new != old, var ticket = ticket else { return }
        guard ticket.state != new else { return }
        ticket.state = new
        tree.content = ticket
        backgroundColor = delegate?.backgroundColorFor(new) ?? .white
        ticketState = new
        print("set state \(new) with undoManager \(undoManager?.debugDescription ?? "")")
        print(undoManager != nil)
        undoManager?.registerUndo(withTarget: self) { vm in
            vm.undoSetState(new: new, old: old, undoManager: undoManager)
        }
    }
    
    private func undoSetState(
        new: TicketState,
        old: TicketState,
        undoManager: UndoManager?
    ) {
        guard var ticket = ticket else { return }
        ticket.state = old
        tree.content = ticket
        ticketState = old
        backgroundColor = delegate?.backgroundColorFor(old) ?? .white
        print("set state \(old) with undoManager \(undoManager?.debugDescription ?? "")")

        undoManager?.registerUndo(withTarget: self) { vm in
            vm.setState(
                new: new,
                old: old,
                undoManager: undoManager
            )
        }
    }
    
    private func insertLeading(undoManager: UndoManager?) {
        delegate?.insertNewNodeBefore(
            tree.id,
            undoManager: undoManager
        )
    }
    
    private func insertTrailing(undoManager: UndoManager?) {
        delegate?.insertNewNodeAfter(
            tree.id,
            undoManager: undoManager
        )
    }
    
    private func insertChild(undoManager: UndoManager?) {
        delegate?.insertChild(
            tree.id,
            undoManager: undoManager
        )
    }
    
    private func insertAbove(undoManager: UndoManager?) {
        delegate?.insertNewNodeAbove(
            tree.id,
            undoManager: undoManager
        )
    }
    
    private func delete(undoManager: UndoManager?) {
        delegate?.delete(
            tree.id,
            undoManager: undoManager
        )
    }
}
