//
//  Ticket.swift
//
//
//  Created by Keith Staines on 25/11/2023.
//

import DiscoveryTreeCore
import SwiftUI

/// A ticket represents an item in a todo list
public struct Ticket: Codable, Hashable {
    
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

enum TicketState: String, Codable, CaseIterable, Hashable, Identifiable {
    case todo
    case inProgress
    case done
    case blocked
    case deferred
    
    var id: String { self.rawValue }
    
    var title: LocalizedStringResource {
        switch self {
        case .todo: return LocalizedStringResource("To do")
        case .inProgress: return LocalizedStringResource("In progress")
        case .done: return LocalizedStringResource("Done")
        case .blocked: return LocalizedStringResource("Blocked")
        case .deferred: return LocalizedStringResource("Deferred")
        }
    }
}

