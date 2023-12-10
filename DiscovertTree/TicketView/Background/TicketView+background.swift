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
            .contentShape(.rect(cornerRadius: ticketCornerRadius))
            .scaleEffect(
                CGSize(width: focusScale.rawValue, height: focusScale.rawValue)
            )
            .focusable()
            .focusEffectDisabled()
            .focused($isTicketFocused)
            .onTapGesture {
                isTicketFocused = true
            }
            .onChange(of: isTicketFocused) { oldValue, newValue in
                print("Ticket \(vm.title) changed isFocused to \(isTicketFocused)")
                withAnimation {
                    setFocusScale()
                }
            }
            .onChange(of: isTitleFieldFocused) { oldValue, newValue in
                withAnimation {
                    setFocusScale()
                }
            }
    }
    
    func setFocusScale() {
        focusScale = (isTicketFocused || isTitleFieldFocused) ?
            .focused : .unfocused
    }
}

