//
//  ConnectorView.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 17/12/2023.
//

import SwiftUI

struct ConnectorView: View {
    let info: TicketViewModel.ChildConnectionInfo
    
    var body: some View {
        let offset = info.offset
        let radius = info.radius
        var path = Path()
        path.move(to: offset.start)
        if offset.end.x == offset.start.x {
            path.addLine(to: offset.end)
        }
        if offset.end.x > offset.start.x {
            let center1 = CGPoint(
                x: offset.start.x + radius,
                y: offset.start.y
            )
            path.addArc(
                center: center1,
                radius: radius,
                startAngle: Angle(degrees: 180.0),
                endAngle: Angle(degrees: 90),
                clockwise: true
            )
            path.addLine(
                to: CGPoint(
                    x: offset.end.x - radius,
                    y: offset.start.y +  radius
                )
            )
            let center2 = CGPoint(
                x: offset.end.x - radius,
                y: offset.end.y
            )
            path.addArc(
                center: center2,
                radius: radius,
                startAngle: Angle(degrees: 270),
                endAngle: Angle(degrees: 00),
                clockwise: false
            )
        }
        if info.nodeType == .spacer {
            path.move(
                to: CGPoint(
                    x: offset.end.x,
                    y: offset.end.y
                )
            )
            path.addLine(
                to: CGPoint(
                    x: offset.end.x,
                    y: offset.end.y + info.ticketSize.height
                )
            )
        }
        return path.stroke(.blue)
    }
}
