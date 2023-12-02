//
//  TestData.swift
//  DiscovertTree
//
//  Created by Keith Staines on 02/12/2023.
//

import DiscoveryTreeCore

func makeTestTree() -> Tree<Ticket> {
    func ticket(x: Int, y: Int) -> Ticket {
        Ticket(title: "x: \(x), y:\(y)")
    }
    
    let t00 = Tree(content: ticket(x: 0, y: 0))
    let t01 = Tree(content: ticket(x: 0, y: 1))
    let t11 = Tree(content: ticket(x: 1, y: 1))
    let t21 = Tree(content: ticket(x: 2, y: 1))
    let t22 = Tree(content: ticket(x: 2, y: 2))
    try? t00.appendChild(t01)
    try? t00.appendChild(t11)
    try? t00.appendChild(t21)
    try? t21.appendChild(t22)
    return t00
}
