//
//  UTType+extension.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 14/12/2023.
//

import Foundation

import UniformTypeIdentifiers

extension UTType {
    static let pdt: UTType = UTType(
        importedAs: "com.keith27staines.discovery-tree"
    )
    
    static let checklistDocument = UTType(exportedAs: "com.example.checklist")
}
