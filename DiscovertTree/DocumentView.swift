//
//  DocumentView.swift
//  DiscovertTree
//
//  Created by Keith Staines on 26/11/2023.
//

import SwiftUI

struct DocumentView: View {
    
    @StateObject var vm = DocumentViewModel()
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            TreeView(vm: vm.root)
        }
    }
    
}

#Preview {
    DocumentView()
}

import DiscoveryTreeCore
extension Tree: Identifiable {}
