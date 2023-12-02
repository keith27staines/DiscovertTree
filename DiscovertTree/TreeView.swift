//
//  TreeView.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//

import SwiftUI
import DiscoveryTreeCore

struct TreeView: View {
    
    let vm: TreeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TicketView(
                optionalTicket: vm.ticket,
                ticketDelegate: vm
            )
            HStack(alignment: .top, spacing: 16) {
                ForEach(vm.children) { child in
                    TreeView(vm: child)
                }
            }
        }
    }
}

#Preview {
    TreeView(
        vm: TreeViewModel(
            treeId: TreeId(),
            delegate: nil
        )
    )
}
