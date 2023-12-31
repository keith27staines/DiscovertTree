//
//  Array+extensions.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 31/12/2023.
//

import Foundation

extension Array {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key:Element] {
        var dict = [Key:Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}
