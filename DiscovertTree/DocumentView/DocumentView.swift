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
