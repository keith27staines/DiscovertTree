//
//  TicketView.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//

import SwiftUI
import DiscoveryTreeCore

struct TicketView: View {
    var d: TreeViewModelDelegate = Delegate()
    @Environment(\.undoManager) var undoManager
    @FocusState var isTicketFocused: Bool
    @FocusState var isTitleFieldFocused: Bool
    @ObservedObject var vm: TicketViewModel
        
    var body: some View {
        ZStack {
            background
            content
            ForEach(vm.childOffsets) { offset in
                ConnectorView(
                    offset: offset,
                    radius: vm.gutter/2
                )
            }
        }
        .frame(width: vm.ticketWidth, height: vm.ticketHeight)
        .offset(vm.offset)
    }
}

class Delegate: TreeViewModelDelegate {
    func childrenOf(_ id: TreeId) throws -> [TreeId] { [] }
    func ticketFor(_ id: TreeId) throws -> Ticket? { Ticket() }
    func insertNewNodeAbove(_ id: TreeId, undoManager: UndoManager?) {}
    func insertNewNodeBefore(_ id: TreeId, undoManager: UndoManager?) {}
    func insertNewNodeAfter(_ id: TreeId, undoManager: UndoManager?) {}
    func insertChild(_ id: TreeId, undoManager: UndoManager?) {}
    func delete(_ id: TreeId, undoManager: UndoManager?) {}
    func ticketViewModelDidChange(_ vm: TicketViewModel) {}
    func backgroundColorFor(_ state: TicketState) -> Color { .yellow }
}

#Preview {
    
    let vm = TicketViewModel(
        dimensions: Dimensions(scale: 1), 
        tree: makeTestTree(),
        delegate: Delegate()
    )
    return TicketView(vm: vm)
}


