//
//  DocumentViewModel.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//

import Combine
import SwiftUI
import DiscoveryTreeCore

final class DocumentViewModel: ObservableObject {
    @Published var project = "Document"
    @Published var ticketViewModels = [TicketViewModel]()
    @Published var maxX: Int = 0
    @Published var maxY: Int = 0
    @Published var legend: Legend = Legend.pastel
    @Published var scale: CGFloat = 1.0
    @Published var dimensions = Dimensions(scale: 1)
    
    let undoManager = UndoManager()
    var tree: TicketTree
    var activeNodesDictionary: [TreeId: TicketTree]
    private var allNodesDictionary: [TreeId: TicketTree]
    private var allTicketViewModels = [TreeId: TicketViewModel]()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        tree = makeTestTree()
        activeNodesDictionary = tree.insertIntoDictionary([:])
        allNodesDictionary = tree.insertIntoDictionary([:])
        ticketViewModels = activeNodesDictionary.compactMap { 
            (key: TreeId, value: TicketTree) in
            TicketViewModel(
                dimensions: dimensions,
                tree: value,
                undoManager: undoManager,
                delegate: self
            )
        }
    
        $scale.sink { [weak self] scale in
            guard let self = self else { return }
            dimensions.scale = scale
            setOffsets()
        }.store(in: &cancellables)
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
            dimensions: dimensions,
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
            let horizontalStride = dimensions.horizontalStride
            let verticalStride = dimensions.verticalStride
            maxX = max(x, maxX)
            maxY = max(y, maxY)

            let widthCenteringOffset = -CGFloat(maxX) * horizontalStride / 2
            let heightCenteringOffset = -CGFloat(maxY) * verticalStride / 2
            let width = horizontalStride * CGFloat(x) + widthCenteringOffset
            let height = verticalStride * CGFloat(y) + heightCenteringOffset
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




