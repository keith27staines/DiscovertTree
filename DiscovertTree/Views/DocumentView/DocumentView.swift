//
//  DocumentView.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//

import SwiftUI
import AppKit
import OSLog

struct DocumentView: View {
    
    @Environment(\.undoManager) var undoManager
    @FocusState var isDocumentFocused
    @ObservedObject var vm: DocumentViewModel
    @State var inspectorIsShown = false
    @State var magnificationGestureState: CGFloat = 1
    
    var logger = Logger(subsystem: "DictionaryTree", category: "Document View")
    
    var body: some View {
        legend
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
            InspectorView(
                selectedObject: vm.selectedObject
            )
        }
    }
    
    var scrollingTicketTree: some View {
        
        ScrollView([.horizontal, .vertical]) {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ticketTree
                    .frame(
                        maxWidth: vm.contentSize.width,
                        maxHeight: vm.contentSize.height
                    )
                    .background(Color(NSColor.quaternarySystemFill))
                    Spacer()
                }
                Spacer()
            }
        }
        .scrollIndicators(.visible)
        .gesture( magnifyGesture )
        .focusable()
        .focused($isDocumentFocused)
        .focusEffectDisabled()
        .onTapGesture {
            vm.documentViewGainedFocus()
        }
    }
    
    var ticketTree: some View {
        TreeView(viewModels: vm.ticketViewModels)
        .frame(
            width: vm.contentSize.width,
            height: vm.contentSize.height,
            alignment: .center
        )
    }
    
    var magnifyGesture : some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                let gestureRatio = scale / magnificationGestureState
                vm.scale *= gestureRatio
                magnificationGestureState = scale
            }
            .onEnded { scale in
                magnificationGestureState = 1.0
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
                logger.log(level: .info, 
                    """
                    undo Manager \(undoManager)")
                    can undo \(undoManager?.canUndo ?? false)
                    can redo \(undoManager?.canRedo ?? false)
                    """
                )

            } label: {
                Text("Report undo")
            }
            
            Button {
                withAnimation {
                    undoManager?.redo()
                }
            } label: {
                Image(systemName: "arrow.uturn.forward")
                    
            }
            .help("Undo \(undoManager?.redoActionName ?? "")")
            .disabled(!(undoManager?.canRedo ?? false))
            .keyboardShortcut(KeyEquivalent("Z"), modifiers: [.shift, .command])
            
            Button {
                withAnimation {
                    undoManager?.undo()
                }
            } label: {
                Image(systemName: "arrow.uturn.backward")
            }
            .help("Undo \(undoManager?.undoActionName ?? "")")
            .disabled(!(undoManager?.canUndo ?? false))
            .keyboardShortcut(KeyEquivalent("Z"), modifiers: .command)
            
            scale
            .help("Adjust magnification")
            .padding(.leading)
            
            Button {
                inspectorIsShown.toggle()
            } label: {
                Image(systemName: "rectangle.trailingthird.inset.filled")
            }
            .help("Show or hide inspectors")
            .padding(.leading)
        }
    }
    
    var legend: some View {
        LegendView(legend: vm.legend)
                .padding()
                .frame(width: 800, height: 64)
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


