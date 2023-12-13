//
//  DocumentView.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//

import SwiftUI

struct DocumentView: View {
    
    @FocusState var isDocumentFocused
    @StateObject var vm = DocumentViewModel()
    
    var body: some View {
        VStack {
            toolBar
            ScrollView([.horizontal, .vertical]) {
                ticketTree
            }
            .background()
            .focusable()
            .focused($isDocumentFocused)
            .focusEffectDisabled()
            .onAppear() { isDocumentFocused = true }
            .onTapGesture { isDocumentFocused = true }
            .gesture( magnifyGesture )
        }
    }
    
    var ticketTree: some View {
        ZStack {
            ForEach(vm.ticketViewModels) { vm in
                TicketView(vm: vm)
            }
        }
        .frame(
            width: CGFloat(vm.maxX + 1) * vm.dimensions.horizontalStride,
            height: CGFloat(vm.maxY + 1) * vm.dimensions.verticalStride,
            alignment: .center
        )
        .border(.pink)
    }
    
    var magnifyGesture : some Gesture {
        MagnifyGesture()
            .onChanged { value in
                vm.scale *= 1 + (value.magnification - 1) / 10.0
            }
    }
    
    var scale: some View {
        Slider(value: $vm.scale, in: 0.2...10) {
            Text("Zoom")
        }
            .frame(width: 200)
    }
    
    var toolBar: some View {
        HStack {
            redoButtons
            Spacer()
            scale
        }
    }
    
    var legend: some View {
        HStack {
            LegendView(legend: vm.legend)
                .padding()
                .frame(width: 800, height: 100)
            Spacer()
        }.background(.secondary)
    }
    
    var redoButtons: some View {
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
    }
    
    func scrollViewOffset() -> CGSize {
        let horizontalStride = vm.dimensions.horizontalStride
        let verticalStride = vm.dimensions.verticalStride
        let gutter = vm.dimensions.gutter
        let width = -CGFloat(vm.maxX)*horizontalStride/2
        let height = CGFloat(vm.maxY)*(verticalStride)/2 - gutter
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
