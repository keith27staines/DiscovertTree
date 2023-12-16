//
//  TicketView+background.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 04/12/2023.
//

import SwiftUI

extension TicketView {
    
    var background: some View {
        vm.backgroundColor
            .clipShape(
                .rect(cornerRadius: vm.ticketCornerRadius)
            )
            .contextMenu {
                ContextMenu(vm: vm)
            }
            .onChange(of: vm.ticketState) {
                oldState,
                newState in
                vm.setState(
                    new: newState,
                    old: oldState,
                    undoManager: undoManager
                )
            }
            .contentShape(.rect(cornerRadius: vm.ticketCornerRadius))
            .focusable()
            .focusEffectDisabled()
            .focused($isTicketFocused)
            .onTapGesture {
                isTicketFocused = true
            }
            .shadow(radius: isTicketFocused || isTitleFieldFocused ? 5: 0)
    }
}

