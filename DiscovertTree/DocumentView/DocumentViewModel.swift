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
    @Published var legend: Legend = Legend.pastel
    
    let undoManager = UndoManager()
    var tree: TicketTree
    var activeNodesDictionary: [TreeId: TicketTree]
    private var allNodesDictionary: [TreeId: TicketTree]
    private var allTicketViewModels = [TreeId: TicketViewModel]()
    
    init() {
        tree = makeTestTree()
        activeNodesDictionary = tree.insertIntoDictionary([:])
        allNodesDictionary = tree.insertIntoDictionary([:])
        ticketViewModels = activeNodesDictionary.compactMap { 
            (key: TreeId, value: TicketTree) in
            TicketViewModel(
                tree: value,
                undoManager: undoManager,
                delegate: self
            )
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
        let vm = viewModelForNode(node)
        ticketViewModels.append(vm)
        node.children.forEach { register($0) }
    }
    
    func viewModelForNode(_ tree: TicketTree) -> TicketViewModel {
        if let vm = allTicketViewModels[tree.id] { return vm }
        let vm = TicketViewModel(
            tree: tree,
            undoManager: undoManager,
            delegate: self
        )
        allTicketViewModels[tree.id] = vm
        return vm
    }
    
    func unregister(_ node: TicketTree) {
        activeNodesDictionary[node.id] = nil
        ticketViewModels.removeAll { vm in
            vm.treeId == node.id
        }
        node.children.forEach { node in
            unregister(node)
        }
    }
    
    func setOffsets() {
        setMaxOffsets()
        for vm in ticketViewModels {
            let x = vm.offsetFromRoot
            let y = vm.depthFromRoot
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
            let x = vm.offsetFromRoot
            let y = vm.depthFromRoot
            maxX = max(x, maxX)
            maxY = max(y, maxY)
        }
    }
}




