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
        VStack {
            toolBar
            scrollingTicketTree
        }
        .onAppear {
            vm.startKeyboardMonitor()
        }
        .onDisappear {
            vm.stopKeyboardMonitor()
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
        .inspector(isPresented: $inspectorIsShown) {
            Text("Inspector")
        }
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
        .frame(width: 200)
    }
    
    var toolBar: some View {
        HStack {
            Spacer()
            scale
                .padding()
            Button {
                inspectorIsShown.toggle()
            } label: {
                Image(systemName: "rectangle.trailingthird.inset.filled")
            }
            .padding(.trailing)
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
