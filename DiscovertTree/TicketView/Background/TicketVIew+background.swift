//
//  TicketVIew+background.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 04/12/2023.
//

import SwiftUI

extension TicketView {
    var background: some View {
        (vm.ticketState.theme.mainColor)
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
                .disabled(vm.tree.isRoot)
                
                Divider()
                
                Button {
                    withAnimation {
                        vm.delete()
                    }
                } label: {
                    Text("Delete")
                }
                .disabled(vm.tree.isRoot)
            }
    }
}
