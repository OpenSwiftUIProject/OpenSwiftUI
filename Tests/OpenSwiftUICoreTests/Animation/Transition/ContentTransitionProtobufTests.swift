//
//  ContentTransitionProtobufTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenRenderBoxShims
@_spi(Private) @testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@Suite(.tags(.aigc))
struct ContentTransitionProtobufTests {
    static let namedCases: [(ContentTransition, [UInt8])] = [
        (.default, [0x0a, 0]),
        (.identity, [0x0a, 2, 0x0a, 0]),
        (.opacity, [0x0a, 2, 0x12, 0]),
        (.interpolate, [0x0a, 2, 0x1a, 0]),
        (.fadeIfDifferent, [0x0a, 2, 0x22, 0]),
        (.text, [0x0a, 2, 0x2a, 0]),
        (.differentText, [0x0a, 4, 0x2a, 2, 8, 1]),
        (.numericText(value: 0), [0x0a, 7, 0x32, 5, 0x15, 0, 0, 0, 0]),
    ]

    @Test(arguments: namedCases)
    func namedWireValues(transition: ContentTransition, bytes: [UInt8]) throws {
        #expect(try ProtobufEncoder.encoding(transition) == Data(bytes))
        #expect(try decode(ContentTransition.self, bytes) == transition)
    }

    @Test
    func replacementFlagAndLastStorageFieldWin() throws {
        var transition = ContentTransition.opacity
        transition.isReplaceable = true
        #expect(try ProtobufEncoder.encoding(transition) == Data([0x0a, 2, 0x12, 0, 0x18, 1]))
        let bytes: [UInt8] = [0x18, 1, 0x0a, 2, 0x0a, 0, 0x78, 42, 0x0a, 2, 0x12, 0]
        #expect(try decode(ContentTransition.self, bytes) == transition)
        #expect(try decode(ContentTransition.self, []) == .default)
    }

    @Test
    func optionalNamedEnvironmentFieldsUseWireDefaults() throws {
        let explicit = ContentTransition.NamedTransition(name: .opacity, layoutDirection: .leftToRight, style: .default)
        #expect(try ProtobufEncoder.encoding(explicit) == Data([0x12, 0]))
        #expect(try decode(ContentTransition.NamedTransition.self, [0x12, 0]) == .init(name: .opacity))
        let resolved = ContentTransition.NamedTransition(name: .opacity, layoutDirection: .rightToLeft, style: .sessionWidget)
        let bytes: [UInt8] = [0x12, 0, 0x38, 1, 0x42, 2, 0x0a, 0]
        #expect(try ProtobufEncoder.encoding(resolved) == Data(bytes))
        #expect(try decode(ContentTransition.NamedTransition.self, bytes) == resolved)
    }

    @Test(arguments: [ContentTransition.Style.default, .sessionWidget, .animatedWidget])
    func styleCodableUsesProtobuf(style: ContentTransition.Style) throws {
        let json = try JSONEncoder().encode(style)
        let wire = try JSONDecoder().decode(Data.self, from: json)
        #expect(wire == (try ProtobufEncoder.encoding(style)))
        #expect(try JSONDecoder().decode(ContentTransition.Style.self, from: json) == style)
    }

    @Test
    func numericWireDefaultsAndBlurTags() throws {
        typealias Configuration = ContentTransition.NumericTextConfiguration
        #expect(try ProtobufEncoder.encoding(Configuration.fixed()) == Data([8, 1]))
        #expect(try ProtobufEncoder.encoding(Configuration.fixed(downwards: true)).isEmpty)
        #expect(try decode(Configuration.self, []) == .fixed())
        #expect(try decode(Configuration.self, [8, 0]) == .fixed(downwards: true))
        #expect(try ProtobufEncoder.encoding(Configuration.fixed().axis(.horizontal)) == Data([8, 1, 0x18, 0]))
        let absolute = Configuration.fixed().blur(radius: 2)
        #expect(try ProtobufEncoder.encoding(absolute) == Data([8, 1, 0x3d, 0, 0, 0, 0x40]))
        var relative = Configuration.fixed()
        relative.relativeBlur = 0.5
        #expect(try ProtobufEncoder.encoding(relative) == Data([8, 1, 0x3d, 0, 0, 0, 0x3f]))
        #expect(try decode(Configuration.self, [0x4d, 0, 0, 0, 0x3f]) == relative)
        #expect(try decode(Configuration.self, [0x3d, 0, 0, 0, 0x3f]) == .fixed().blur(radius: 0.5))
    }

    @Test
    func customTransitionPreservesEffectOrderButOmitsLayoutDirection() throws {
        var transition = ContentTransition.CustomTransition(effects: [.init(.opacity), .init(.matchMove)], method: .diff)
        transition.layoutDirection = .rightToLeft
        let bytes: [UInt8] = [8, 1, 0x12, 0, 0x12, 2, 8, 5]
        #expect(try ProtobufEncoder.encoding(transition) == Data(bytes))
        let decoded = try decode(ContentTransition.CustomTransition.self, bytes)
        #expect(decoded.effects == transition.effects)
        #expect(decoded.method == .diff)
        #expect(decoded.layoutDirection == nil)
    }

    @Test
    func effectWireValueIncludesTimelineAndFlags() throws {
        let effect = ContentTransition.Effect(
            .translation(CGSize(width: 2, height: 3)), timeline: 0.25 ... 0.75,
            appliesOnInsertion: false
        ).removeInverts(true)
        let bytes: [UInt8] = [
            8, 3, 0x25, 0, 0, 0x80, 0x3e, 0x4d, 0, 0, 0, 0x3f, 0x30, 2,
            0x15, 0, 0, 0, 0x40, 0x1d, 0, 0, 0x40, 0x40, 0x50, 1,
        ]
        #expect(try ProtobufEncoder.encoding(effect) == Data(bytes))
        #expect(try decode(ContentTransition.Effect.self, bytes) == effect)
    }

    @Test
    func legacyEffectEndTimeUsesCurrentBeginTime() throws {
        let effect = try decode(ContentTransition.Effect.self, [0x25, 0, 0, 0x80, 0x3e, 0x2d, 0, 0, 0x40, 0x3f])
        #expect(effect.begin == 0.25)
        #expect(effect.duration == 0.5)
        let reordered = try decode(ContentTransition.Effect.self, [0x2d, 0, 0, 0x40, 0x3f, 0x25, 0, 0, 0x80, 0x3e])
        #expect(reordered.begin == 0.25)
        #expect(reordered.duration == 0.75)
    }

    @Test
    func integerArgumentsKeepBaselineFieldBehavior() throws {
        let effect = ContentTransition.Effect(type: .init(type: .matchMove, arg0: .int(4), arg1: .int(5)))
        let bytes: [UInt8] = [8, 5, 0x38, 4, 0x40, 5]
        #expect(try ProtobufEncoder.encoding(effect) == Data(bytes))
        let decoded = try decode(ContentTransition.Effect.self, bytes)
        #expect(decoded.type.arg0 == .int(4))
        #expect(decoded.type.arg1 == .none)
    }

    @Test
    func unknownBackendValuesAndOverflow() throws {
        let unknown = try decode(ContentTransition.Effect.self, [8, 123, 0x30, 0x80, 1, 0x50, 0x80, 2])
        #expect(unknown.type.type.rawValue == 123)
        #expect(unknown.events.rawValue == 128)
        #expect(unknown.flags.rawValue == 256)
        let overflow = try decode(ContentTransition.Effect.self, [8, 0x80, 0x80, 0x80, 0x80, 0x10])
        #expect(overflow.type.type.rawValue == 0)
        let events = try decode(ContentTransition.Effect.self, [0x30, 0x80, 0x80, 0x80, 0x80, 0x10])
        #expect(events.events == .addRemove)
    }

    @Test
    func stateRoundTripIncludesAnimationAndOptions() throws {
        let state = ContentTransition.State(
            transition: .opacity, style: .animatedWidget, animation: .linear(duration: 0.75),
            options: [.formsGroup, .animatesDifferentContent, .addsDrawingGroup]
        )
        var decoder = ProtobufDecoder(try ProtobufEncoder.encoding(state))
        #expect(try ContentTransition.State(from: &decoder) == state)
        #expect(try ProtobufEncoder.encoding(ContentTransition.State()).isEmpty)
        #expect(try decode(ContentTransition.State.self, []) == .init())
    }

    static let malformedMessages: [[UInt8]] = [
        [0], [0x0a, 1], [8, 1], [0x1d, 0, 0, 0, 0], [0x0a, 2, 0x32, 1],
    ]

    @Test(arguments: malformedMessages)
    func rejectsMalformedMessages(bytes: [UInt8]) {
        #expect(throws: ProtobufDecoder.DecodingError.self) {
            try decode(ContentTransition.self, bytes)
        }
    }

    private func decode<T: ProtobufDecodableMessage>(_ type: T.Type, _ bytes: [UInt8]) throws -> T {
        var decoder = ProtobufDecoder(Data(bytes))
        return try T(from: &decoder)
    }
}
