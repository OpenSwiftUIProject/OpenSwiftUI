//
//  SymbolEffectTests.swift
//  OpenSwiftUICoreTests

import Foundation
@_spi(Private) @testable import OpenSwiftUICore
import Testing

struct SymbolEffectTests {
    typealias Trigger = _SymbolEffect.Trigger

    @Test(arguments: [
        (Trigger.condition(true), Trigger?.none, false),
        (Trigger.condition(true), Trigger?.some(.condition(false)), true),
        (Trigger.condition(false), Trigger?.some(.condition(true)), false),
        (Trigger.condition(true), Trigger?.some(.condition(true)), false),
        (Trigger.value(AnyEquatable(2)), Trigger?.some(.value(AnyEquatable(1))), true),
        (Trigger.value(AnyEquatable(1)), Trigger?.some(.value(AnyEquatable(1))), false),
        (Trigger.value(AnyEquatable(1)), Trigger?.some(.condition(false)), false),
    ])
    func triggerActivates(trigger: Trigger, oldTrigger: Trigger?, expected: Bool) {
        #expect(trigger.activates(after: oldTrigger) == expected)
    }

    @Test
    func isIndefinite() {
        var pulse = _SymbolEffect.PulseConfiguration()
        #expect(_SymbolEffect(.pulse(pulse)).isIndefinite == true)
        pulse.trigger = .condition(true)
        #expect(_SymbolEffect(.pulse(pulse)).isIndefinite == false)
        #expect(_SymbolEffect(.scale(.init())).isIndefinite == true)

        var options = _SymbolEffect.Options()
        options.repeatCount = 2
        #expect(_SymbolEffect(.pulse(.init()), options: options).isIndefinite == false)
        options.repeatCount = .infinity
        #expect(_SymbolEffect(.pulse(pulse), options: options).isIndefinite == true)
    }

    @Test(arguments: [
        (UInt32(0x01), UInt32(0x21)),
        (UInt32(0x11), UInt32(0x21)),
        (UInt32(0x21), UInt32(0x11)),
        (UInt32(0x31), UInt32(0x01)),
    ])
    func appendSymbolEffectAppliesRightToLeft(flags: UInt32, expected: UInt32) throws {
        var wiggle = _SymbolEffect.WiggleConfiguration()
        wiggle.flags = .init(rawValue: flags)
        wiggle.appliesRTL = true
        var environment = EnvironmentValues()
        environment.layoutDirection = .rightToLeft
        environment.appendSymbolEffect(_SymbolEffect(.wiggle(wiggle)), for: 7)

        let identified = try #require(environment.symbolEffects.first)
        #expect(identified.identifier == 7)
        #expect(identified.serial == 0)
        guard case let .wiggle(result) = identified.effect.storage else {
            Issue.record("Expected a wiggle effect")
            return
        }
        #expect(result.flags.rawValue == expected)
        #expect(result.appliesRTL == false)
    }

    @Test
    func appendSymbolEffectKeepsLeftToRight() throws {
        var wiggle = _SymbolEffect.WiggleConfiguration()
        wiggle.flags = .init(rawValue: 0x11)
        wiggle.appliesRTL = true
        var environment = EnvironmentValues()
        environment.layoutDirection = .leftToRight
        environment.appendSymbolEffect(_SymbolEffect(.wiggle(wiggle)), for: 1)

        let identified = try #require(environment.symbolEffects.first)
        #expect(identified.effect == _SymbolEffect(.wiggle(wiggle)))
    }

    @Test
    func protobufEncoding() throws {
        var bounce = _SymbolEffect.BounceConfiguration()
        bounce.flags = .up
        bounce.layered = false
        try expectEncoding(_SymbolEffect(.bounce(bounce)), hex: "0a06120410011800")

        var pulse = _SymbolEffect.PulseConfiguration()
        pulse.trigger = .condition(true)
        try expectEncoding(_SymbolEffect(.pulse(pulse)), hex: "0a060a041a021001")

        var options = _SymbolEffect.Options()
        options.speed = 2
        try expectEncoding(_SymbolEffect(.pulse(.init()), options: options), hex: "0a020a0012050d00000040")
    }

    private func expectEncoding(_ effect: _SymbolEffect, hex: String) throws {
        let data = try ProtobufEncoder.encoding(effect)
        #expect(data.map { String(format: "%02x", $0) }.joined() == hex)
        var decoder = ProtobufDecoder(data)
        #expect(try _SymbolEffect(from: &decoder) == effect)
    }
}
