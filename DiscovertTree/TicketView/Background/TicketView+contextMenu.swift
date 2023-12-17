//
//  TicketView+contextMenu.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 09/12/2023.
//

import SwiftUI

extension TicketView {
    struct ContextMenu: View {
        
        @Environment(\.undoManager) var undoManager
        @ObservedObject var vm: TicketViewModel
        
        var body: some View {
            VStack {
                statePicker
                Divider()
                deleteButton
            }
        }
        
        var statePicker: some View {
            Picker(
                "State",
                selection: $vm.ticketState
            ) {
                ForEach(TicketState.allCases, id: \.self) { state in
                    Text(state.title)
                }
            }
            .disabled(vm.isStatePickingDisabled)
        }
        
        var deleteButton: some View {
            Button {
                withAnimation {
                    vm.onDeleteButtonTapped(undoManager: undoManager)
                }
            } label: {
                Text("Delete")
            }
            .disabled(vm.isDeleteButtonDisabled)
        }
    }
}

