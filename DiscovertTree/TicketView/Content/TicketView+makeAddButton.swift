//
//  TicketView+makeAddButton.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 09/12/2023.
//

import SwiftUI

extension TicketView {
    func makeAddButton(position: TicketViewModel.AddButtonPosition) -> some View {
        Button {
            withAnimation {
                vm.onAddButtonTapped(position: position, undoManager: undoManager)
            }
        } label: {
            Image(systemName: vm.insertMode == .ticket ? "plus" : "plus")
                .foregroundStyle(.black.opacity(0.4))
                .font(.headline)
        }
        .buttonStyle(.plain)
        .disabled(!vm.hasAddButtonAtPosition(position))
        .opacity(vm.hasAddButtonAtPosition(position) ? 1 : 0)
    }
}
