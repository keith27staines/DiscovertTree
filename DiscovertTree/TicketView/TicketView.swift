//
//  TicketView.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//

import SwiftUI
import DiscoveryTreeCore

struct TicketView: View {
    
    @FocusState var isTitleFieldFocused: Bool
    @ObservedObject var vm: TicketViewModel
        
    var body: some View {
        ZStack {
            background
            content
        }
        .frame(width: ticketWidth, height: ticketHeight)
        .offset(vm.offset)
    }
}

#Preview {
    class Delegate: TreeViewModelDelegate {
        func childrenOf(_ id: TreeId) throws -> [TreeId] { [] }
        func ticketFor(_ id: TreeId) throws -> Ticket? { Ticket() }
        func insertNewNodeAbove(_ id: TreeId) {}
        func insertNewNodeBefore(_ id: TreeId) {}
        func insertNewNodeAfter(_ id: TreeId) {}
        func insertChild(_ id: TreeId) {}
        func delete(_ id: TreeId) {}
        func ticketViewModelDidChange(_ vm: TicketViewModel) {}
    }
    let vm = TicketViewModel(
        tree: makeTestTree(),
        undoManager: UndoManager(),
        delegate: Delegate()
    )
    return TicketView(vm: vm)
}
