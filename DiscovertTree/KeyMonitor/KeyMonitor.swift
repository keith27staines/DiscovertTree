//
//  KeyMonitor.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 18/12/2023.
//

import AppKit

final class KeyMonitor {
    
    private (set) var lastEvent: KeyEvent? {
        didSet {
            if oldValue?.eventType != lastEvent?.eventType {
                onIsKeyDownDidChange(isKeyDown)
            }
        }
    }
        
    func receiveEvent(_ event: KeyEvent) -> Bool {
        guard event.keyCode == keyCode else {
            lastEvent = nil
            return false
        }
        if lastEvent?.eventType != event.eventType {
            lastEvent = event
        }
        return true
    }
    
    func stopMonitoring() {
        lastEvent = nil
    }
    
    let keyCode: KeyCode
    
    var onIsKeyDownDidChange: (Bool) -> Void
    
    init(
        keyCode: KeyCode,
        onIsKeyDownDidChange: @escaping ((Bool) -> Void) = {_ in }
    ) {
        self.keyCode = keyCode
        self.onIsKeyDownDidChange = onIsKeyDownDidChange
    }
    
    var isKeyDown: Bool { lastEvent?.eventType == .keyDown }
}

struct KeyEvent: Equatable {
    
    enum EventType {
        case keyDown
        case keyUp
    }
    
    let date: TimeInterval
    let keyCode: KeyCode
    let eventType: EventType
    
}

extension KeyEvent {
    init?(event: NSEvent, date: TimeInterval = Date.now.timeIntervalSince1970) {
        guard event.type == .keyUp || event.type == .keyDown else { return nil }
        self.date = date
        self.keyCode = event.keyCode
        self.eventType = event.type == .keyDown ? .keyDown : .keyUp
    }
}

typealias KeyCode = UInt16

extension KeyCode {
    static var cmd:             KeyCode { return 0x37 }
    static var alt:             KeyCode { return 0x3A }
    static var ctrl:            KeyCode { return 0x3B }
    static var space:           KeyCode { return 0x31 }
}

