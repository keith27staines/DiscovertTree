//
//  LegendView.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 10/12/2023.
//

import SwiftUI

struct LegendView: View {
    @State var legend: Legend
    var body: some View {
        HStack {
            Text(legend.name)
            ForEach(legend.states) { state in
                StateView(state: state)
            }
            .foregroundColor(legend.textColor)
        }
    }
    
    struct StateView: View {
        let state: Legend.LegendStateAdapter
        var body: some View {
            ZStack {
                Color(state.backgroundColor)
                Text(state.title)
            }
        }
    }
}

class Legend {
    let name: String
    var states = [LegendStateAdapter]()
    let textColor: Color = .black
    
    init(name: String, states: [LegendStateAdapter] = [LegendStateAdapter]()) {
        self.name = name
        self.states = states
    }
}

extension Legend {
    static var pastel: Legend {
        Legend(
            name: "Pastel shades",
            states: [
                LegendStateAdapter(
                    state: TicketState.todo,
                    backgroundColor: Color("ticketPastelBlue")
                ),
                LegendStateAdapter(
                    state: TicketState.inProgress,
                    backgroundColor: Color("ticketPastelYellow")
                ),
                LegendStateAdapter(
                    state: TicketState.done,
                    backgroundColor: Color("ticketPastelGreen")
                ),
                LegendStateAdapter(
                    state: TicketState.blocked,
                    backgroundColor: Color("ticketPastelBrown")
                ),
                LegendStateAdapter(
                    state: TicketState.deferred,
                    backgroundColor: Color("ticketPastelPink")
                ),
            ]
        )
    }
}

extension Legend {
    struct LegendStateAdapter: Identifiable {
        
        let title: LocalizedStringResource
        var id: String { ticketState.id }
        let ticketState: TicketState
        var backgroundColor: Color
        
        init(state: TicketState, backgroundColor: Color) {
            self.ticketState = state
            self.title = state.title
            self.backgroundColor = backgroundColor
        }
    }
}

#Preview {
    LegendView(legend: Legend.pastel)
}


