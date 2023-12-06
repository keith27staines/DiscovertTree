//
//  DocumentViewModel+insertSibling.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 05/12/2023.
//

import Foundation

extension DocumentViewModel {
    
    func addChild(_ child: TicketTree, to parent: TicketTree, at index: Int) throws {
        try parent.insertChild(child, at: index)
        register(child)
        setOffsets()
        undoManager.registerUndo(withTarget: self) { vm in
            vm.undoAddChild(child, to: parent, at: index)
        }
    }
    
    func undoAddChild(_ child: TicketTree, to parent: TicketTree, at index: Int) {
        child.removeFromParent()
        unregister(child)
        setOffsets()
        undoManager.registerUndo(withTarget: self) { vm in
            do {
                try vm.addChild(child, to: parent, at: index)
            } catch {
                vm.undoManager.removeAllActions(withTarget: self)
            }
        }
    }
}

extension DocumentViewModel {
    
    func deleteChild(_ child: TicketTree, at index: Int, from parent: TicketTree) throws {
        child.children.forEach { node in
            unregister(node)
        }
        child.removeFromParent()
        unregister(child)
        setOffsets()
        undoManager.registerUndo(withTarget: self) { vm in
            do {
                try vm.addChild(child, to: parent, at: index)
            } catch {
                vm.undoManager.removeAllActions(withTarget: self)
            }
        }
    }
    
    func undoChild(_ child: TicketTree, at index: Int, from parent: TicketTree) throws {
        do {
            try parent.insertChild(child, at: index)
            undoManager.registerUndo(withTarget: self) { vm in
                do {
                    try vm.deleteChild(child, at: index, from: parent)
                } catch {
                    vm.undoManager.removeAllActions(withTarget: self)
                }
            }
        } catch {
            
        }
    }
}

