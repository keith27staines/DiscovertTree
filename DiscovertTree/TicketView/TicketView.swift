//
//  TicketView.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//

import SwiftUI
import DiscoveryTreeCore

struct TicketView: View {
    
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
        func insertAbove(_ id: TreeId) {}
        func insertLeading(_ id: TreeId) {}
        func insertTrailing(_ id: TreeId) {}
        func insertChild(_ id: TreeId) {}
        func delete(_ id: TreeId) {}
    }
    let vm = TicketViewModel(
        tree: makeTestTree(),
        delegate: Delegate()
    )
    return TicketView(vm: vm)
}
