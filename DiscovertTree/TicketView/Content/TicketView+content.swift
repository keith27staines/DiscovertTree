//
//  TicketView+content.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 04/12/2023.
//

import SwiftUI

extension TicketView {
    
    var content: some View {
        VStack {
            makeAddButton(position: .top)
            Spacer()
            HStack(alignment: .center) {
                makeAddButton(position: .leading)
                Spacer()
                titleField
                Spacer()
                makeAddButton(position: .trailing)
            }
            Spacer()
            makeAddButton(position: .bottom)
        }
    }
}

