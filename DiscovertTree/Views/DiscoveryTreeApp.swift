//
//  DiscovertTreeApp.swift
//  DiscovertTree
//
//  Created by Keith Staines on 25/11/2023.
//

import SwiftUI

@main
struct DiscovertTreeApp: App {
    
    @Environment(\.undoManager) var undoManager
    
    var body: some Scene {
        DocumentGroup(newDocument: DocumentViewModel()) { file in
            DocumentView(vm: file.document)
        }
        .commands {
            CommandGroup(replacing: .undoRedo) {
                EmptyView()
            }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
    }
}
