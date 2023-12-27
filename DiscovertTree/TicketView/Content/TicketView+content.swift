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
        .dropDestination(for: TreeId.self) { items, location in
            guard let treeId = items.first, treeId != vm.treeId
            else {
                print("drop rejected")
                return false
            }
            guard treeId != vm.treeId else { return false }
            print("drop accepted \(treeId)")
            return true
        } isTargeted: { Bool in
            
        }
    }
}

