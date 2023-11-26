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
                ContentView()
            }
            .navigationTitle("Split View")
        } detail: {
            DocumentView()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
