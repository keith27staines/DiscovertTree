//
//  KeyMonitorTests.swift
//  DiscoveryTreeTests
//
//  Created by Keith Staines on 17/12/2023.
//

import XCTest

final class KeyMonitorTests: XCTestCase {

    func test_keyDownIsTrue_withOneEventOfCorrectKeyCode_and_keyIsDown() throws {
        let sut = KeyMonitor(keyCode: 1)
        let event = makeEvent(code: 1, isDown: true, received: 1000)!
        sut.receiveEvent(event)
        XCTAssertTrue(sut.isKeyDown)
    }
    
    func test_keyDownIsFalse_withOneEventOfCorrectKeyCode_and_keyIsUp() throws {
        let sut = KeyMonitor(keyCode: 1)
        let event = makeEvent(code: 1, isDown: false, received: 1000)!
        sut.receiveEvent(event)
        XCTAssertFalse(sut.isKeyDown)
    }
    
    func makeEvent(code: UInt16, isDown: Bool, received: TimeInterval) -> KeyEvent? {
        let cgEvent = CGEvent(keyboardEventSource: nil, virtualKey: code, keyDown: isDown)!
        let nsEvent = NSEvent(cgEvent: cgEvent)!
        let eventTime = received
        return KeyEvent(event: nsEvent, date: eventTime)
    }
}

final class KeyMonitor {
    typealias KeyCode = UInt16
    
    private (set) var lastEvent: KeyEvent?
        
    func receiveEvent(_ event: KeyEvent) {
        lastEvent = event
    }
    
    let keyCode: KeyCode
    
    init(keyCode: KeyCode) {
        self.keyCode = keyCode
    }
    
    var isKeyDown: Bool { lastEvent?.eventType == .keyDown }
}

struct KeyEvent: Equatable {
    
    enum EventType {
        case keyDown
        case keyUp
    }
    
    let date: TimeInterval
    let keyCode: UInt16
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
