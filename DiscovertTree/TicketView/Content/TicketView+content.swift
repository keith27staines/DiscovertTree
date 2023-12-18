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


enum KeyCode {
    
    case cmd
    case alt
    case ctrl
    case space
    
    var value: UInt16 {
        switch self {
        case .cmd:       return 0x37
        case .alt:       return 0x3A
        case .ctrl:      return 0x3B
        case .space:     return 0x31
        }
    }
}

