//
//  TicketView.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//

import SwiftUI
import DiscoveryTreeCore

struct TicketView: View {
    
    let ticket: Ticket?
    let theme = Theme.buttercup
    
    var body: some View {
        ZStack {
            background
            ticketContent
        }
    }
    

}

extension TicketView {
    var background: some View {
        theme
            .mainColor
            .clipShape(
                .rect(
                    cornerRadius: 10
                )
            )
            .frame(
                width: 200,
                height: 100,
                alignment: .center
            )
    }
    
    @ViewBuilder
    var ticketContent: some View {
        if let ticket = ticket {
            Text(ticket.title)
                .font(.title)
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
                .foregroundColor(theme.accentColor)
        } else {
            EmptyView()
        }
    }
}
