//
//  TicketVIew+background.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 04/12/2023.
//

import SwiftUI

extension TicketView {
    var background: some View {
        vm.ticketState.theme.mainColor
            .clipShape(
                .rect(
                    cornerRadius: ticketCornerRadius
                )
            )
            .contextMenu {
                Picker(
                    "State",
                    selection: $vm.ticketState
                ) {
                    ForEach(TicketState.allCases, id: \.self) { state in
                        Text(state.description)
                    }
                }
                Divider()
                Button {
                    vm.delete()
                } label: {
                    Label("Delete", systemImage: "globe")
                }
            }
            .focusable()
    }
}
