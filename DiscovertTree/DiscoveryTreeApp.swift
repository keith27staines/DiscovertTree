//
//  DiscovertTreeApp.swift
//  DiscovertTree
//
//  Created by Keith Staines on 25/11/2023.
//

import SwiftUI

@main
struct DiscovertTreeApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: DocumentViewModel()) { file in
            DocumentView(vm: file.document)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unifiedCompact)
    }
}
