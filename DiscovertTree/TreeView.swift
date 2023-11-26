//
//  TreeView.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//

import SwiftUI
import DiscoveryTreeCore

struct TreeView: View {
    
    let tree: Tree<Ticket>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TicketView(ticket: tree.content)
            HStack(alignment: .top, spacing: 16) {
                ForEach(tree.children) { child in
                    TreeView(tree: child)
                }
            }
        }
    }
}

#Preview {
    TreeView(tree: DocumentViewModel.makeTestTree())
}
