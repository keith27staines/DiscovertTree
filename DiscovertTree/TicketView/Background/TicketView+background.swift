//
//  TicketView+background.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 04/12/2023.
//

import SwiftUI

extension TicketView {
    
    var background: some View {
        (vm.ticketState.theme.mainColor)
            .clipShape(
                .rect(cornerRadius: ticketCornerRadius)
            )
            .contextMenu {
                ContextMenu(vm: vm)
            }
    }
}

