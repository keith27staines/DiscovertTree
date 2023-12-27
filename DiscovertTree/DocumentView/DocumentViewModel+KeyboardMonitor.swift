//
//  DocumentViewModel+KeyboardMonitor.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 21/12/2023.
//

import Foundation
import AppKit

extension DocumentViewModel {
    func startKeyboardMonitor() {
        
        eventMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.keyDown, .keyUp]
        ) { [weak self] event in
            guard let self = self, let keyEvent = KeyEvent(event: event)
            else { return event }
            let handled = self.keyMonitor.receiveEvent(keyEvent)
            return handled ? nil : event
        }
        
        keyMonitor.onIsKeyDownDidChange = { [weak self] isPressed in
            guard let self = self else { return }
            ticketInsertMode = isPressed ? .spacer : .ticket
            ticketViewModels.forEach { $0.insertMode = self.ticketInsertMode }
        }
    }
    
    func stopKeyboardMonitor() {
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
    }
}
