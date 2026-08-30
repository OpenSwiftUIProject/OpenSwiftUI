//
//  PanEventTests.swift
//  OpenSwiftUICoreTests

import Foundation
@_spi(ForOpenSwiftUIOnly)
@_spi(_)
@testable import OpenSwiftUICore
import Testing

@Suite
struct PanEventTests {
    @Test
    func initializationFromValues() {
        let event = PanEvent(
            globalLocation: CGPoint(x: 10, y: 20),
            phase: .active,
            timestamp: Time(seconds: 3.5),
            globalTranslation: CGSize(width: 4, height: 5),
            touchType: .indirect
        )

        #expect(event.location == CGPoint(x: 10, y: 20))
        #expect(event.globalLocation == CGPoint(x: 10, y: 20))
        #expect(event.phase == .active)
        #expect(event.timestamp == Time(seconds: 3.5))
        #expect(event.binding == nil)
        #expect(event.translation == CGSize(width: 4, height: 5))
        #expect(event.globalTranslation == CGSize(width: 4, height: 5))
        #expect(event.touchType == .indirect)
        #expect(event.radius == 0)
        #expect(event.kind == .pan)
    }

    @Test
    func locationSetterSynchronizesTranslation() {
        var event = PanEvent(
            globalLocation: CGPoint(x: 10, y: 20),
            phase: .began,
            timestamp: .zero,
            globalTranslation: CGSize(width: 4, height: 5),
            touchType: .direct
        )

        event.location = CGPoint(x: 7, y: 8)

        #expect(event.location == CGPoint(x: 7, y: 8))
        #expect(event.translation == CGSize(width: 7, height: 8))
        #expect(event.globalLocation == CGPoint(x: 10, y: 20))
        #expect(event.globalTranslation == CGSize(width: 4, height: 5))
    }

    @Test
    func initializationFromPanEventType() {
        let source = TestPanEvent(
            phase: .ended,
            timestamp: Time(seconds: 9),
            binding: nil,
            translation: CGSize(width: 1, height: 2),
            globalTranslation: CGSize(width: 3, height: 4),
            touchType: .indirect
        )

        let event = PanEvent(source as any PanEventType)

        #expect(event.location == CGPoint(x: 1, y: 2))
        #expect(event.globalLocation == CGPoint(x: 3, y: 4))
        #expect(event.phase == .ended)
        #expect(event.timestamp == Time(seconds: 9))
        #expect(event.binding == nil)
        #expect(event.translation == CGSize(width: 1, height: 2))
        #expect(event.globalTranslation == CGSize(width: 3, height: 4))
        #expect(event.touchType == .indirect)

        let erased: any EventType = source
        #expect(PanEvent(erased) == event)
    }

    @Test
    func initializationRejectsNonPanEvent() {
        let event: any EventType = TestEvent(
            phase: .failed,
            timestamp: .zero,
            binding: nil
        )

        #expect(PanEvent(event) == nil)
    }
}

private struct TestPanEvent: PanEventType {
    var phase: EventPhase
    var timestamp: Time
    var binding: EventBinding?
    var translation: CGSize
    var globalTranslation: CGSize
    var touchType: TouchType
}

private struct TestEvent: EventType {
    var phase: EventPhase
    var timestamp: Time
    var binding: EventBinding?
}
