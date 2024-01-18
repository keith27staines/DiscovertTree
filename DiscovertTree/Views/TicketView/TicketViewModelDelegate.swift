//
//  TicketViewModelDelegate.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 09/12/2023.
//

import SwiftUI

protocol TicketViewModelDelegate: AnyObject {
    var maxExtents: CGPoint { get }
    func childrenOf(_ id: TreeId) throws -> [TreeId]
    func ticketFor(_ id: TreeId) throws -> Ticket?
    func insertNewNodeAbove(_ id: TreeId, undoManager: UndoManager?)
    func insertNewNodeBefore(_ id: TreeId, undoManager: UndoManager?)
    func insertNewNodeAfter(_ id: TreeId, undoManager: UndoManager?)
    func insertChild(_ id: TreeId, undoManager: UndoManager?)
    func delete(_ id: TreeId, undoManager: UndoManager?)
    func ticketViewModelDidChange(_ vm: TicketViewModel)
    func backgroundColorFor(_ state: TicketState) -> Color
    func onNodeDidChangeFocus(_ id: TreeId, hadFocus: Bool, hasFocus: Bool)
    func viewModelsForSubtree(node: TicketTree) throws -> [TicketViewModel]
    func move(
        _ id: TreeId,
        to target: TreeId,
        position: NodeRelativePosition,
        undoManager: UndoManager?
    )
    func undoActionWasRegistered()
}
