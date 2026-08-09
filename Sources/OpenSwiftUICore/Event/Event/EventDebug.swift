//
//  EventDebug.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A636ACD16EB64077CFE18AF4AEBDC516 (SwiftUICore)

import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#else
#error("Unsupported Platform")
#endif
import OpenAttributeGraphShims

// MARK: - _EventDebugTriggers

@available(OpenSwiftUI_v1_0, *)
public struct _EventDebugTriggers: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let responders: _EventDebugTriggers = .init(rawValue: 1 << 1)

    public static let sendEvents: _EventDebugTriggers = .init(rawValue: 1 << 2)

    public static let eventBindings: _EventDebugTriggers = .init(rawValue: 1 << 3)

    public static let eventPhases: _EventDebugTriggers = .init(rawValue: 1 << 4)

    public static let gestures: _EventDebugTriggers = .init(rawValue: 1 << 5)

    public static let hitTest: _EventDebugTriggers = .init(rawValue: 1 << 6)

    public static let all: _EventDebugTriggers = .init(rawValue: -1)

    init(environmentString: String) {
        var triggers: _EventDebugTriggers = []
        for character in environmentString.lowercased() {
            switch character {
            case "*": triggers = .all
            case "r": triggers.formUnion(.responders)
            case "e": triggers.formUnion(.sendEvents)
            case "b": triggers.formUnion(.eventBindings)
            case "p": triggers.formUnion(.eventPhases)
            case "g": triggers.formUnion(.gestures)
            case "h": triggers.formUnion(.hitTest)
            default: break
            }
        }
        self = triggers
    }
}

@available(*, unavailable)
extension _EventDebugTriggers: Sendable {}

// MARK: - _eventDebugTriggers

@available(OpenSwiftUI_v1_0, *)
public var _eventDebugTriggers: _EventDebugTriggers = {
    guard let stringValue = getenv("OpenSWIFTUI_EVENT_DEBUG").map({ String(cString: $0) }) ??
            UserDefaults.standard.string(forKey: "org.OpenSwiftUIProject.OpenSwiftUI.EventDebugTriggers") else {
        return []
    }
    return _EventDebugTriggers(environmentString: stringValue)
}()

// MARK: - Event debug printing

@inline(never)
package func printEvents(_ events: [EventID: any EventType]) {
    events.forEach { id, event in
        Signpost.eventHandling.traceEvent(
            type: .event,
            object: nil,
            "Event: %{public}@.%{public}@ at %3.6f",
            [
                String(describing: id.type),
                String(describing: event.phase),
                event.timestamp.seconds,
            ]
        )
    }
    if _eventDebugTriggers.contains(.sendEvents) {
        Log.eventDebug("EVENTS \(events)\n")
    }
}

@inline(never)
package func printEventBindings(_ bindings: [EventID: EventBinding]) {
    guard _eventDebugTriggers.contains(.eventBindings) else {
        return
    }
    Log.eventDebug("BINDINGS")
    for (id, binding) in bindings {
        Log.eventDebug("\(id) -> [")
        for responder in binding.responder.sequence {
            let description = if let convertible = responder as? any CustomStringConvertible {
                convertible.description
            } else {
                Metadata(type(of: responder)).description
            }
            Log.eventDebug("  \(description) \(address(of: responder))")
        }
        Log.eventDebug("]\n")
    }
}

@inline(never)
package func printGestures(
    data: @autoclosure () -> GestureDebug.Data?,
    host: AnyObject?
) {
    guard _eventDebugTriggers.contains(.gestures), let data = data() else {
        return
    }
    Log.eventDebug("GESTURES (\(succinctDescription(of: host)))")
    data.printTree()
    Log.eventDebug("")
}

private func succinctDescription(of object: AnyObject?) -> String {
    guard let object else {
        return "(nil host)"
    }
    let description = if let convertible = object as? any CustomStringConvertible {
        convertible.description
    } else {
        Metadata(type(of: object)).description
    }
    return "\(description) \(address(of: object))"
}

@_spi(ForOpenSwiftUIOnly)
extension ResponderNode {
    @inline(never)
    package func log(action: String, data: Any? = nil) {
        var result = action
        if action.count < 12 {
            result += String(repeating: " ", count: 12 - action.count)
        }
        let hostDescription = if let responder = self as? ViewResponder {
            succinctDescription(of: responder.host)
        } else {
            "nil"
        }
        result += " \(hostDescription) -> \(type(of: self)) \(self) "
        if let data {
            result += " \(data)"
        }
        Log.eventDebug(result)
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
extension _GestureInputs.InheritedPhase: CustomStringConvertible {
    public var description: String {
        var result = "[ "
        if contains(.failed) {
            result += "failed "
        }
        if contains(.active) {
            result += "active "
        }
        result += "]"
        return result
    }
}
