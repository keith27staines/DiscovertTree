//
//  TreeView.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 31/12/2023.
//

import SwiftUI

struct TreeView: View {
    
    let viewModels: [TicketViewModel]
    
    init(viewModels: [TicketViewModel]) {
        self.viewModels  = viewModels
    }
    
    var body: some View {
        ZStack {
            ForEach(viewModels) { vm in
                TicketView(vm: vm)
            }
        }
    }
}


