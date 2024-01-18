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
    
    @Published var title: String
    @Published var createdDate: Date
    @Published var offset = CGSize.zero
    @Published var dimensions: Dimensions
    @Published var ticketState: TicketState
    @Published var insertMode: NodeType
    @Published var canAcceptDrops = true
    @Published var backgroundColor: Color
    
    var ticketWidth: CGFloat { dimensions.ticketWidth }
    var ticketHeight: CGFloat { dimensions.ticketHeight }
    var ticketCornerRadius: CGFloat { dimensions.ticketCornerRadius }
    var gutter: CGFloat { dimensions.gutter }
    var treeId: TreeId { tree.id }
    var isStatePickingDisabled: Bool { tree.isRoot }
    var isDeleteButtonDisabled: Bool { tree.isRoot }
    var offsetFromRoot: Int { tree.offsetFromRoot() }
    var depthFromRoot:  Int { tree.depthFromRoot() }
    var nodeType: NodeType
    
    private let tree: TicketTree
    private weak var delegate: TicketViewModelDelegate?
    private var cancellables = Set<AnyCancellable>()
    private var ticket: Ticket? { tree.content }
    private var eventMonitor: Any?
    
    func subTreeViewModels() -> [TicketViewModel] {
        guard let delegate = delegate else { return []}
        return (try? delegate.viewModelsForSubtree(node: tree)) ?? []
    }
    
    func calculateDragViewOffset() -> CGPoint {
        guard let delegate = delegate else { return .zero }
        let midpoint = CGPoint(
            x: delegate.maxExtents.x / 2.0,
            y: delegate.maxExtents.y / 2.0
        )
        let dragPoint = CGPoint(
            x: CGFloat(offsetFromRoot),
            y: CGFloat(depthFromRoot)
        )
        let delta = CGPoint(
            x: dragPoint.x - midpoint.x,
            y: dragPoint.y - midpoint.y)

        return CGPoint(
            x: delta.x * dimensions.horizontalStride,
            y: delta.y * dimensions.verticalStride
        )
    }
    
    var childConnectionInfo: [ConnectionInfo] {
        tree.children.compactMap { node in
            if nodeType == .spacer { return nil }
            return ConnectionInfo(
                dimensions: dimensions,
                startNode: tree,
                endNode: node
            )
        }
    }
    
    func hasAddButtonAtPosition(_ position: NodeRelativePosition) -> Bool {
        switch position {
        case .top: return !tree.isRoot
        case .leading: return !tree.isRoot
        case .trailing: return !tree.isRoot
        case .bottom: return true
        }
    }
    
    func onDrop(
        _ id: TreeId,
        position: NodeRelativePosition,
        undoManager: UndoManager?
    ) {
        delegate?.move(
            id,
            to: self.treeId,
            position: position,
            undoManager: undoManager
        )
    }
    
    func onAddButtonTapped(
        position: NodeRelativePosition,
        undoManager: UndoManager?
    ) {
        switch position {
        case .top: insertAbove(undoManager: undoManager)
        case .leading: insertLeading(undoManager: undoManager)
        case .trailing: insertTrailing(undoManager: undoManager)
        case .bottom: insertChild(undoManager: undoManager)
        }
    }
    
    func onDeleteButtonTapped(undoManager: UndoManager?) {
        delete(undoManager: undoManager)
    }

    init(
        dimensions: Dimensions,
        tree: TicketTree,
        delegate: TicketViewModelDelegate?
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
            self.backgroundColor = delegate?.backgroundColorFor(
                tree.content?.state ?? .todo
            ) ?? .white
        }
    }
    
    func commitTitle(undoManager: UndoManager?) {
        setTitle(
            new: title,
            old: ticket?.title ?? "",
            undoManager: undoManager
        )
    }
    
    func onTicketDidChangeFocus(hadFocus: Bool, hasFocus: Bool) {
        delegate?.onNodeDidChangeFocus(
            treeId,
            hadFocus: hadFocus,
            hasFocus: hasFocus
        )
    }
}

// MARK: Implementation
extension TicketViewModel {
    
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
            vm.setTitle(
                new: old,
                old: new,
                undoManager: undoManager
            )
        }
        delegate?.undoActionWasRegistered()
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
            vm.setState(new: old, old: new, undoManager: undoManager)
        }
        delegate?.undoActionWasRegistered()
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

//class TitlePropertyManager {
//    
//    weak var vm: TicketViewModel?
//    weak var tree: TicketTree?
//    
//    init(vm: TicketViewModel? = nil, tree: TicketTree? = nil) {
//        self.vm = vm
//        self.tree = tree
//    }
//    
//    func setTitle(
//        new: String,
//        old: String,
//        undoManager: UndoManager?
//    ) {
//        guard new != old else { return }
//        ticket.title = new
//        tree.content = ticket
//        title = new
//        undoManager?.registerUndo(withTarget: self) { vm in
//            vm.undoSetTitle(
//                new: new,
//                old: old,
//                undoManager: undoManager
//            )
//        }
//    }
//    
//    func undoSetTitle(
//        new: String,
//        old: String,
//        undoManager: UndoManager?
//    ) {
//        guard var ticket = ticket else { return }
//        ticket.title = old
//        tree.content = ticket
//        title = old
//        undoManager?.registerUndo(withTarget: self) { vm in
//            vm.setTitle(
//                new: new,
//                old: old,
//                undoManager: undoManager
//            )
//        }
//    }
//
//    
//    
//}
