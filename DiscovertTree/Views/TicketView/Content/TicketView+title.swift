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
                .lineLimit(3)
                .textFieldStyle(.plain)
                .multilineTextAlignment(.leading)
                .font(.system(size: 16 * vm.dimensions.scale))
                .bold()
                .background(.white)
                .foregroundColor(.black)
                .focusable()
                .focused($isTitleFieldFocused)
                .onSubmit {
                    isTitleFieldFocused = false
                }
                .onChange(of: isTitleFieldFocused) { wasFocused, isFocusedNow in
                    print("Title focus: \(isFocusedNow)")
                    if !isFocusedNow {
                        vm.commitTitle(undoManager: undoManager)
                    }
                    vm.onTicketDidChangeFocus(hadFocus: wasFocused, hasFocus: isFocusedNow)
                }
        }
    }
}
