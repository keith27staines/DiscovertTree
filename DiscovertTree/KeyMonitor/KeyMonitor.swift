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
        
    func receiveEvent(_ event: KeyEvent) {
        guard event.keyCode == keyCode else {
            lastEvent = nil
            return
        }
        if lastEvent?.eventType != event.eventType {
            lastEvent = event
        }
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

//enum KeyCode: UInt16 {
//
//    case cmd
//    case alt
//    case ctrl
//    case space
//
//    var value: UInt16 {
//        switch self {
//        case .cmd:       return 0x37
//        case .alt:       return 0x3A
//        case .ctrl:      return 0x3B
//        case .space:     return 0x31
//        }
//    }
//}

