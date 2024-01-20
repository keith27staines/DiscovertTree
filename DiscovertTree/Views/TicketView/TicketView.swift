//
//  TicketView.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//

import SwiftUI
import DiscoveryTreeCore
import OSLog
import UniformTypeIdentifiers

struct TicketView: View {
   
    @Environment(\.undoManager) var undoManager
    @FocusState var isTicketFocused: Bool
    @FocusState var isTitleFieldFocused: Bool
    @ObservedObject var vm: TicketViewModel
    @State var isFocusable: Bool = false
        
    var body: some View {
        switch vm.nodeType {
        case .ticket: ticket
        case .spacer: EmptyView()
        }
    }
    
    var ticket: some View {
        ZStack {
            background
            content
        }
        .opacity(vm.nodeType == .ticket ? 1 : 0)
        .frame(width: vm.ticketWidth, height: vm.ticketHeight)
        .overlay { connectorOverlay }
        .draggable(vm.tree) {
            let models = vm.subTreeViewModels()
            let offsets = vm.calculateDragViewOffset()
            TreeView(viewModels: models)
                .frame(width: 2000, height: 2000)
                .opacity(0.4)
                .offset(
                    x: -offsets.x,
                    y: -offsets.y
                )
        }
        .offset(vm.offset)
        .onChange(of: isTicketFocused) { oldValue, newValue in
            vm.onTicketDidChangeFocus(hadFocus: oldValue, hasFocus: newValue)
        }
    }

    var connectorOverlay: some View {
        ForEach(vm.childConnectionInfo) { info in
            ConnectorView(info: info)
        }
    }
}

class Delegate: TicketViewModelDelegate {
    var maxExtents: CGPoint = .zero
    func childrenOf(_ id: TreeId) throws -> [TreeId] { [] }
    func ticketFor(_ id: TreeId) throws -> Ticket? { Ticket() }
    func insertNewNodeAbove(_ id: TreeId, undoManager: UndoManager?) {}
    func insertNewNodeBefore(_ id: TreeId, undoManager: UndoManager?) {}
    func insertNewNodeAfter(_ id: TreeId, undoManager: UndoManager?) {}
    func insertChild(_ id: TreeId, undoManager: UndoManager?) {}
    func delete(_ id: TreeId, undoManager: UndoManager?) {}
    func ticketViewModelDidChange(_ vm: TicketViewModel) {}
    func backgroundColorFor(_ state: TicketState) -> Color { .yellow }
    func onNodeDidChangeFocus(_ id: TreeId, hadFocus: Bool, hasFocus: Bool) {}
    func viewModelsForSubtree(node: TicketTree) throws -> [TicketViewModel] {[]}
    func move(
        _ id: TreeId,
        to target: TreeId,
        position: NodeRelativePosition,
        undoManager: UndoManager?
    ) {}
    func undoActionWasRegistered() {}
    func importTree(_ node: TicketTree) {}
}

#Preview {
    
    let vm = TicketViewModel(
        dimensions: Dimensions(scale: 1), 
        tree: makeTestTree(),
        delegate: Delegate()
    )
    return TicketView(vm: vm)
}
