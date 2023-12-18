//
//  KeyMonitorTests.swift
//  DiscoveryTreeTests
//
//  Created by Keith Staines on 17/12/2023.
//

import XCTest
@testable import DiscoveryTree

final class KeyMonitorTests: XCTestCase {
    
    let now: TimeInterval = 0
    
    func test_keyDownIsFalse_withOneEventOfIncorrectKeyCode_and_keyIsDown() throws {
        let sut = KeyMonitor(keyCode: 1) {_ in 
            XCTFail()
        }
        let event = makeEvent(code: 2, isDown: true, received: now)!
        sut.receiveEvent(event)
        XCTAssertFalse(sut.isKeyDown)
    }

    func test_keyDownIsTrue_withOneEventOfCorrectKeyCode_and_keyIsDown() throws {
        let sut = KeyMonitor(keyCode: 1)
        let event = makeEvent(code: 1, isDown: true, received: now)!
        sut.receiveEvent(event)
        XCTAssertTrue(sut.isKeyDown)
    }
    
    func test_keyDownIsFalse_withOneEventOfCorrectKeyCode_and_keyIsUp() throws {
        let sut = KeyMonitor(keyCode: 1)
        let event = makeEvent(code: 1, isDown: false, received: now)!
        sut.receiveEvent(event)
        XCTAssertFalse(sut.isKeyDown)
    }
    
    func test_stopMonitoring_afterEventHasBeenMonitored() throws {
        let sut = KeyMonitor(keyCode: 1)
        let event = makeEvent(code: 1, isDown: true, received: now)!
        sut.receiveEvent(event)
        sut.stopMonitoring()
        XCTAssertFalse(sut.isKeyDown)
    }
    
    func test_onIsPressedChange_withOneMonitoredEvent() {
        var callbacks = [Bool]()
        let event = makeEvent(code: 1, isDown: true, received: now)!
        let sut = KeyMonitor(keyCode: 1) { isPressed in
            callbacks.append(isPressed)
        }
        sut.receiveEvent(event)
        XCTAssertEqual(callbacks.count, 1)
        XCTAssertTrue(callbacks[0])
    }
    
    func test_onIsPressedChange_withSeveralMonitoredEvents_endingInDifferentType() {
        var callbacks = [Bool]()
        let event1 = makeEvent(code: 1, isDown: true, received: now)!
        let event2 = makeEvent(code: 1, isDown: false, received: now)!
        let sut = KeyMonitor(keyCode: 1) { isPressed in
            callbacks.append(isPressed)
        }
        sut.receiveEvent(event1)
        sut.receiveEvent(event1)
        sut.receiveEvent(event1)
        sut.receiveEvent(event1)
        sut.receiveEvent(event1)
        sut.receiveEvent(event2)
        XCTAssertEqual(callbacks.count, 2)
        XCTAssertTrue(callbacks[0])
        XCTAssertFalse(callbacks[1])
    }
    
    func test_onIsPressedChange_withTwoEvents_endingInDifferentCode() {
        var callbacks = [Bool]()
        let event1 = makeEvent(code: 1, isDown: true, received: now)!
        let event2 = makeEvent(code: 2, isDown: true, received: now)!
        let sut = KeyMonitor(keyCode: 1) { isPressed in
            callbacks.append(isPressed)
        }
        sut.receiveEvent(event1)
        sut.receiveEvent(event2)
        XCTAssertEqual(callbacks.count, 2)
        XCTAssertTrue(callbacks[0])
        XCTAssertFalse(callbacks[1])
    }
    
    func test_onIsPressedChange_withOneEvent_withUnmonitoredCode() {
        var callbacks = [Bool]()
        let event = makeEvent(code: 2, isDown: true, received: now)!
        let sut = KeyMonitor(keyCode: 1) { isPressed in
            callbacks.append(isPressed)
        }
        sut.receiveEvent(event)
        XCTAssertEqual(callbacks.count, 0)
    }
    
    func makeEvent(
        code: KeyCode,
        isDown: Bool,
        received: TimeInterval
    ) -> KeyEvent? {
        let cgEvent = CGEvent(
            keyboardEventSource: nil,
            virtualKey: code,
            keyDown: isDown
        )!
        let nsEvent = NSEvent(cgEvent: cgEvent)!
        let eventTime = received
        return KeyEvent(event: nsEvent, date: eventTime)
    }
}

