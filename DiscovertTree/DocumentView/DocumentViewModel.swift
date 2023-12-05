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
    var activeNodesDictionary: [TreeId: TicketTree]
    var allNodesDictionary: [TreeId: TicketTree]
    let undoManager = UndoManager()
    
    init() {
        tree = makeTestTree()
        activeNodesDictionary = tree.insertIntoDictionary([:])
        allNodesDictionary = tree.insertIntoDictionary([:])
        ticketViewModels = activeNodesDictionary.compactMap { (key: TreeId, value: TicketTree) in
            TicketViewModel(tree: value, delegate: self)
        }
        setOffsets()
    }
}

extension DocumentViewModel {
    
    func node(with id: TreeId) throws -> TicketTree {
        guard let node = allNodesDictionary[id] 
        else { throw AppError.nodeDoesNotExist }
        return node
    }
    
    func register(_ node: TicketTree) {
        activeNodesDictionary[node.id] = node
        allNodesDictionary[node.id] = node
        ticketViewModels.append(
            TicketViewModel(
                tree: node,
                delegate: self
            )
        )
    }
    
    func unregister(_ node: TicketTree) {
        activeNodesDictionary[node.id] = nil
        ticketViewModels.removeAll { vm in
            vm.tree.id == node.id
        }
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




