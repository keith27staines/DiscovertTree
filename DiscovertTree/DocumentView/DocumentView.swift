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
        VStack {
            HStack {
                Button {
                    withAnimation {
                        vm.undoManager.redo()
                    }
                } label: {
                    Text("Redo")
                }
                .disabled(!vm.undoManager.canRedo)
                
                Button {
                    withAnimation {
                        vm.undoManager.undo()
                    }
                } label: {
                    Text("Undo")
                }
                .disabled(!vm.undoManager.canUndo)
            }

            ScrollView([.horizontal, .vertical]) {
                ZStack {
                    ForEach(vm.ticketViewModels) { vm in
                        TicketView(vm: vm)
                    }
                }
                .frame(
                    width: CGFloat(vm.maxX + 1)*(ticketWidth + gutter),
                    height: CGFloat(vm.maxY + 1)*(ticketHeight + gutter),
                    alignment: .center
                )
                .background(.pink)
            }
        }
    }
    
    func scrollViewOffset() -> CGSize {
        let width = -CGFloat(vm.maxX)*(ticketWidth + gutter)/2
        let height = CGFloat(vm.maxY)*(ticketHeight + gutter)/2 - gutter
        return CGSize(
            width: width,
            height: height
        )
    }
}

#Preview {
    DocumentView()
}

import DiscoveryTreeCore
extension Tree: Identifiable {}
