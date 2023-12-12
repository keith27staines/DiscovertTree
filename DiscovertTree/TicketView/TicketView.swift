//
//  TicketView.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//

import SwiftUI
import DiscoveryTreeCore

struct TicketView: View {
    @FocusState var isTicketFocused: Bool
    @FocusState var isTitleFieldFocused: Bool
    @ObservedObject var vm: TicketViewModel
        
    var body: some View {
        ZStack {
            background
            content
            ForEach(vm.childOffsets) { offset in
                ConnectorView(offset: offset, radius: vm.gutter/2)
            }
        }
        .frame(width: vm.ticketWidth, height: vm.ticketHeight)
        .offset(vm.offset)
    }
}

struct ConnectorView: View {
    
    let offset: TicketViewModel.ChildOffset
    let radius: CGFloat
    
    var body: some View {
        var path = Path()
        path.move(to: offset.start)
        if offset.end.x == offset.start.x {
            path.addLine(to: offset.end)
        }
        if offset.end.x > offset.start.x {
            let center1 = CGPoint(x: offset.start.x + radius, y: offset.start.y)
            path.addArc(center: center1, radius: radius, startAngle: Angle(degrees: 180.0), endAngle: Angle(degrees: 90), clockwise: true)
            path.addLine(to: CGPoint(x: offset.end.x - radius, y: offset.start.y +  radius))
            let center2 = CGPoint(x: offset.end.x - radius, y: offset.end.y)
            path.addArc(center: center2, radius: radius, startAngle: Angle(degrees: 270), endAngle: Angle(degrees: 00), clockwise: false)
        }
        return path.stroke(.blue)
    }
}

#Preview {
    class Delegate: TreeViewModelDelegate {        
        func childrenOf(_ id: TreeId) throws -> [TreeId] { [] }
        func ticketFor(_ id: TreeId) throws -> Ticket? { Ticket() }
        func insertNewNodeAbove(_ id: TreeId) {}
        func insertNewNodeBefore(_ id: TreeId) {}
        func insertNewNodeAfter(_ id: TreeId) {}
        func insertChild(_ id: TreeId) {}
        func delete(_ id: TreeId) {}
        func ticketViewModelDidChange(_ vm: TicketViewModel) {}
        func backgroundColorFor(_ vm: TicketViewModel) -> Color { .yellow }
    }
    let vm = TicketViewModel(
        dimensions: Dimensions(scale: 1), 
        tree: makeTestTree(),
        undoManager: UndoManager(),
        delegate: Delegate()
    )
    return TicketView(vm: vm)
}
