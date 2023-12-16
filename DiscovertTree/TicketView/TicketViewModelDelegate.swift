//
//  TicketViewModelDelegate.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 09/12/2023.
//

import SwiftUI

protocol TreeViewModelDelegate: AnyObject {
    func childrenOf(_ id: TreeId) throws -> [TreeId]
    func ticketFor(_ id: TreeId) throws -> Ticket?
    func insertNewNodeAbove(_ id: TreeId, undoManager: UndoManager?)
    func insertNewNodeBefore(_ id: TreeId, undoManager: UndoManager?)
    func insertNewNodeAfter(_ id: TreeId, undoManager: UndoManager?)
    func insertChild(_ id: TreeId, undoManager: UndoManager?)
    func delete(_ id: TreeId, undoManager: UndoManager?)
    func ticketViewModelDidChange(_ vm: TicketViewModel)
    func backgroundColorFor(_ vm: TicketViewModel) -> Color
}
