//
//  ContentView.swift
//  DiscovertTree
//
//  Created by Keith Staines on 25/11/2023.
//

import SwiftUI
import DiscoveryTreeCore

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            List(1..<50) { i in
                NavigationLink("Row \(i)", value: i)
            }
            .navigationDestination(for: Int.self) {_ in 
                TreeView()
            }
            .navigationTitle("Split View")
        } detail: {
            Text("Please select a row")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
