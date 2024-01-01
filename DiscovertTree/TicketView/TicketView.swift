//
//  TicketView.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//;

import SwiftUI
import DiscoveryTreeCore

struct TicketView: View {
    var d: TicketViewModelDelegate = Delegate()
    @Environment(\.undoManager) var undoManager
    @FocusState var isTicketFocused: Bool
    @FocusState var isTitleFieldFocused: Bool
    @ObservedObject var vm: TicketViewModel
    @State private var isDropTargeted = false
        
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
        .glow(
            isGlowing: vm.canAcceptDrops && isDropTargeted,
            color: .blue,
            radius: vm.ticketCornerRadius
        )
        .overlay { connectorOverlay }
        .overlay { vm.canAcceptDrops ? dotsOverlay : nil }
        .draggable(vm.treeId) {
            let models = vm.subTreeViewModels()
            let offsets = vm.calculateDragViewOffset()
            TreeView(viewModels: models)
                .frame(width: 2000, height: 2000)
                .opacity(0.6)
                .offset(
                    x: -offsets.x,
                    y: -offsets.y
                )
        }
        .dropDestination(for: TreeId.self) { items, location in
            guard let id = items.first, vm.canAcceptDrops == true
            else {
                return false
            }
            withAnimation {
                vm.onDrop(id, undoManager: undoManager)
            }
            return true
        } isTargeted: {
            isDropTargeted = $0
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
    
    var dotsOverlay: some View {
        ZStack {
            Dot(vm: vm)
                .offset(
                    CGSize(
                        width: -vm.dimensions.horizontalStride/2.0,
                        height: 0
                    )
                )
            
            Dot(vm: vm)
                .offset(
                    CGSize(
                        width: vm.dimensions.horizontalStride/2.0,
                        height: 0
                    )
                )
        }
    }
    
    struct Dot: View {
        @Environment(\.undoManager) var undoManager
        @ObservedObject var vm: TicketViewModel
        @State private var isDropTargeted = false
        var body: some View {
            Image(systemName: "plus.circle.fill")
                .font(.headline)
                .dropDestination(for: TreeId.self) { items, location in
                    guard let id = items.first, vm.canAcceptDrops == true
                    else {
                        return false
                    }
                    withAnimation {
                        vm.onDrop(id, undoManager: undoManager)
                    }
                    return true
                } isTargeted: {
                    isDropTargeted = $0
                }
                .glow(isGlowing: isDropTargeted, color: .blue)
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
    func move(_ id: TreeId, to newParentId: TreeId, undoManager: UndoManager?) {}
    func onNodeDidChangeFocus(_ id: TreeId, hadFocus: Bool, hasFocus: Bool) {}
    func viewModelsForSubtree(node: TicketTree) throws -> [TicketViewModel] {[]}
}

#Preview {
    
    let vm = TicketViewModel(
        dimensions: Dimensions(scale: 1), 
        tree: makeTestTree(),
        delegate: Delegate()
    )
    return TicketView(vm: vm)
}


