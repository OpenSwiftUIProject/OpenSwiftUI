//
//  KeyPressTests.swift
//  OpenSwiftUITests

import Foundation
import OpenAttributeGraphShims
@_spi(_)
@testable import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
import Testing

@MainActor
struct KeyPressTests {
    @Test(arguments: [
        (KeyPress.Phases(), 0, "[]"),
        (.down, 1, ".down"),
        (.repeat, 2, ".repeat"),
        (.up, 4, ".up"),
        ([.down, .repeat], 3, "[.down, .repeat]"),
        ([.down, .repeat, .up], 7, "[.down, .repeat, .up]"),
        (.init(rawValue: 8), 8, "[]"),
        (.init(rawValue: 9), 9, ".down"),
        (.all, Int.max, ".all"),
        (.init(rawValue: -1), -1, "[.down, .repeat, .up]"),
    ] as [(KeyPress.Phases, Int, String)])
    func phases(phase: KeyPress.Phases, rawValue: Int, description: String) {
        #expect(phase.rawValue == rawValue)
        #expect(phase.debugDescription == description)
    }

    // EventPhase is not Sendable, so each argument creates its value inside the test.
    @Test(arguments: [
        (.began, .down),
        (.active, .repeat),
        (.ended, .up),
        (.failed, .up),
    ] as [(EventPhase, KeyPress.Phases)])
    func eventConversion(phase: EventPhase, expected: KeyPress.Phases) throws {
        let press = try #require(KeyPress(for: event(phase: phase, keys: "ab", string: "AB")))
        #expect(press.phase == expected)
        #expect(press.key == "a")
        #expect(press.characters == "ab")
        #expect(press.modifiers == [.shift, .command])
    }

    @Test
    func emptyAndNonKeyEvents() {
        #expect(KeyPress(for: event(keys: "", string: "a")) == nil)
        #expect(KeyPress(for: OtherEvent()) == nil)
    }

    @Test(arguments: [
        ("👨‍👩‍👧‍👦x", Character("👨‍👩‍👧‍👦"), "KeyPress(.down, \"👨‍👩‍👧‍👦x\")"),
        ("\"\n", "\"", "KeyPress(.down, \"\"\n\")"),
    ])
    func keyAndDescription(keys: String, key: Character, description: String) throws {
        let press = try #require(KeyPress(for: event(keys: keys, string: "ignored")))
        #expect(press.key.character == key)
        #expect(press.characters == keys)
        #expect(press.debugDescription == description)
    }

    @Test(arguments: [KeyPress.Result.handled, .ignored])
    func singleKeyActionAndDefaultPhases(result: KeyPress.Result) throws {
        var calls = 0
        let view = EmptyView().onKeyPress("a") {
            calls += 1
            return result
        }
        let handlers = try environment(for: view).keyPressHandlers
        let handler = try #require(handlers.first)
        #expect(calls == 0)
        #expect(handler.phases == [.down, .repeat])
        guard case let .keys(keys) = handler.subject else {
            Issue.record("Expected a key subject")
            return
        }
        #expect(keys == ["a"])
        let press = try #require(KeyPress(for: event(keys: "a", string: "A")))
        #expect(handler.action(press) == result)
        #expect(calls == 1)
    }

    @Test(arguments: [
        (KeyOverload.single, Set<KeyEquivalent>(["a"]), KeyPress.Phases.up),
        (.keys, ["a", "b"], [.down, .repeat]),
        (.keysIn, ["x"], .up),
    ] as [(KeyOverload, Set<KeyEquivalent>, KeyPress.Phases)])
    func keySubjects(overload: KeyOverload, keys: Set<KeyEquivalent>, phases: KeyPress.Phases) throws {
        let values: EnvironmentValues
        switch overload {
        case .single:
            let key = try #require(keys.first)
            values = try environment(for: EmptyView().onKeyPress(key, phases: phases) { _ in .ignored })
        case .keys:
            values = try environment(for: EmptyView().onKeyPress(keys: keys) { _ in .ignored })
        case .keysIn:
            values = try environment(for: EmptyView().onKeyPress(keysIn: keys, phases: phases) { _ in .ignored })
        }
        let handler = try #require(values.keyPressHandlers.first)
        guard case let .keys(subject) = handler.subject else {
            Issue.record("Expected a key subject")
            return
        }
        #expect(subject == keys)
        #expect(handler.phases == phases)
    }

    @Test(arguments: [
        (false, CharacterSet.letters, KeyPress.Phases.up),
        (true, .decimalDigits, [.down, .repeat]),
    ] as [(Bool, CharacterSet, KeyPress.Phases)])
    func characterSubjects(deprecated: Bool, characters: CharacterSet, phases: KeyPress.Phases) throws {
        let values = try deprecated
            ? environment(for: EmptyView().onKeyPress(charactersIn: characters) { _ in .ignored })
            : environment(for: EmptyView().onKeyPress(characters: characters, phases: phases) { _ in .ignored })
        let handler = try #require(values.keyPressHandlers.first)
        guard case let .characters(subject) = handler.subject else {
            Issue.record("Expected a character-set subject")
            return
        }
        #expect(subject == characters)
        #expect(handler.phases == phases)
    }

    @Test
    func allKeysAndDefaultPhases() throws {
        let all = try environment(for: EmptyView().onKeyPress { _ in .ignored })
        guard case .all = try #require(all.keyPressHandlers.first).subject else {
            Issue.record("Expected an all-keys subject")
            return
        }
        #expect(all.keyPressHandlers.first?.phases == [.down, .repeat])
    }

    @Test
    func environmentPreservesHandlerOrderAndActions() throws {
        let first = try environment(for: EmptyView().onKeyPress(phases: .up) { _ in .handled })
        let second = try environment(for: EmptyView().onKeyPress(phases: .down) { _ in .ignored }, initial: first)
        #expect(second.keyPressHandlers.map(\.phases) == [.up, .down])
        #expect(first.keyPressHandlers.count == 1)
        let press = try #require(KeyPress(for: event(keys: "a", string: "A")))
        #expect(second.keyPressHandlers.map { $0.action(press) } == [.handled, .ignored])
    }

    @Test
    func keyHashingUsesCharacterEquality() {
        let keys: Set<KeyEquivalent> = [KeyEquivalent("é"), KeyEquivalent("e\u{301}")]
        #expect(keys.count == 1)
        #expect(Set([KeyPress.Result.handled, .ignored]).count == 2)
    }

    private func event(phase: EventPhase = .began, keys: String, string: String) -> KeyEvent {
        KeyEvent(
            phase: phase,
            timestamp: .init(seconds: 0),
            modifiers: [.shift, .command],
            keys: keys,
            stringValue: string,
            keyID: 1
        )
    }

    enum KeyOverload: Sendable {
        case single, keys, keysIn
    }

    private func environment<V: View>(for view: V, initial: EnvironmentValues = .init()) throws -> EnvironmentValues {
        let modifier = try #require(Mirror(reflecting: view).descendant("modifier") as? any EnvironmentModifier)
        return applying(modifier, to: initial)
    }

    private func applying<M: EnvironmentModifier>(_ modifier: M, to initial: EnvironmentValues) -> EnvironmentValues {
        let graph = ViewGraph(rootViewType: EmptyView.self)
        return graph.globalSubgraph.apply {
            var environment = initial
            M.makeEnvironment(modifier: Attribute(value: modifier), environment: &environment)
            return environment
        }
    }

    private struct OtherEvent: EventType {
        var phase: EventPhase = .began
        var timestamp: Time = .init(seconds: 0)
        var binding: EventBinding?
    }
}
