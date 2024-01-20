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
    static let pdt: UTType = UTType(exportedAs: "com.keith27staines.discovery-tree")
    static let ticketTree: UTType = UTType(exportedAs: "com.keith27staines.ticket-tree")
}
