//
//  TicketViewModelDelegate.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 09/12/2023.
//

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
