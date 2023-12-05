//
//  DocumentViewModel+insertNewParentAboveNode.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 05/12/2023.
//

import Foundation

extension DocumentViewModel {
    
    func insert(_ newParent: TicketTree, above node: TicketTree) {
        do {
            try node.insertAbove(newParent)
            if newParent.parent == nil { tree = newParent }
            register(newParent)
            setOffsets()
            undoManager.registerUndo(withTarget: self) { [weak self] vm in
                guard let self = self else { return }
                undoInsert(newParent, above: node)
            }
        } catch {
            
        }
    }
    
    func undoInsert(_ newParent: TicketTree, above node: TicketTree) {
        do {
            if let index = newParent.childIndex() {
                node.removeFromParent()
                _ = try newParent.parent?.replaceChild(at: index, with: node)
            } else {
                node.removeFromParent()
                tree = node
            }
            unregister(newParent)
            setOffsets()
            undoManager.registerUndo(withTarget: self) { vm in
                vm.insert(newParent, above: node)
            }
        } catch {
            print(error)
        }
    }
}
