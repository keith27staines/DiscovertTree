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
                vm.onAddButtonTapped(position: position)
            }
        } label: {
            Image(systemName: "plus")
                .bold()
                .background(.red)
        }
        .buttonStyle(.borderless)
        .disabled(!vm.hasAddButtonAtPosition(position))
        .opacity(vm.hasAddButtonAtPosition(position) ? 1 : 0)
    }
}
