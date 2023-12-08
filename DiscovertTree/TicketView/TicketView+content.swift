//
//  TicketView+content.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 04/12/2023.
//

import SwiftUI

extension TicketView {
    
    var content: some View {
        VStack {
            Button {
                withAnimation {
                    vm.insertAbove()
                }
            } label: {
                Image(systemName: "plus")
            }
            
            Spacer()
            
            HStack(alignment: .center) {
                Button {
                    withAnimation {
                        vm.insertLeading()
                    }
                } label: {
                    Image(systemName: "plus")
                }
                Spacer()
                VStack {
                    TextField("Title", text: $vm.title, onCommit: {
                        NSApplication.shared.keyWindow?.makeFirstResponder(nil)
                        vm.titleDidLoseFocus()
                    })
                    .onChange(of: isTitleFieldFocused) { wasFocused, isFocusedNow in
                        if !isFocusedNow { vm.titleDidLoseFocus() }
                    }
                    .focused($isTitleFieldFocused)
                    .foregroundColor(vm.ticketState.theme.accentColor)
                }
                Spacer()
                Button {
                    withAnimation {
                        vm.insertTrailing()
                    }
                } label: {
                    Image(systemName: "plus")
                }

            }
            
            Spacer()
            
            Button {
                withAnimation {
                    vm.insertChild()
                }
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}
