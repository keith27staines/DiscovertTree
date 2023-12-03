//
//  TicketView.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//

import SwiftUI
import DiscoveryTreeCore

struct TicketView: View {
    
    @ObservedObject var vm: TicketViewModel
        
    var body: some View {
        ZStack {
            background
            content
        }
        .frame(width: ticketWidth, height: ticketHeight)
        .offset(vm.offset)
    }
}

extension TicketView {
    var background: some View {
        (vm.ticketState.theme.mainColor)
            .clipShape(
                .rect(
                    cornerRadius: ticketCornerRadius
                )
            )
    }
    
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
                TextField("Ticket title", text: $vm.title)
                    .foregroundColor(vm.ticketState.theme.accentColor)
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

/*
 .contextMenu {
     Button {
         print("Change country setting")
     } label: {
         Label("Choose Country", systemImage: "globe")
     }
     
     Button {
         print("Enable geolocation")
     } label: {
         Label("Detect Location", systemImage: "location.circle")
     }
 }
 */

#Preview {
    class Delegate: TreeViewModelDelegate {
        func childrenOf(_ id: TreeId) throws -> [TreeId] { [] }
        func ticketFor(_ id: TreeId) throws -> Ticket? { Ticket() }
        func insertAbove(_ id: TreeId) {}
        func insertLeading(_ id: TreeId) {}
        func insertTrailing(_ id: TreeId) {}
        func insertChild(_ id: TreeId) {}
    }
    let vm = TicketViewModel(
        tree: makeTestTree(),
        delegate: Delegate()
    )
    return TicketView(vm: vm)
}
