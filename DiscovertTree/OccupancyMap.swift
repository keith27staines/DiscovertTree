//
//  OccupancyMap.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 26/12/2023.
//

import Foundation
import DiscoveryTreeCore

final class OccupancyMap<C> where C: Codable & Hashable {
    
    let root: Tree<C>
    
    private var map = [String: Set<Tree<C>>]()
    
    init(root: Tree<C>) {
        self.root = root
        add(root)
    }
    
    func occupancy(_ x: Int, _ y: Int) -> Set<Tree<C>> {
        let key = key(x: x, y: y)
        return map[key] ?? []
    }
    
    func add(_ node: Tree<C>) {
        let key = key(node: node)
        let keyExists = map[key] != nil
        if !keyExists {
            map[key] = []
        }
        map[key]?.insert(node)
        node.children.forEach { child in
            add(child)
        }
    }
    
    func hasCollisions() -> Bool {
        map.values.first { set in
            set.count > 1
        } == nil ? false : true
    }
    
    func remove(_ node: Tree<C>) {
        let key = key(node: node)
        map[key]?.remove(node)
    }
    
    private func key(node: Tree<C>) -> String {
        key(x: node.x, y: node.y)
    }
    
    private func key(x: Int, y: Int) -> String {
        "\(x),\(y)"
    }
    
}
