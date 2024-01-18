//
//  InspectorView.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 17/01/2024.
//

import SwiftUI

struct InspectorView: View {
    
    let selectedObject: DocumentViewModel.SelectedObject
    
    var body: some View {
        VStack {
            switch selectedObject {
            case .none:
                Text("Nothing selected")
            case .ticket(let vm):
                TicketInspectorView(vm: vm)
            case .document:
                Text("Document")
                Text("Document")
            }
            Spacer()
        }
    }
    
    struct TicketInspectorView: View {
        
        @ObservedObject var vm: TicketViewModel
        
        var body: some View {
            Form {
                Text("TICKET")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                TextEditor(text: $vm.title)
                        .lineLimit(0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityLabel("Title of ticket")
                
                DatePicker(selection: $vm.createdDate, displayedComponents: .date) {
                    Text("Created date")
                }
            }
        }
        
        init(vm: TicketViewModel) {
            self.vm = vm
        }
    }
}
