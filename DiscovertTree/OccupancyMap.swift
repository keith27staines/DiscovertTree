//
//  OccupancyMap.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 26/12/2023.
//

import Foundation
import DiscoveryTreeCore

class OccupancyMap<C> where C: Codable & Hashable {
    
    typealias Node = Tree<C>
    typealias Map = [Key: NodeSet]
    typealias NodeSet = Set<Node>
    
    let root: Node
    private var map = Map()
    
    struct Key: Hashable {
        let x: Int
        let y: Int
    }
    
    init(root: Node) {
        self.root = root
        add(root)
    }
    
    func priorityCollidingNode() -> Node? {
        guard let set = priorityCollisionSet(map: map) else { return nil }
        let nodes = Array(set)
        return nodes.first { node in
            node.childIndex() == 0
        }
    }
    
    func occupancy(_ x: Int, _ y: Int) -> NodeSet {
        let key = Key(x: x, y: y)
        return map[key] ?? []
    }
    
    func hasCollisions() -> Bool {
        !collisions(map: map).isEmpty
    }
}

extension OccupancyMap {
    
    func priorityCollisionSet(map: Map) -> NodeSet? {
        let collisions = collisions(map: map)
        let depth = depth(map: collisions)
        let deepestCollisions = filterForDepth(map: collisions, depth: depth)
        let offset = leastOffset(map: deepestCollisions)
        let priorityCollisionKey = Key(x: offset, y: depth)
        return map[priorityCollisionKey]
    }
    
    private func collisions(map: Map) -> Map {
        map.filter { (key, value) in
            value.count > 1
        }
    }
    
    private func depth(map: Map) -> Int {
        var maxDepth = 0
        for key in map.keys {
            maxDepth = key.y > maxDepth ? key.y : maxDepth
        }
        return maxDepth
    }
    
    private func filterForDepth(map: Map, depth: Int) -> Map {
        map.filter { (key, value) in
            key.y == depth
        }
    }
    
    private func leastOffset(map: Map) -> Int {
        var leastOffset = Int.max
        for key in map.keys {
            leastOffset = key.x < leastOffset ? key.x : leastOffset
        }
        return leastOffset
    }
    
    private func add(_ node: Node) {
        let key = Key(x: node.x, y: node.y)
        let keyExists = map[key] != nil
        if !keyExists {
            map[key] = []
        }
        map[key]?.insert(node)
        node.children.forEach { child in
            add(child)
        }
    }
}
