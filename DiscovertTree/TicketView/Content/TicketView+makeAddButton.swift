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
                vm.addButtonTapped(position: position)
            }
        } label: {
            Image(systemName: "plus")
        }
        .buttonStyle(.borderless)
        .disabled(!vm.showAddButton(position))
        .opacity(vm.showAddButton(position) ? 1 : 0)
    }
}
