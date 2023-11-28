//
//  Ticket.swift
//
//
//  Created by Keith Staines on 25/11/2023.
//

import Foundation
import DiscoveryTreeCore

/// A ticket represents an item in a todo list
struct Ticket: Codable {
    
    /// Uniquely identifies the object in a type safe way
    let id: Id<Ticket>
    
    /// The title describes at the highest level the purpose of the ticket
    var title: String
    
    /// The date the ticket was created
    var createdDate: Date
    
    /// Initializes a new instance
    /// - Parameters:
    ///   - id: Uniquely identifies the ticket in a type safe way
    ///   - title: Title of the ticket
    ///   - createdDate: Date on which the ticket was created
    init(id: UUID = UUID(), title: String, createdDate: Date = Date.now) {
        self.id = Id<Ticket>(uuid: id)
        self.title = title
        self.createdDate = createdDate
    }
}
