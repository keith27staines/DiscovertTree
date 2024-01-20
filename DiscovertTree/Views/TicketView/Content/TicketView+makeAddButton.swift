//
//  TicketView+makeAddButton.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 09/12/2023.
//

import SwiftUI

extension TicketView {
    @ViewBuilder
    func makeAddButton(_ position: NodeRelativePosition) -> some View {
        if vm.canAcceptDrops {
            AddButton(vm: vm, position: position)
        }
    }
}

extension TicketView {
    
    struct AddButton: View {
        @State var isDropTargeted = false
        @Environment(\.undoManager) var undoManager
        @ObservedObject var vm: TicketViewModel
        var position: NodeRelativePosition
        
        var body: some View {
            Button {
                withAnimation {
                    vm.onAddButtonTapped(position: position, undoManager: undoManager)
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.black)
                    .font(.headline)
            }
            .buttonStyle(.plain)
            .disabled(!vm.hasAddButtonAtPosition(position))
            .opacity(vm.hasAddButtonAtPosition(position) ? 1 : 0)
            .dropDestination(for: TicketTree.self) { items, location in
                guard let id = items.first?.id, vm.canAcceptDrops == true
                else {
                    return false
                }
                withAnimation {
                    vm.onDrop(id, position: position, undoManager: undoManager)
                }
                return true
            } isTargeted: {
                isDropTargeted = $0
            }
            .glow(isGlowing: isDropTargeted)
        }
    }
}

