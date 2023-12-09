//
//  TicketView+title.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 09/12/2023.
//

import SwiftUI

extension TicketView {
    var titleField: some View {
        TextField("Title", text: $vm.title)
            .multilineTextAlignment(.center)
            .textFieldStyle(.plain)
            .onSubmit {
                isTitleFieldFocused = false
            }
            .onChange(of: isTitleFieldFocused) { wasFocused, isFocusedNow in
                if !isFocusedNow { vm.titleDidLoseFocus() }
            }
            .focused($isTitleFieldFocused)
            .foregroundColor(vm.ticketState.theme.accentColor)
    }
}
