//
//  DocumentViewModel.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//

import SwiftUI
import DiscoveryTreeCore

final class DocumentViewModel: ObservableObject {
    @Published var project = "Document"
    @Published var ticketViewModels = [TicketViewModel]()
    @Published var maxX: Int = 0
    @Published var maxY: Int = 0
    
    var tree: TicketTree
    var nodesDictionary: [TreeId: TicketTree]
    
    init() {
        tree = makeTestTree()
        nodesDictionary = tree.insertIntoDictionary([:])
        ticketViewModels = nodesDictionary.compactMap { (key: TreeId, value: TicketTree) in
            TicketViewModel(tree: value, delegate: self)
        }
        setOffsets()
    }
}

extension DocumentViewModel: TreeViewModelDelegate {
    func insertAbove(_ id: TreeId) {
        do {
            let node = try node(with: id)
            let newNode = try node.insertNewTreeAbove()
            newNode.content = Ticket()
            if newNode.parent == nil { tree = newNode }
            register(newNode)
            setOffsets()
        } catch {
            
        }
    }
    
    func insertLeading(_ id: TreeId) {
        do {
            let newNode = TicketTree()
            newNode.content = Ticket()
            let node = try node(with: id)
            guard let parent = node.parent else { throw AppError.nodeDoesNotExist }
            let index = node.childIndex() ?? 0
            try parent.insertChild(newNode, at: index)
            register(newNode)
            setOffsets()
        } catch {
            
        }
    }
    
    func insertTrailing(_ id: TreeId) {
        do {
            let ticket = Ticket(title: "New Ticket")
            let node = try node(with: id)
            let newNode = Tree<Ticket>()
            newNode.content = ticket
            guard let parent = node.parent else { throw AppError.nodeDoesNotExist }
            let children = parent.children
            let index = node.childIndex() ?? 0
            if index >= children.endIndex {
                try parent.appendChild(newNode)
            } else {
                try parent.insertChild(newNode, at: index + 1)
            }
            register(newNode)
            setOffsets()
        } catch {
            
        }
    }
    
    func insertChild(_ id: TreeId) {
        do {
            let ticket = Ticket(title: "New Ticket")
            let node = try node(with: id)
            let newNode = Tree<Ticket>()
            newNode.content = ticket
            try node.insertChild(newNode, at: 0)
            register(newNode)
            setOffsets()
        } catch {
            
        }
    }
    
    func ticketFor(_ id: TreeId) throws -> Ticket? {
        try node(with: id).content
    }
    
    func node(with id: TreeId) throws -> TicketTree {
        guard let node = nodesDictionary[id] 
        else { throw AppError.nodeDoesNotExist }
        return node
    }
    
    func childrenOf(_ id: TreeId) throws -> [TreeId] {
        try node(with: id).children.compactMap { $0.id }
    }
    
    func register(_ node: TicketTree) {
        nodesDictionary[node.id] = node
        ticketViewModels.append(
            TicketViewModel(
                tree: node,
                delegate: self
            )
        )
    }
    
    func setOffsets() {
        setMaxOffsets()
        for vm in ticketViewModels {
            let x = vm.tree.offsetFromRoot()
            let y = vm.tree.depthFromRoot()
            maxX = max(x, maxX)
            maxY = max(y, maxY)

            let widthCenteringOffset = -CGFloat(maxX)*(ticketWidth + gutter)/2
            let heightCenteringOffset = -CGFloat(maxY)*(ticketHeight + gutter)/2
            let width = (ticketWidth + gutter) * CGFloat(x) + widthCenteringOffset
            let height = (ticketHeight + gutter) * CGFloat(y) + heightCenteringOffset
            vm.offset = CGSize(
                width: width,
                height: height
            )
        }
    }
    
    func setMaxOffsets() {
        maxX = 0
        maxY = 0
        for vm in ticketViewModels {
            let x = vm.tree.offsetFromRoot()
            let y = vm.tree.depthFromRoot()
            maxX = max(x, maxX)
            maxY = max(y, maxY)
        }
    }
}




