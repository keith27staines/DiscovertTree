//
//  OccupancyMapTests.swift
//  DiscoveryTreeTests
//
//  Created by Keith Staines on 26/12/2023.
//

import XCTest
@testable import DiscoveryTreeCore
@testable import DiscoveryTree

public typealias StringTree = Tree<String>

final class OccupancyMapTests: XCTestCase {

    let root = StringTree()
    
    func test_occupancyAtRootWithOneOccupierAtRoot() {
        let sut = OccupancyMap<String>(root: root)
        XCTAssertEqual(sut.occupancy(0, 0).first, root)
        XCTAssertFalse(sut.hasCollisions())
    }
    
    func test() throws {
        
        // append two children to root
        let firstChildOfRoot = Tree<String>()
        let secondChildOfRoot = Tree<String>()
        try root.appendChild(firstChildOfRoot)
        try root.appendChild(secondChildOfRoot)
        
        // add two children to root's first child
        let node02 = Tree<String>()
        let node12a = Tree<String>()
        try firstChildOfRoot.appendChild(node02)
        try firstChildOfRoot.appendChild(node12a)
        
        // add two children to root's second child
        // causing one collision in the occupancy map
        let node12b = Tree<String>()
        let node22 = Tree<String>()
        try secondChildOfRoot.appendChild(node12b)
        try secondChildOfRoot.appendChild(node22)

        let sut = OccupancyMap<String>(root: root)
        XCTAssertTrue(sut.hasCollisions())
        XCTAssertEqual(sut.occupancy(0, 0).count, 1)
        XCTAssertEqual(sut.occupancy(0, 1).count, 1)
        XCTAssertEqual(sut.occupancy(1, 1).count, 1)
        
        XCTAssertEqual(sut.occupancy(0, 2).count, 1)
        XCTAssertEqual(sut.occupancy(1, 2).count, 2) // should be collision here
        XCTAssertEqual(sut.occupancy(2, 2).count, 1)
        
        XCTAssertEqual(sut.priorityCollidingNode(), node12b)
    }
    
}



