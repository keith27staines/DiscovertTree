//
//  Ticket.swift
//
//
//  Created by Keith Staines on 25/11/2023.
//

import DiscoveryTreeCore
import Foundation

/// A ticket represents an item in a todo list
struct Ticket: Codable {
    
    /// The title describes at the highest level the purpose of the ticket
    var title: String
    
    /// The date the ticket was created
    var createdDate: Date
    
    /// The state of the ticket
    var state: TicketState = .todo
    
    init(
        title: String = "New Ticket",
        createdDate: Date = .now,
        state: TicketState = .todo
    ) {
        self.title = title
        self.createdDate = createdDate
        self.state = state
    }
}


enum TicketState: Codable, CaseIterable, Hashable {
    case todo
    case inProgress
    case done
    case blocked
    
    var description: String {
        switch self {
        case .todo:
            return "To do"
        case .inProgress:
            return "In progress"
        case .done:
            return "Done"
        case .blocked:
            return "Blocked"
        }
    }
    
    var theme: Theme {
        switch self {
        case .todo:
            return .lavender
        case .inProgress:
            return .buttercup
        case .done:
            return .seafoam
        case .blocked:
            return .bubblegum
        }
    }
}

