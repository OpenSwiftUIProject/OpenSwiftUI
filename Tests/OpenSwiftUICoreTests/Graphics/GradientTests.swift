//
//  GradientTests.swift
//  OpenSwiftUICoreTests

import Foundation
@testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

// MARK: - Gradient

@Suite(.tags(.aigc))
@MainActor
struct GradientTests {
    @Test
    func stopsPreserveOrderDuplicatesAndExtendedLocations() {
        let red = Color(rgba(1, 0, 0))
        let blue = Color(rgba(0, 0, 1))
        let stops: [Gradient.Stop] = [
            .init(color: red, location: 1.5),
            .init(color: blue, location: -0.5),
            .init(color: red, location: -0.5),
        ]
        var gradient = Gradient(stops: stops)
        #expect(gradient.stops == stops)

        let original = gradient
        gradient.stops[0].location = 0.25
        #expect(original.stops[0].location == 1.5)
        #expect(gradient.stops[0].location == 0.25)
    }

    @Test(arguments: [
        (0, []),
        (1, [0]),
        (2, [0, 1]),
        (3, [0, 0.5, 1]),
        (5, [0, 0.25, 0.5, 0.75, 1]),
    ] as [(Int, [CGFloat])])
    func colorsAreEvenlyDistributed(count: Int, locations: [CGFloat]) {
        let colors = (0..<count).map { Color(rgba(Float($0) / 4, 0, 0)) }
        let gradient = Gradient(colors: colors)
        #expect(gradient.stops.map(\.color) == colors)
        #expect(gradient.stops.map(\.location) == locations)
    }

    @Test
    func constantAndFallbackColorsUseStopCount() {
        let red = Color(rgba(1, 0, 0))
        let blue = Color(rgba(0, 0, 1))
        let empty = Gradient(colors: [])
        #expect(empty.constantColor == .clear)
        #expect(empty.fallbackColor == nil)

        let single = Gradient(stops: [.init(color: red, location: 2)])
        #expect(single.constantColor == red)
        #expect(single.fallbackColor == red)

        let repeated = Gradient(colors: [red, red])
        #expect(repeated.constantColor == nil)
        #expect(repeated.fallbackColor == red)

        let mixed = Gradient(colors: [blue, red])
        #expect(mixed.constantColor == nil)
        #expect(mixed.fallbackColor == blue)
    }

    @Test
    func reversalPreservesDuplicatesAndDoesNotClamp() {
        let red = Color(rgba(1, 0, 0))
        let blue = Color(rgba(0, 0, 1))
        let green = Color(rgba(0, 1, 0))
        let gradient = Gradient(stops: [
            .init(color: red, location: -0.25),
            .init(color: blue, location: 0.75),
            .init(color: green, location: 0.75),
        ])
        #expect(gradient.reversed.stops == [
            .init(color: green, location: 0.25),
            .init(color: blue, location: 0.25),
            .init(color: red, location: 1.25),
        ])
        #expect(gradient.reversed.reversed == gradient)
        #expect(Gradient(stops: []).reversed.stops.isEmpty)
    }

    @Test
    func equalityAndHashingIncludeStopOrder() {
        let red = Color(rgba(1, 0, 0))
        let blue = Color(rgba(0, 0, 1))
        let gradient = Gradient(colors: [red, blue])
        let equal = Gradient(stops: [
            .init(color: red, location: 0),
            .init(color: blue, location: 1),
        ])
        #expect(gradient == equal)
        #expect(gradient.hashValue == equal.hashValue)
        #expect(Set([gradient, equal]).count == 1)
        #expect(gradient != Gradient(colors: [blue, red]))
        #expect(gradient != Gradient(colors: [red]))
    }

    @Test(arguments: [ColorScheme.light, .dark])
    func resolutionUsesTheSuppliedEnvironment(scheme: ColorScheme) {
        var environment = EnvironmentValues()
        environment.colorScheme = scheme
        let gradient = Gradient(stops: [
            .init(color: Color(provider: GradientSchemeColor()), location: 0.75),
            .init(color: Color(rgba(0, 1, 0, 0.5)), location: -0.25),
        ])
        let resolved = gradient.resolve(in: environment)
        #expect(resolved.colorSpace == .default)
        #expect(resolved.stops.map(\.location) == [0.75, -0.25])
        #expect(resolved.stops[0].color == (scheme == .light ? rgba(1, 0, 0) : rgba(0, 0, 1)))
        #expect(resolved.stops[1].color == rgba(0, 1, 0, 0.5))
        #expect(resolved.stops.allSatisfy { $0.interpolation == nil })
        #expect(Gradient(colors: []).resolve(in: environment).stops.isEmpty)
    }

    @Test
    func resolvedInitializerKeepsColorsAndLocations() {
        let source = ResolvedGradient(stops: [
            stop(rgba(1, 0, 0, 0.5), -0.25, curveA),
            stop(rgba(0, 0, 1), 1.25),
        ], colorSpace: .linear)
        let gradient = Gradient(source)
        #expect(gradient.stops == [
            .init(color: Color(rgba(1, 0, 0, 0.5)), location: -0.25),
            .init(color: Color(rgba(0, 0, 1)), location: 1.25),
        ])
        let resolved = gradient.resolve(in: EnvironmentValues())
        #expect(resolved.colorSpace == .default)
        #expect(resolved.stops.allSatisfy { $0.interpolation == nil })
        #expect(Gradient(ResolvedGradient(stops: [], colorSpace: .linear)).stops.isEmpty)
    }

    @Test
    func shapeStyleResolvesToTopToBottomLinearPaint() throws {
        var environment = EnvironmentValues()
        environment.setTestSystemColorDefinition()
        let gradient = Gradient(colors: [Color(rgba(1, 0, 0)), Color(rgba(0, 0, 1))])
        var shape = _ShapeStyle_Shape(
            operation: .resolveStyle(name: .foreground, levels: 0..<1),
            environment: environment
        )
        gradient._apply(to: &shape)
        guard case let .paint(anyPaint) = shape.stylePack[.foreground, 0].fill else {
            Issue.record("Expected a gradient paint")
            return
        }
        let paint = try #require(anyPaint.as(type: LinearGradient._Paint.self))
        #expect(paint.startPoint == UnitPoint(x: 0.5, y: 0))
        #expect(paint.endPoint == UnitPoint(x: 0.5, y: 1))
        #expect(paint.gradient.stops == [stop(rgba(1, 0, 0), 0), stop(rgba(0, 0, 1), 1)])
        #expect(shape.stylePack[.foreground, 0].opacity == 1)
    }

    @Test
    func shapeStyleUsesTheFirstColorOnlyForFallback() {
        let red = Color(rgba(1, 0, 0))
        let gradient = Gradient(colors: [red, Color(rgba(0, 0, 1))])
        var fallback = _ShapeStyle_Shape(operation: .fallbackColor(level: 0))
        gradient._apply(to: &fallback)
        guard case let .color(color) = fallback.result else {
            Issue.record("Expected a fallback color")
            return
        }
        #expect(color == red)

        var text = _ShapeStyle_Shape(operation: .prepareText(level: 0))
        gradient._apply(to: &text)
        guard case .preparedText(.foregroundKeyColor) = text.result else {
            Issue.record("Expected the foreground key color")
            return
        }
    }

    @Test
    func emptyShapeStyleHasNoFallbackAndPreservesMultiLevelResult() {
        let gradient = Gradient(colors: [])
        var shape = _ShapeStyle_Shape(operation: .fallbackColor(level: 0))
        gradient._apply(to: &shape)
        guard case .none = shape.result else {
            Issue.record("An empty gradient must not supply a fallback color")
            return
        }
        shape.operation = .multiLevel
        shape.result = .bool(true)
        gradient._apply(to: &shape)
        guard case let .bool(value) = shape.result else {
            Issue.record("Expected the existing multi-level result")
            return
        }
        #expect(value == true)
    }
}

// MARK: - Gradient.Stop

@Suite(.tags(.aigc))
struct GradientStopTests {
    @Test
    func mutationEqualityAndHashing() {
        let red = Color(rgba(1, 0, 0))
        let original = Gradient.Stop(color: red, location: -0.5)
        var value = original
        #expect(value == Gradient.Stop(color: red, location: -0.5))
        #expect(Set([original, value]).count == 1)
        value.location = 0.5
        #expect(value != original)
        value.location = -0.5
        value.color = Color(rgba(0, 0, 1))
        #expect(value != original)
        #expect(original.color == red)
        #expect(original.location == -0.5)
    }

    @Test
    func locationEqualityFollowsFloatingPointRules() {
        let color = Color(rgba(1, 0, 0))
        let positiveZero = Gradient.Stop(color: color, location: 0)
        let negativeZero = Gradient.Stop(color: color, location: -CGFloat.zero)
        #expect(positiveZero == negativeZero)
        #expect(positiveZero.hashValue == negativeZero.hashValue)
        let nan = Gradient.Stop(color: color, location: .nan)
        #expect(nan != nan)
    }

    @Test(arguments: [ColorScheme.light, .dark])
    func resolvesColorWithoutChangingLocation(scheme: ColorScheme) {
        var environment = EnvironmentValues()
        environment.colorScheme = scheme
        let value = Gradient.Stop(color: Color(provider: GradientSchemeColor()), location: 1.5)
        let resolved = value.resolve(in: environment)
        #expect(resolved.color == (scheme == .light ? rgba(1, 0, 0) : rgba(0, 0, 1)))
        #expect(resolved.location == 1.5)
        #expect(resolved.interpolation == nil)
    }
}

// MARK: - ResolvedGradient

@Suite(.tags(.aigc))
@MainActor
struct ResolvedGradientTests {
    @Test
    func initializersPreserveStopsAndChooseColorSpace() {
        let empty = ResolvedGradient()
        #expect(empty.stops.isEmpty)
        #expect(empty.colorSpace == .default)
        let stops = [stop(rgba(1, 0, 0), 1.25, curveA), stop(rgba(0, 0, 1), -0.25)]
        #expect(ResolvedGradient(stops: stops).colorSpace == .default)
        var gradient = ResolvedGradient(stops: stops, colorSpace: .linear)
        #expect(gradient.stops == stops)
        #expect(gradient.colorSpace == .linear)
        let original = gradient
        gradient.stops[0].location = 0
        gradient.colorSpace = .device
        #expect(original.stops[0].location == 1.25)
        #expect(original.colorSpace == .linear)
    }

    @Test(arguments: [
        ([], true, false),
        ([0], true, false),
        ([-Float.zero, 0], true, false),
        ([1], false, true),
        ([1, 1], false, true),
        ([0, 1], false, false),
        ([0.5], false, false),
        ([-1], false, false),
        ([2], false, false),
        ([.nan], false, false),
    ] as [([Float], Bool, Bool)])
    func opacityFlags(opacities: [Float], isClear: Bool, isOpaque: Bool) {
        let gradient = ResolvedGradient(
            stops: opacities.map { stop(rgba(1, 0, 0, $0), 0) },
            colorSpace: .linear
        )
        #expect(gradient.isClear == isClear)
        #expect(gradient.isOpaque == isOpaque)
    }

    @Test
    func constantColorChecksEveryStopButNotItsMetadata() {
        let red = rgba(1, 0, 0)
        #expect(ResolvedGradient().constantColor == .clear)
        #expect(ResolvedGradient(stops: [stop(red, 2)]).constantColor == red)
        var gradient = ResolvedGradient(stops: [
            stop(red, -1), stop(red, 0.5, curveA), stop(red, 2, curveB),
        ], colorSpace: .perceptual)
        #expect(gradient.constantColor == red)
        gradient.stops[2].color = rgba(0, 0, 1)
        #expect(gradient.constantColor == nil)
        gradient.stops[2].color = rgba(1, 0, 0, 0.5)
        #expect(gradient.constantColor == nil)
        gradient.stops = [stop(rgba(1, 0, 0, 0), 0), stop(rgba(0, 0, 1, 0), 1)]
        #expect(gradient.constantColor == nil)
    }

    @Test
    func constantColorHandlesNaNAndSignedZero() throws {
        let nan = rgba(.nan, 0, 0)
        let single = ResolvedGradient(stops: [stop(nan, 0)])
        #expect(try #require(single.constantColor).linearRed.isNaN)
        let repeated = ResolvedGradient(stops: [stop(nan, 0), stop(nan, 1)])
        #expect(repeated.constantColor == nil)
        let zeros = ResolvedGradient(stops: [
            stop(rgba(0, 0, 0), 0), stop(rgba(-Float.zero, 0, 0), 1),
        ])
        #expect(zeros.constantColor == rgba(0, 0, 0))
    }

    @Test(arguments: [
        ([], 0), ([false], 0), ([true], 1), ([false, true, false, true], 2),
    ] as [([Bool], Int)])
    func interpolationQueries(flags: [Bool], count: Int) {
        let gradient = ResolvedGradient(stops: flags.map {
            stop(rgba(1, 0, 0), 0, $0 ? .linear : nil)
        })
        #expect(gradient.hasInterpolations == (count != 0))
        #expect(gradient.interpolationsCount == count)
    }

    @Test(arguments: [
        (-1, -0.5, -0.25), (0, 0, 0), (0.5, 0.25, 0.125), (2, 1, 0.5),
    ] as [(Float, Float, Float)])
    func opacityMultiplicationPreservesOtherFields(factor: Float, first: Float, second: Float) {
        var gradient = ResolvedGradient(stops: [
            stop(rgba(1, 0, 0, 0.5), -0.25, curveA),
            stop(rgba(0, 0, 1, 0.25), 1.25, curveB),
        ], colorSpace: .linear)
        gradient.multiplyOpacity(by: factor)
        #expect(gradient.stops == [
            stop(rgba(1, 0, 0, first), -0.25, curveA),
            stop(rgba(0, 0, 1, second), 1.25, curveB),
        ])
        #expect(gradient.colorSpace == .linear)
        var empty = ResolvedGradient(stops: [], colorSpace: .device)
        empty.multiplyOpacity(by: factor)
        #expect(empty == ResolvedGradient(stops: [], colorSpace: .device))
    }

    @Test
    func equalityIncludesStopFieldsOrderAndColorSpace() {
        let original = ResolvedGradient(stops: [
            stop(rgba(1, 0, 0), 0, curveA), stop(rgba(0, 0, 1), 1),
        ], colorSpace: .linear)
        #expect(original == ResolvedGradient(stops: original.stops, colorSpace: .linear))
        var changed = original
        changed.colorSpace = .device
        #expect(changed != original)
        changed = original
        changed.stops.reverse()
        #expect(changed != original)
        changed = original
        changed.stops[0].interpolation = curveB
        #expect(changed != original)
    }

    @Test(arguments: [(.v4, false), (.v5, true), (.v6, true)] as [(Semantics, Bool)])
    func animationGetterUsesLinkedSemantics(semantics: Semantics, enabled: Bool) {
        let gradient = ResolvedGradient(stops: [stop(rgba(1, 0, 0, 0.5), 0.25, curveA)], colorSpace: .linear)
        semantics.test {
            if enabled {
                #expect(gradient.animatableData == ResolvedGradientVector(gradient))
                #expect(gradient.animatableData.magnitudeSquared == 0.5)
            } else {
                #expect(gradient.animatableData == .zero)
            }
        }
    }

    @Test(arguments: [(.v4, false), (.v5, true), (.v6, true)] as [(Semantics, Bool)])
    func animationSetterUsesIncomingColorSpaceButKeepsDestinationSpace(
        semantics: Semantics,
        enabled: Bool
    ) {
        let source = ResolvedGradient(stops: [stop(rgba(0.5, 0.25, 1, 0.5), 0.75, curveA)], colorSpace: .linear)
        var destination = ResolvedGradient(stops: [stop(rgba(1, 0, 0), -1)], colorSpace: .perceptual)
        let original = destination
        semantics.test {
            destination.animatableData = ResolvedGradientVector(source)
            #expect(destination.colorSpace == .perceptual)
            #expect(destination.stops == (enabled ? source.stops : original.stops))
            destination.animatableData = .zero
            #expect(destination.stops == (enabled ? [] : original.stops))
            #expect(destination.colorSpace == .perceptual)
        }
    }
}

// MARK: - ResolvedGradient.Stop

@Suite(.tags(.aigc))
struct ResolvedGradientStopTests {
    @Test
    func initializationAndEqualityIncludeAllFields() {
        let original = ResolvedGradient.Stop(color: rgba(1, 0, 0), location: 0.5)
        #expect(original.interpolation == nil)
        #expect(original == stop(rgba(1, 0, 0), 0.5))
        #expect(original != stop(rgba(0, 0, 1), 0.5))
        #expect(original != stop(rgba(1, 0, 0, 0.5), 0.5))
        #expect(original != stop(rgba(1, 0, 0), 0.75))
        #expect(original != stop(rgba(1, 0, 0), 0.5, .linear))
        var changed = original
        changed.interpolation = curveA
        #expect(changed.interpolation == curveA)
        #expect(original.interpolation == nil)
    }

    @Test(arguments: [
        (nil, ""),
        (.linear, "1a00"),
        (ResolvedGradient.Interpolation(p1: (0.25, 0.5), p2: (0.75, 1)), "1a0f0d0000803e150000003f1d0000403f"),
        (ResolvedGradient.Interpolation(p1: (0, 0), p2: (0, 0)), "1a0a1d000000002500000000"),
    ] as [(ResolvedGradient.Interpolation?, String)])
    func protobufEncodesOptionalInterpolation(interpolation: ResolvedGradient.Interpolation?, suffix: String) throws {
        let value = stop(rgba(1, 0, 0), 0.5, interpolation)
        let bytes = "0a0a0d0000803f250000803f150000003f" + suffix
        try value.testPBEncoding(hexString: bytes)
        let decoded = try bytes.decodePBHexString(ResolvedGradient.Stop.self)
        #expect(decoded == value)
        #expect(decoded.location == 0.5)
        #expect(decoded.color == rgba(1, 0, 0))
    }

    @Test
    func protobufDefaultsAndUnknownFields() throws {
        let absent = try "".decodePBHexString(ResolvedGradient.Stop.self)
        #expect(absent == stop(.clear, 0))
        let emptyCurve = try "1a00".decodePBHexString(ResolvedGradient.Stop.self)
        #expect(emptyCurve == stop(.clear, 0, .linear))
        let partialCurve = try "38011a0728012500000000".decodePBHexString(ResolvedGradient.Stop.self)
        #expect(partialCurve.interpolation == ResolvedGradient.Interpolation(p1: (0, 0), p2: (1, 0)))
        #expect(partialCurve.color == .clear)
        #expect(partialCurve.location == 0)
    }

    @Test
    func protobufUsesTheLastSingularField() throws {
        let bytes = "150000003f150000803f1a050d0000803e1a00"
        let value = try bytes.decodePBHexString(ResolvedGradient.Stop.self)
        #expect(value.location == 1)
        #expect(value.interpolation == .linear)
    }

    @Test
    func protobufPreservesWideLocations() throws {
        let value = stop(rgba(1, 0, 0), 65_536)
        let bytes = "0a0a0d0000803f250000803f11000000000000f040"
        try value.testPBEncoding(hexString: bytes)
        let decoded = try bytes.decodePBHexString(ResolvedGradient.Stop.self)
        #expect(decoded.location == 65_536)
        #expect(decoded.color == rgba(1, 0, 0))
    }

    @Test(arguments: ["15", "1a01", "1a010d", "0a02ff"])
    func protobufRejectsTruncatedFields(bytes: String) {
        #expect(throws: Error.self) {
            try bytes.decodePBHexString(ResolvedGradient.Stop.self)
        }
    }
}

// MARK: - ResolvedGradient.ColorSpace

@Suite(.tags(.aigc))
struct ResolvedGradientColorSpaceTests {
    @Test(arguments: [
        (0, .device), (1, .linear), (2, .perceptual),
        (3, nil), (255, nil), (256, nil), (.max, nil),
    ] as [(UInt, ResolvedGradient.ColorSpace?)])
    func protobufValuesUseTheFullInteger(value: UInt, expected: ResolvedGradient.ColorSpace?) {
        #expect(ResolvedGradient.ColorSpace(protobufValue: value) == expected)
        if let expected {
            #expect(expected.protobufValue == value)
            #expect(UInt(expected.rawValue) == value)
        }
    }

    @MainActor
    @Test
    func defaultMatchesTheLinkedSDK() {
        // The static default is initialized once, outside forced-semantics scopes.
        let expected: ResolvedGradient.ColorSpace = isLinkedOnOrAfter(.v4) ? .perceptual : .device
        #expect(ResolvedGradient.ColorSpace.default == expected)
        #expect(Set<ResolvedGradient.ColorSpace>([.device, .linear, .perceptual, .device]).count == 3)
    }

    @Test
    func linearConversionUsesPremultipliedExtendedComponents() {
        let source = rgba(2, -1, 0.5, 0.25)
        let converted = ResolvedGradient.ColorSpace.linear.convertIn(source)
        #expect(converted == .init(r: 0.5, g: -0.25, b: 0.125, a: 0.25))
        #expect(ResolvedGradient.ColorSpace.linear.convertOut(converted) == source)
    }

    @Test(arguments: [
        (.device, 0, 0.21404114), (.device, -Float.zero, 0.21404114),
        (.linear, 0, 0.5), (.linear, -Float.zero, 0.5),
        (.perceptual, 0, 0.125), (.perceptual, -Float.zero, 0.125),
    ] as [(ResolvedGradient.ColorSpace, Float, Float)])
    func zeroAlphaSkipsUnpremultiplication(space: ResolvedGradient.ColorSpace, opacity: Float, expected: Float) {
        let components = ResolvedGradient.ColorSpace.InterpolatableColor(r: 0.5, g: 0.5, b: 0.5, a: opacity)
        let result = space.convertOut(components)
        expectColor(result, rgba(expected, expected, expected, opacity))
        #expect(result.opacity.sign == opacity.sign)
    }

    @Test(arguments: [ResolvedGradient.ColorSpace.device, .linear, .perceptual])
    func conversionRoundTripPreservesExtendedColorsAndAlpha(space: ResolvedGradient.ColorSpace) {
        let input = rgba(2, -0.25, 0.5, 0.25)
        let output = space.convertOut(space.convertIn(input))
        expectColor(output, rgba(2, -0.25, 0.5, 0.25), tolerance: 0.00001)
        let transparent = space.convertIn(rgba(2, -0.25, 0.5, 0))
        #expect(transparent == .init(r: 0, g: 0, b: 0, a: 0))
    }

    @Test(arguments: [
        (0, 0), (0.0031308, 0.04044994), (0.25, 0.53709873),
        (1, 1), (-1, -1), (-0.25, -0.53709873), (2, 1.353256),
    ] as [(Float, Float)])
    func deviceConversionIn(linear: Float, expected: Float) {
        let value = ResolvedGradient.ColorSpace.device.convertIn(rgba(linear, linear, linear))
        #expect(abs(value.r - expected) < 0.000002)
        #expect(abs(value.g - expected) < 0.000002)
        #expect(abs(value.b - expected) < 0.000002)
        #expect(value.a == 1)
    }

    @Test(arguments: [
        (0, 0), (0.04045, 0.003130805), (0.5, 0.21404114),
        (1, 1), (-1, -1), (-0.5, -0.21404114), (2, 4.953846),
    ] as [(Float, Float)])
    func deviceConversionOut(device: Float, expected: Float) {
        let value = ResolvedGradient.ColorSpace.device.convertOut(.init(r: device, g: device, b: device, a: 1))
        expectColor(value, rgba(expected, expected, expected), tolerance: 0.00001)
    }

    @Test(arguments: [
        (Float.zero, .plus), (-Float.zero, .minus),
    ] as [(Float, FloatingPointSign)])
    func deviceConversionPreservesTheSignOfZero(value: Float, expectedSign: FloatingPointSign) {
        let converted = ResolvedGradient.ColorSpace.device.convertIn(rgba(value, value, value))
        #expect(converted.r == 0)
        #expect(converted.r.sign == expectedSign)
        #expect(converted.g.sign == expectedSign)
        #expect(converted.b.sign == expectedSign)
        let result = ResolvedGradient.ColorSpace.device.convertOut(.init(r: value, g: value, b: value, a: 1))
        #expect(result.linearRed == 0)
        #expect(result.linearRed.sign == expectedSign)
        #expect(result.linearGreen.sign == expectedSign)
        #expect(result.linearBlue.sign == expectedSign)
    }

    @Test
    func perceptualConversionUsesSignedRootLMSAndPremultiplies() {
        let red = ResolvedGradient.ColorSpace.perceptual.convertIn(rgba(1, 0, 0, 0.5))
        #expect(abs(red.r - 0.37211760) < 0.000001)
        #expect(abs(red.g - 0.29809135) < 0.000001)
        #expect(abs(red.b - 0.22265252) < 0.000001)
        #expect(red.a == 0.5)
        let negative = ResolvedGradient.ColorSpace.perceptual.convertIn(rgba(-0.125, -0.125, -0.125))
        #expect(abs(negative.r + 0.5) < 0.000001)
        #expect(abs(negative.g + 0.5) < 0.000001)
        #expect(abs(negative.b + 0.5) < 0.000001)
    }

    @Test(arguments: [
        ([1, 0, 0], [4.0767417, -1.2684380, -0.0041960863]),
        ([0, 1, 0], [-3.3077116, 2.6097574, -0.7034186]),
        ([0, 0, 1], [0.23096993, -0.3413194, 1.7076147]),
        ([-0.5, -0.5, -0.5], [-0.125, -0.125, -0.125]),
    ] as [([Float], [Float])])
    func perceptualConversionOut(components: [Float], expected: [Float]) {
        let value = ResolvedGradient.ColorSpace.perceptual.convertOut(
            .init(r: components[0], g: components[1], b: components[2], a: 1)
        )
        expectColor(value, rgba(expected[0], expected[1], expected[2]), tolerance: 0.000002)
    }

    @Test(arguments: [
        (.device, 0.21404114), (.linear, 0.5), (.perceptual, 0.125),
    ] as [(ResolvedGradient.ColorSpace, Float)])
    func midpointDependsOnColorSpace(space: ResolvedGradient.ColorSpace, expected: Float) {
        let result = space.mix(rgba(0, 0, 0), rgba(1, 1, 1), by: 0.5)
        expectColor(result, rgba(expected, expected, expected))
    }

    @Test
    func mixUsesPremultipliedAlphaAndDoesNotShortcutEndpoints() {
        let space = ResolvedGradient.ColorSpace.linear
        let result = space.mix(rgba(1, 0, 0, 0.25), rgba(0, 0, 1, 0.75), by: 0.5)
        #expect(result == rgba(0.25, 0, 0.75, 0.5))
        #expect(space.mix(rgba(1, 0, 0, 0), rgba(0, 0, 1), by: 0.5) == rgba(0, 0, 1, 0.5))
        #expect(space.mix(rgba(1, 0, 0, 0), rgba(0, 0, 1), by: 0) == .clear)
        #expect(space.mix(rgba(1, 0, 0), rgba(0, 0, 1), by: 1) == rgba(0, 0, 1))
    }

    @Test(arguments: [(-1, 2, -1), (2, -1, 2)] as [(Float, Float, Float)])
    func mixDoesNotClampTheFraction(fraction: Float, red: Float, blue: Float) {
        let result = ResolvedGradient.ColorSpace.linear.mix(rgba(1, 0, 0), rgba(0, 0, 1), by: fraction)
        #expect(result == rgba(red, 0, blue))
    }

    @Test(arguments: [ResolvedGradient.ColorSpace.device, .linear, .perceptual])
    func nanFractionPropagates(space: ResolvedGradient.ColorSpace) {
        let result = space.mix(rgba(1, 0, 0), rgba(0, 0, 1), by: .nan)
        #expect(result.linearRed.isNaN)
        #expect(result.linearGreen.isNaN)
        #expect(result.linearBlue.isNaN)
        #expect(result.opacity.isNaN)
    }
}

// MARK: - ResolvedGradient.ColorSpace.InterpolatableColor

@Suite(.tags(.aigc))
struct ResolvedGradientInterpolatableColorTests {
    @Test
    func componentArithmeticAndMagnitude() {
        let lhs = ResolvedGradient.ColorSpace.InterpolatableColor(r: 1, g: 2, b: -3, a: 4)
        let rhs = ResolvedGradient.ColorSpace.InterpolatableColor(r: -2, g: 1, b: 4, a: -0.5)
        #expect(lhs + rhs == .init(r: -1, g: 3, b: 1, a: 3.5))
        #expect(lhs * -2 == .init(r: -2, g: -4, b: 6, a: -8))
        #expect(lhs.magnitudeSquared == 30)
    }

    @Test
    func magnitudeAccumulatesInFloatBeforeDoubleConversion() {
        let value = ResolvedGradient.ColorSpace.InterpolatableColor(r: 4096, g: 1, b: 1, a: 1)
        #expect(value.magnitudeSquared == 16_777_216)
    }

    @Test
    func equalityIncludesEveryComponentAndUsesFloatRules() {
        let zero = ResolvedGradient.ColorSpace.InterpolatableColor(r: 0, g: 0, b: 0, a: 0)
        #expect(zero == .init(r: -0.0, g: 0, b: 0, a: 0))
        #expect(zero != .init(r: 1, g: 0, b: 0, a: 0))
        #expect(zero != .init(r: 0, g: 1, b: 0, a: 0))
        #expect(zero != .init(r: 0, g: 0, b: 1, a: 0))
        #expect(zero != .init(r: 0, g: 0, b: 0, a: 1))
        let nan = ResolvedGradient.ColorSpace.InterpolatableColor(r: .nan, g: 0, b: 0, a: 1)
        #expect(nan != nan)
    }
}

// MARK: - ResolvedGradient + ProtobufMessage / CodableByProtobuf

@Suite(.tags(.aigc))
@MainActor
struct ResolvedGradientProtobufTests {
    @Test(arguments: [
        (.device, ""), (.linear, "1001"), (.perceptual, "1002"),
    ] as [(ResolvedGradient.ColorSpace, String)])
    func emptyEncodingOmitsOnlyDevice(space: ResolvedGradient.ColorSpace, bytes: String) throws {
        try ResolvedGradient(stops: [], colorSpace: space).testPBEncoding(hexString: bytes)
    }

    @Test
    func repeatedMessagesPreserveOrderAndDuplicates() throws {
        let gradient = ResolvedGradient(stops: [
            stop(rgba(1, 0, 0), 0.5), stop(rgba(0, 0, 1), 0.25), stop(rgba(1, 0, 0), 0.5),
        ], colorSpace: .linear)
        let bytes = "0a110a0a0d0000803f250000803f150000003f"
            + "0a110a0a1d0000803f250000803f150000803e"
            + "0a110a0a0d0000803f250000803f150000003f1001"
        try gradient.testPBEncoding(hexString: bytes)
        let decoded = try bytes.decodePBHexString(ResolvedGradient.self)
        #expect(decoded == gradient)
        #expect(decoded.stops.map(\.location) == [0.5, 0.25, 0.5])
        #expect(decoded.colorSpace == .linear)
    }

    @Test
    func missingAndUnknownColorSpacesHaveDifferentDefaults() throws {
        let absent = try "".decodePBHexString(ResolvedGradient.self)
        #expect(absent.stops.isEmpty)
        #expect(absent.colorSpace == .default)
        for bytes in ["1003", "10ff01", "108002", "10ffffffffffffffffff01"] {
            let decoded = try bytes.decodePBHexString(ResolvedGradient.self)
            #expect(decoded.colorSpace == .device)
        }
        #expect(try "1000".decodePBHexString(ResolvedGradient.self).colorSpace == .device)
    }

    @Test
    func unknownFieldsAreSkippedAndLastColorSpaceWins() throws {
        let value = try "380110020a003d0000000010010a00".decodePBHexString(ResolvedGradient.self)
        #expect(value.stops == [stop(.clear, 0), stop(.clear, 0)])
        #expect(value.colorSpace == .linear)
    }

    @Test(arguments: ["0a01", "0a0115", "0a021a01", "10"])
    func rejectsTruncatedMessages(bytes: String) {
        #expect(throws: Error.self) {
            try bytes.decodePBHexString(ResolvedGradient.self)
        }
    }

    @Test
    func codableUsesASingleProtobufDataValue() throws {
        let empty = ResolvedGradient(stops: [], colorSpace: .linear)
        let encoded = try JSONEncoder().encode(empty)
        #expect(String(decoding: encoded, as: UTF8.self) == "\"EAE=\"")
        let decoded = try JSONDecoder().decode(ResolvedGradient.self, from: Data("\"EAE=\"".utf8))
        #expect(decoded.stops.isEmpty)
        #expect(decoded.colorSpace == .linear)
    }

    @Test
    func codableRoundTripPreservesStopsAndCurves() throws {
        let source = ResolvedGradient(stops: [
            stop(rgba(1, 0, 0, 0.5), 0.25, curveA), stop(rgba(0, 0, 1), 0.75, .linear),
        ], colorSpace: .perceptual)
        let data = try JSONEncoder().encode(source)
        let decoded = try JSONDecoder().decode(ResolvedGradient.self, from: data)
        #expect(decoded == source)
        #expect(decoded.stops[0].color == rgba(1, 0, 0, 0.5))
        #expect(decoded.stops[0].interpolation == curveA)
        #expect(decoded.stops[1].location == 0.75)
        #expect(decoded.colorSpace == .perceptual)
    }
}

// MARK: - ResolvedGradientVector

// Semantic overrides are synchronous and use the same actor as other semantic tests.
@Suite(.tags(.aigc))
@MainActor
struct ResolvedGradientVectorTests {
    @Test
    func zeroIsAnEmptyDeviceVector() {
        let zero = ResolvedGradientVector()
        #expect(zero == .zero)
        #expect(zero == ResolvedGradientVector(ResolvedGradient(stops: [], colorSpace: .device)))
        #expect(zero != ResolvedGradientVector(ResolvedGradient(stops: [], colorSpace: .linear)))
        #expect(zero.magnitudeSquared == 0)
        #expect(resolvedVector(zero).stops.isEmpty)
        var scaled = zero
        scaled.scale(by: .nan)
        #expect(scaled == .zero)
    }

    @Test
    func initializerConvertsColorsAndKeepsMetadata() {
        let source = ResolvedGradient(stops: [stop(rgba(2, -1, 0.5, 0.5), -0.25, curveA)], colorSpace: .linear)
        let vector = ResolvedGradientVector(source)
        #expect(vector.magnitudeSquared == 1.5625)
        #expect(resolvedVector(vector).stops == [stop(rgba(2, -1, 0.5, 0.5), -0.25, curveA)])
    }

    @Test
    func emptyRightOperandDoesNotChangeColorSpaceOrMetadata() {
        let gradient = ResolvedGradient(stops: [stop(rgba(1, 0, 0), 0.25, curveA)], colorSpace: .linear)
        let original = ResolvedGradientVector(gradient)
        let empty = ResolvedGradientVector(ResolvedGradient(stops: [], colorSpace: .perceptual))
        var value = original
        value += empty
        #expect(value == original)
        value -= empty
        #expect(value == original)
        #expect(original + empty == original)
        #expect(original - empty == original)
    }

    @Test
    func emptyLeftCopiesAdditionButDropsCurvesForSubtraction() {
        let gradient = ResolvedGradient(stops: [
            stop(rgba(1, 0, 0), 0.25, curveA), stop(rgba(0, 0, 1, 0.5), 0.75, curveB),
        ], colorSpace: .linear)
        let rhs = ResolvedGradientVector(gradient)
        #expect(ResolvedGradientVector.zero + rhs == rhs)
        let difference = ResolvedGradientVector.zero - rhs
        #expect(resolvedVector(difference).stops == [
            stop(rgba(1, 0, 0, -1), 0.25), stop(rgba(0, 0, 1, -0.5), 0.75),
        ])
        #expect(difference.magnitudeSquared == 2.5)
        #expect(resolvedVector(rhs).stops == gradient.stops)
    }

    @Test
    func matchingGridAdditionAndSubtractionUseRightColorWeights() {
        let lhs = ResolvedGradientVector(ResolvedGradient(stops: [stop(rgba(1, 0, 0, 0.5), 0.25)], colorSpace: .linear))
        let rhs = ResolvedGradientVector(ResolvedGradient(stops: [stop(rgba(0, 0, 1, 0.25), 0.25)], colorSpace: .linear))
        let sum = lhs + rhs
        let difference = lhs - rhs
        expectColor(resolvedVector(sum).stops[0].color, rgba(2.0 / 3.0, 0, 1.0 / 3.0, 0.75))
        #expect(resolvedVector(difference).stops == [stop(rgba(2, 0, -1, 0.25), 0.25)])
        var inPlace = lhs
        inPlace += rhs
        #expect(inPlace == sum)
        inPlace = lhs
        inPlace -= rhs
        #expect(inPlace == difference)
        #expect(resolvedVector(lhs).stops == [stop(rgba(1, 0, 0, 0.5), 0.25)])
    }

    @Test(arguments: [
        (false, true, true, [0.75, 0.75, 1.75, 1.75]),
        (true, true, true, [0.25, -0.25, 0.25, -0.25]),
        (true, true, false, [-0.25, -0.5, 0.25, 0]),
        (true, false, true, [0.5, 0.25, 0, -0.25]),
        (false, true, false, [0.25, 0.5, 1.75, 2]),
        (false, false, true, [0.5, 0.25, 2, 1.75]),
        (false, false, false, nil),
        (true, false, false, nil),
    ] as [(Bool, Bool, Bool, [Float]?)])
    func matchingGridCurvesScaleTheLeftOperand(
        subtract: Bool,
        hasLeft: Bool,
        hasRight: Bool,
        expected: [Float]?
    ) throws {
        let lhs = ResolvedGradientVector(ResolvedGradient(stops: [
            stop(rgba(1, 0, 0), 0.5, hasLeft ? curveA : nil),
        ], colorSpace: .linear))
        let rhs = ResolvedGradientVector(ResolvedGradient(stops: [
            stop(rgba(0, 0, 1), 0.5, hasRight ? curveB : nil),
        ], colorSpace: .linear))
        let result = resolvedVector(subtract ? lhs - rhs : lhs + rhs)
        #expect(result.stops[0].location == 0.5)
        if let expected {
            let curve = try #require(result.stops[0].interpolation)
            #expect([curve.p1x, curve.p1y, curve.p2x, curve.p2y] == expected)
        } else {
            #expect(result.stops[0].interpolation == nil)
        }
    }

    @Test
    func mergeKeepsLeftMetadataAtSharedAndLeftOnlyLocations() {
        let lhs = ResolvedGradientVector(ResolvedGradient(stops: [
            stop(rgba(1, 0, 0), 0, curveA),
            stop(rgba(1, 0, 0), 0.5, curveB),
            stop(rgba(1, 0, 0), 1),
        ], colorSpace: .linear))
        let rhs = ResolvedGradientVector(ResolvedGradient(stops: [
            stop(rgba(0, 0, 1), 0.5, curveA),
            stop(rgba(0, 0, 1), 0.75, curveB),
            stop(rgba(0, 0, 1), 1, curveA),
            stop(rgba(0, 0, 1), 1.5, curveB),
        ], colorSpace: .linear))
        let result = resolvedVector(lhs + rhs)
        #expect(result.stops.map(\.location) == [0, 0.5, 0.75, 1, 1.5])
        #expect(result.stops.map(\.interpolation) == [curveA, curveB, nil, nil, nil])
        #expect(result.stops.map(\.color) == Array(repeating: rgba(0.5, 0, 0.5, 2), count: 5))
        #expect(resolvedVector(lhs).stops.map(\.interpolation) == [curveA, curveB, nil])
    }

    @Test(arguments: [false, true])
    func mergeSamplesAdjacentColorsWithoutApplyingCurves(subtract: Bool) {
        let lhs = ResolvedGradientVector(ResolvedGradient(stops: [
            stop(rgba(0, 0, 0), 0.25), stop(rgba(0, 0, 0), 0.75),
        ], colorSpace: .linear))
        let rhs = ResolvedGradientVector(ResolvedGradient(stops: [
            stop(rgba(1, 0, 0), 0, curveA), stop(rgba(0, 0, 1), 1, curveB),
        ], colorSpace: .linear))
        let result = resolvedVector(subtract ? lhs - rhs : lhs + rhs)
        let expected: [ResolvedGradient.Stop] = subtract ? [
            stop(rgba(-1, 0, 0, 0), 0),
            stop(rgba(-0.75, 0, -0.25, 0), 0.25),
            stop(rgba(-0.25, 0, -0.75, 0), 0.75),
            stop(rgba(0, 0, -1, 0), 1),
        ] : [
            stop(rgba(0.5, 0, 0, 2), 0),
            stop(rgba(0.375, 0, 0.125, 2), 0.25),
            stop(rgba(0.125, 0, 0.375, 2), 0.75),
            stop(rgba(0, 0, 0.5, 2), 1),
        ]
        #expect(result.stops == expected)
    }

    @Test
    func duplicateLocationsUseTheCursorAndLowerColorWithoutSorting() {
        let lhs = ResolvedGradientVector(ResolvedGradient(stops: [
            stop(rgba(0, 0, 0), 0.5), stop(rgba(0, 0, 0), 0.25),
        ], colorSpace: .linear))
        let rhs = ResolvedGradientVector(ResolvedGradient(stops: [
            stop(rgba(0, 1, 0), -0.5), stop(rgba(1, 0, 0), 0.5),
            stop(rgba(0, 0, 1), 0.5), stop(rgba(0, 1, 0), 1),
        ], colorSpace: .linear))
        let result = resolvedVector(lhs + rhs)
        #expect(result.stops.map(\.location) == [-0.5, 0.5, 0.25, 0.5, 1])
        #expect(result.stops.map(\.color) == [
            rgba(0, 0.5, 0, 2), rgba(0.5, 0, 0, 2), rgba(0.5, 0, 0, 2),
            rgba(0, 0, 0.5, 2), rgba(0, 0.5, 0, 2),
        ])
    }

    @Test
    func unorderedComparisonSelectsTheRightLocation() {
        let lhs = ResolvedGradientVector(ResolvedGradient(stops: [
            stop(rgba(0, 0, 0), 0), stop(rgba(0, 0, 0), 1),
        ], colorSpace: .linear))
        let rhs = ResolvedGradientVector(ResolvedGradient(stops: [
            stop(rgba(1, 0, 0), .nan, curveA), stop(rgba(0, 0, 1), 0.5),
        ], colorSpace: .linear))
        let result = resolvedVector(lhs + rhs)
        #expect(result.stops.count == 4)
        #expect(result.stops[0].location.isNaN)
        #expect(result.stops[0].color == rgba(0.5, 0, 0, 2))
        #expect(result.stops[0].interpolation == nil)
        #expect(result.stops.dropFirst().map(\.location) == [0, 0.5, 1])
        #expect(result.stops[1].color.opacity.isNaN)
    }

    @Test(arguments: [
        (.device, .linear, 0.0625, 4.046875),
        (.perceptual, .linear, 0.0625, 4.046875),
        (.linear, .perceptual, 0.015625, 4.75),
    ] as [(ResolvedGradient.ColorSpace, ResolvedGradient.ColorSpace, Float, Double)])
    func additionConvertsLeftColorsToTheRightSpace(
        leftSpace: ResolvedGradient.ColorSpace,
        rightSpace: ResolvedGradient.ColorSpace,
        expected: Float,
        magnitude: Double
    ) {
        let lhs = ResolvedGradientVector(ResolvedGradient(stops: [
            stop(rgba(0.125, 0.125, 0.125), 0.5),
        ], colorSpace: leftSpace))
        let rhs = ResolvedGradientVector(ResolvedGradient(stops: [stop(rgba(0, 0, 0), 0.5)], colorSpace: rightSpace))
        let result = lhs + rhs
        expectColor(resolvedVector(result).stops[0].color, rgba(expected, expected, expected, 2))
        #expect(abs(result.magnitudeSquared - magnitude) < 0.00001)
    }

    @Test(arguments: [(-2, -1, 6.25), (0, 0, 0), (2, 1, 6.25)] as [(Double, Float, Double)])
    func scalingChangesOnlyColorComponents(factor: Double, opacity: Float, magnitude: Double) {
        let original = ResolvedGradientVector(ResolvedGradient(stops: [
            stop(rgba(2, -1, 0.5, 0.5), -0.25, curveA),
        ], colorSpace: .linear))
        var value = original
        value.scale(by: factor)
        let result = resolvedVector(value)
        #expect(result.stops[0].location == -0.25)
        #expect(result.stops[0].interpolation == curveA)
        #expect(result.stops[0].color == (factor == 0 ? .clear : rgba(2, -1, 0.5, opacity)))
        #expect(value.magnitudeSquared == magnitude)
        #expect(value != .zero)
        #expect(original.magnitudeSquared == 1.5625)
    }

    @Test
    func scalingNarrowsTheDoubleFactorToFloat() {
        let original = ResolvedGradientVector(ResolvedGradient(stops: [stop(rgba(1, 0, 0), 0)], colorSpace: .linear))
        var value = original
        value.scale(by: 1 + Double.ulpOfOne)
        #expect(value == original)
        #expect(value.magnitudeSquared == 2)
    }

    @Test
    func magnitudeSumsFloatStopMagnitudesInDouble() {
        let value = ResolvedGradientVector(ResolvedGradient(stops: [
            stop(rgba(4096, 1, 1), 0), stop(rgba(0, 0, 0), 1),
        ], colorSpace: .linear))
        #expect(value.magnitudeSquared == 16_777_217)
    }

    @Test
    func arithmeticDoesNotMutateSharedStopStorage() {
        let original = ResolvedGradientVector(ResolvedGradient(stops: [
            stop(rgba(1, 0, 0, 0.5), 0.25, curveA),
        ], colorSpace: .linear))
        var value = original
        value += original
        #expect(resolvedVector(value).stops == [
            stop(rgba(1, 0, 0), 0.25, .init(p1: (0.5, 1), p2: (1.5, 2))),
        ])
        value = original
        value -= original
        #expect(resolvedVector(value).stops == [
            stop(.clear, 0.25, .init(p1: (0, 0), p2: (0, 0))),
        ])
        #expect(resolvedVector(original).stops == [stop(rgba(1, 0, 0, 0.5), 0.25, curveA)])
    }

    @Test
    func equalityIncludesColorLocationCurveAndColorSpace() {
        let source = ResolvedGradient(stops: [stop(rgba(1, 0, 0), 0.25, curveA)], colorSpace: .linear)
        let original = ResolvedGradientVector(source)
        #expect(original == ResolvedGradientVector(source))
        var changed = source
        changed.stops[0].color = rgba(0, 0, 1)
        #expect(original != ResolvedGradientVector(changed))
        changed = source
        changed.stops[0].location = 0.5
        #expect(original != ResolvedGradientVector(changed))
        changed = source
        changed.stops[0].interpolation = curveB
        #expect(original != ResolvedGradientVector(changed))
        changed = source
        changed.colorSpace = .device
        #expect(original != ResolvedGradientVector(changed))
        changed = source
        changed.stops.append(stop(rgba(0, 0, 1), 0.75))
        let pair = ResolvedGradientVector(changed)
        #expect(pair != original)
        changed.stops.reverse()
        #expect(pair != ResolvedGradientVector(changed))
    }
}

// MARK: - Fixtures

private func rgba(_ red: Float, _ green: Float, _ blue: Float, _ opacity: Float = 1) -> Color.Resolved {
    Color.Resolved(linearRed: red, linearGreen: green, linearBlue: blue, opacity: opacity)
}

private func stop(
    _ color: Color.Resolved,
    _ location: CGFloat,
    _ interpolation: ResolvedGradient.Interpolation? = nil
) -> ResolvedGradient.Stop {
    ResolvedGradient.Stop(color: color, location: location, interpolation: interpolation)
}

private var curveA: ResolvedGradient.Interpolation {
    .init(p1: (0.25, 0.5), p2: (0.75, 1))
}

private var curveB: ResolvedGradient.Interpolation {
    .init(p1: (0.5, 0.25), p2: (1, 0.75))
}

private struct GradientSchemeColor: ColorProvider {
    func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        environment.colorScheme == .light ? rgba(1, 0, 0) : rgba(0, 0, 1)
    }
}

@MainActor
private func resolvedVector(_ vector: ResolvedGradientVector) -> ResolvedGradient {
    Semantics.v5.test {
        var gradient = ResolvedGradient(stops: [], colorSpace: .linear)
        gradient.animatableData = vector
        return gradient
    }
}

private func expectColor(
    _ actual: Color.Resolved,
    _ expected: Color.Resolved,
    tolerance: Float = 0.000001,
    sourceLocation: SourceLocation = #_sourceLocation
) {
    #expect(abs(actual.linearRed - expected.linearRed) <= tolerance, sourceLocation: sourceLocation)
    #expect(abs(actual.linearGreen - expected.linearGreen) <= tolerance, sourceLocation: sourceLocation)
    #expect(abs(actual.linearBlue - expected.linearBlue) <= tolerance, sourceLocation: sourceLocation)
    #expect(abs(actual.opacity - expected.opacity) <= tolerance, sourceLocation: sourceLocation)
}
