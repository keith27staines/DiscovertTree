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
    @Published var maxX: Int = 0
    @Published var maxY: Int = 0
    @Published var legend: Legend = Legend.pastel
    @Published var scale: CGFloat = 1.0
    @Published var dimensions = Dimensions(scale: 1)
    @Published var selectedObject: SelectedObject = .none
    
    let treeManager: TreeManaging
    var ticketViewModels = [TicketViewModel]()
    var allTicketViewModels = [TreeId: TicketViewModel]()
    var contentSize: CGSize {
        CGSize(
            width: CGFloat(maxX + 1) * dimensions.horizontalStride + dimensions.gutter,
            height: CGFloat(maxY + 1) * dimensions.verticalStride + dimensions.gutter
        )
    }

    var cancellables = Set<AnyCancellable>()
    var eventMonitor: Any?
    let keyMonitor = KeyMonitor(keyCode: .space)
    var ticketInsertMode = NodeType.ticket
    let minMagnification = 0.2
    let maxMagnification = 2.0
    
    convenience init() {
        self.init(tree: makeTestTree())
    }
    
    init(tree: TicketTree) {
        let tm = TreeManager(tree: tree)
        self.treeManager = tm
        tm.delegate = self
        
        ticketViewModels = treeManager.activeNodesDictionary.compactMap {
            (key: TreeId, value: TicketTree) in
            TicketViewModel(
                dimensions: dimensions,
                tree: value,
                delegate: self
            )
        }
        allTicketViewModels = ticketViewModels.toDictionary { $0.treeId }
    
        $scale.sink { [weak self] scale in
            guard let self = self else { return }
            var scale = scale
            scale = max(scale, minMagnification)
            scale = min(scale, maxMagnification)
            dimensions.scale = scale
            setOffsets()
        }.store(in: &cancellables)
    }
}

extension DocumentViewModel: TreeManagerDelegate {

    func viewModelForNode(_ tree: TicketTree) -> TicketViewModel {
        if let vm = allTicketViewModels[tree.id] { return vm }
        let vm = TicketViewModel(
            dimensions: dimensions,
            tree: tree,
            delegate: self
        )
        allTicketViewModels[tree.id] = vm
        return vm
    }
    
    func onNodeDidRegister(_ node: TicketTree) {
        let vm = viewModelForNode(node)
        ticketViewModels.append(vm)
    }
    
    func onNodeDidUnregister(_ node: TicketTree) {
        ticketViewModels.removeAll { vm in
            vm.treeId == node.id
        }
    }
    
    func onTreeDidChange() {
        setOffsets()
    }
}

extension DocumentViewModel {
    
    func documentViewGainedFocus() {
        selectedObject = .document
        treeManager.recursivelySetNodeDropAcceptance(
            node: treeManager.tree.root(),
            value: { node in
                return true
            }
        )
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




