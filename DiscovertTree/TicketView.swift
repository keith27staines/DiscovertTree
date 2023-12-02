//
//  TicketView.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//

import SwiftUI
import DiscoveryTreeCore

struct TicketView: View {
    
    let optionalTicket: Ticket?
    let theme = Theme.buttercup
    weak var ticketDelegate: TicketDelegate?
    
    var body: some View {
        ZStack {
            background
            ticketPlaceholder
        }
        .frame(width: 200, height: 100)
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
    }
    
    @ViewBuilder
    var ticketPlaceholder: some View {
        if let ticket = optionalTicket {
            TicketContent(
                ticket: ticket,
                theme: theme,
                ticketDelegate: ticketDelegate
            )
        } else {
            EmptyView()
        }
    }
    
    struct TicketContent: View {
        
        @Bindable var ticket: Ticket
        let theme: Theme
        weak var ticketDelegate: TicketDelegate?
        
        var body: some View {
            VStack {
                Button {
                    ticketDelegate?.insertAbove()
                } label: {
                    Image(systemName: "plus")
                }
                Spacer()
                HStack(alignment: .center) {
                    Button {
                        ticketDelegate?.insertAbove()
                    } label: {
                        Image(systemName: "plus")
                    }
                    Spacer()
                    TextField("Ticket title", text: $ticket.title)
                        .foregroundColor(theme.accentColor)
                    Spacer()
                    Button {
                        ticketDelegate?.insertAbove()
                    } label: {
                        Image(systemName: "plus")
                    }

                }
                Spacer()
                Button {
                    ticketDelegate?.insertAbove()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

/*
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
 */

#Preview {
    TicketView(optionalTicket: Ticket(title: "Title"))
}
