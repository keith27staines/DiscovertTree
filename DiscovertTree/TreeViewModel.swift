//
//  TreeViewModel.swift
//  DiscovertTree
//
//  Created by Keith Staines on 25/11/2023.
//

import Foundation
import Observation
import DiscoveryTreeCore

class TreeViewModel: Identifiable {

    weak var delegate: (any TreeViewModelDelegate)?
    let treeId: TreeId
    
    init(treeId: TreeId, delegate: TreeViewModelDelegate?) {
        self.treeId = treeId
        self.delegate = delegate
    }
    
    var ticket: Ticket? {
       try? delegate?.ticketFor(treeId) ?? nil
    }
    
    var children: [TreeViewModel] {
        do {
            guard let children = try delegate?.childrenOf(treeId) else {
                return []
            }
            return children.map { child in
                TreeViewModel.init(treeId: child, delegate: delegate)
            }
        } catch {
            return []
        }
    }
}

extension TreeViewModel: TicketDelegate {
    func insertLeading() {
        delegate?.insertLeading(treeId)
    }
    
    func insertTrailing() {
        delegate?.insertTrailing(treeId)
    }
    
    func insertChild() {
        delegate?.insertChild(treeId)
    }
    
    func insertAbove() {
        delegate?.insertAbove(treeId)
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

