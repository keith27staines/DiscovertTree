//
//  TicketView+title.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 09/12/2023.
//

import SwiftUI

extension TicketView {
    @ViewBuilder
    var titleField: some View {
        if vm.nodeType == .ticket {
            TextField("Title", text: $vm.title, axis: .vertical)
                .textFieldStyle(.plain)
                .multilineTextAlignment(.leading)
                .font(.system(size: 16 * vm.dimensions.scale))
                .bold()
                .background(.white)
                .foregroundColor(.black)
                .disabled(!(isTicketFocused || isTitleFieldFocused))
                .onSubmit {
                    isTitleFieldFocused = false
                }
                .onChange(of: isTitleFieldFocused) { wasFocused, isFocusedNow in
                    if !isFocusedNow { vm.commitTitle(undoManager: undoManager) }
                }
                .focused($isTitleFieldFocused)
        }
    }
}
