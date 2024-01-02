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
            makeAddButton(.top)
            Spacer()
            HStack(alignment: .center) {
                makeAddButton(.leading)
                Spacer()
                titleField
                Spacer()
                makeAddButton(.trailing)
            }
            Spacer()
            makeAddButton(.bottom)
        }
    }
}

