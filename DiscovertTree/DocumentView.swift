//
//  DocumentView.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//

import SwiftUI

struct DocumentView: View {
    
    @StateObject var vm = DocumentViewModel()
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack {
                ForEach(vm.ticketViewModels) { vm in
                    TicketView(vm: vm)
                }
            }
            .frame(
                width: CGFloat(vm.maxX + 1)*(200+16),
                height: CGFloat(vm.maxY)*(100+16),
                alignment: .center
            )
            .offset(
                CGSize(
                    width: -vm.maxX*(200+16)/2,
                    height: vm.maxY*(100+16)/2
                )
            )
        }
    }
}

#Preview {
    DocumentView()
}

import DiscoveryTreeCore
extension Tree: Identifiable {}
