//
//  DocumentView.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//

import SwiftUI

struct DocumentView: View {
    
    @Environment(\.undoManager) var undoManager
    @FocusState var isDocumentFocused
    @ObservedObject var vm: DocumentViewModel
    @State var inspectorIsShown = false
    
    var body: some View {
        scrollingTicketTree
            .toolbar {
                toolBar
            }
        .onAppear {
            vm.startKeyboardMonitor()
        }
        .onDisappear {
            vm.stopKeyboardMonitor()
        }
        .inspector(isPresented: $inspectorIsShown) {
            Text("Inspector")
        }
    }
    
    var scrollingTicketTree: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ScrollView([.horizontal, .vertical]) {
                    ticketTree
                        .gesture( magnifyGesture )
                }
                .scrollIndicators(.visible)
                .frame(
                    maxWidth: vm.contentSize.width,
                    maxHeight: vm.contentSize.height
                )
                .background(Color.red.opacity(0.2))
                Spacer()
            }
            Spacer()
        }
        .focusable()
        .focused($isDocumentFocused)
        .focusEffectDisabled()
        .onAppear() { isDocumentFocused = true }
        .onTapGesture { isDocumentFocused = true }
        .gesture( magnifyGesture )
    }
    
    var ticketTree: some View {
        ZStack {
            ForEach(vm.ticketViewModels) { vm in
                TicketView(vm: vm)
            }
        }
        .frame(
            width: vm.contentSize.width,
            height: vm.contentSize.height,
            alignment: .center
        )
        .border(.pink)
    }
    
    var magnifyGesture : some Gesture {
        MagnificationGesture()
            .onChanged { value in
                vm.scale += value/10.0
            }
    }
    
    var scale: some View {
        Slider(
            value: $vm.scale,
            in: vm.minMagnification...vm.maxMagnification
        ) {
            Text("Zoom")
        }
        .frame(width: 100)
    }
    
    var toolBar: some View {
        HStack {
            Spacer()
            Button {
                withAnimation {
                    undoManager?.redo()
                }
            } label: {
                Image(systemName: "arrow.uturn.forward")
                    
            }
            .disabled(!(undoManager?.canRedo ?? false))
            
            Button {
                withAnimation {
                    undoManager?.undo()
                }
            } label: {
                Image(systemName: "arrow.uturn.backward")
            }
            .disabled(!(undoManager?.canUndo ?? false))

            scale
                .padding()
            Button {
                inspectorIsShown.toggle()
            } label: {
                Image(systemName: "rectangle.trailingthird.inset.filled")
            }
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
    DocumentView(vm: DocumentViewModel())
}

import DiscoveryTreeCore
extension Tree: Identifiable {}
