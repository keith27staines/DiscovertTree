//
//  UTType+extension.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 14/12/2023.
//

import SwiftUI
import DiscoveryTreeCore

import UniformTypeIdentifiers

extension UTType {
    static let pdt: UTType = UTType(importedAs: "com.keith27staines.discovery-tree")
    static let treeId: UTType = UTType(exportedAs: "com.keith27staines.treeId")
}

extension TreeId: Transferable {
    static public var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .treeId)
    }
}
