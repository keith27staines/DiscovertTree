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
        
    var body: some View {
        switch vm.nodeType {
            
        case .ticket:
            ticket
        case .spacer:
            EmptyView()
        }
    }
    
    var ticket: some View {
        ZStack {
            background
            content
            ForEach(vm.childConnectionInfo) { info in
                ConnectorView(info: info)
            }
        }
        .opacity(vm.nodeType == .ticket ? 1 : 0)
        .frame(width: vm.ticketWidth, height: vm.ticketHeight)
        .draggable(vm.treeId)
        .dropDestination(for: TreeId.self) { items, location in
            guard let id = items.first
            else {
                print("drop rejected")
                return false
            }
            withAnimation {
                _ = vm.onDrop(id, undoManager: undoManager)
            }
            return true
        }
        .offset(vm.offset)
    }
    
}

class Delegate: TicketViewModelDelegate {
    func childrenOf(_ id: TreeId) throws -> [TreeId] { [] }
    func ticketFor(_ id: TreeId) throws -> Ticket? { Ticket() }
    func insertNewNodeAbove(_ id: TreeId, undoManager: UndoManager?) {}
    func insertNewNodeBefore(_ id: TreeId, undoManager: UndoManager?) {}
    func insertNewNodeAfter(_ id: TreeId, undoManager: UndoManager?) {}
    func insertChild(_ id: TreeId, undoManager: UndoManager?) {}
    func delete(_ id: TreeId, undoManager: UndoManager?) {}
    func ticketViewModelDidChange(_ vm: TicketViewModel) {}
    func backgroundColorFor(_ state: TicketState) -> Color { .yellow }
    func move(_ id: TreeId, to newParentId: TreeId, undoManager: UndoManager?) -> Bool { true }
}

#Preview {
    
    let vm = TicketViewModel(
        dimensions: Dimensions(scale: 1), 
        tree: makeTestTree(),
        delegate: Delegate()
    )
    return TicketView(vm: vm)
}


