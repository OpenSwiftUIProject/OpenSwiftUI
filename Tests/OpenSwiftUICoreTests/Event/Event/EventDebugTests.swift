//
//  EventDebugTests.swift
//  OpenSwiftUICoreTests

@_spi(ForOpenSwiftUIOnly) @testable import OpenSwiftUICore
import Testing

@Suite(.serialized)
struct EventDebugTriggersTests {
    @Test
    func rawValues() {
        #expect(_EventDebugTriggers.responders.rawValue == 1 << 1)
        #expect(_EventDebugTriggers.sendEvents.rawValue == 1 << 2)
        #expect(_EventDebugTriggers.eventBindings.rawValue == 1 << 3)
        #expect(_EventDebugTriggers.eventPhases.rawValue == 1 << 4)
        #expect(_EventDebugTriggers.gestures.rawValue == 1 << 5)
        #expect(_EventDebugTriggers.hitTest.rawValue == 1 << 6)
        #expect(_EventDebugTriggers.all.rawValue == -1)
    }

    @Test(arguments: [
        ("r", 2), ("R", 2),
        ("e", 4), ("E", 4),
        ("b", 8), ("B", 8),
        ("p", 16), ("P", 16),
        ("g", 32), ("G", 32),
        ("h", 64), ("H", 64),
        ("ReBpGh", 126),
        ("", 0), ("xyz", 0), ("r-r", 2),
        ("*", -1), ("r*x", -1), ("*ReBpGh", -1),
    ])
    func environmentString(_ string: String, expectedRawValue: Int) {
        #expect(_EventDebugTriggers(environmentString: string).rawValue == expectedRawValue)
    }

    @Test
    func printGesturesEvaluatesDataOnlyWhenEnabled() {
        let originalTriggers = _eventDebugTriggers
        defer {
            _eventDebugTriggers = originalTriggers
        }

        var evaluationCount = 0
        func data() -> GestureDebug.Data? {
            evaluationCount += 1
            return nil
        }

        _eventDebugTriggers = []
        printGestures(data: data(), host: nil)
        #expect(evaluationCount == 0)

        _eventDebugTriggers = .sendEvents
        printGestures(data: data(), host: nil)
        #expect(evaluationCount == 0)

        _eventDebugTriggers = .gestures
        printGestures(data: data(), host: nil)
        #expect(evaluationCount == 1)
    }
}

struct InheritedPhaseDescriptionTests {
    @Test(arguments: [
        (0, "[ ]"),
        (1, "[ failed ]"),
        (2, "[ active ]"),
        (3, "[ failed active ]"),
        (4, "[ ]"),
        (5, "[ failed ]"),
        (6, "[ active ]"),
        (7, "[ failed active ]"),
    ])
    func description(rawValue: Int, expectedDescription: String) {
        let phase = _GestureInputs.InheritedPhase(rawValue: rawValue)
        #expect(phase.description == expectedDescription)
    }
}
