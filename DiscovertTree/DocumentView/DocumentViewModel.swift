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

extension DocumentViewModel {
    
    func node(with id: TreeId) throws -> TicketTree {
        guard let node = nodesDictionary[id] 
        else { throw AppError.nodeDoesNotExist }
        return node
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
    
    func unregister(_ node: TicketTree) {
        nodesDictionary[node.id] = nil
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




