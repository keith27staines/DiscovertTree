//
//  DocumentViewModel+FileDocument.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 14/12/2023.
//

import SwiftUI
import UniformTypeIdentifiers

extension DocumentViewModel: FileDocument {

    static var readableContentTypes: [UTType] { [.pdt] }

    convenience init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else { throw CocoaError(.fileReadCorruptFile) }
        do {
            let decoder = JSONDecoder()
            let tree = try decoder.decode(TicketTree.self, from: data)
            self.init(tree: tree)
        } catch {
            throw CocoaError(.coderReadCorrupt)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(treeManager.tree)
        return .init(regularFileWithContents: data)
    }
}
