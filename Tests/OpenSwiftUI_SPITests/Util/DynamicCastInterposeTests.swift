//
//  DynamicCastInterposeTests.swift
//  OpenSwiftUI_SPITests

#if canImport(Darwin) && OPENSWIFTUI_SWIFTUI_RENDERER
import Darwin
import OpenSwiftUI
import OpenSwiftUICore
import SwiftUI
import Testing

@_silgen_name("_OpenSwiftUI_LinkSwiftUIRendererInterposers")
private func linkSwiftUIRendererInterposers()

@Suite
struct DynamicCastInterposeTests {
    init() {
        linkSwiftUIRendererInterposers()
    }

    @Test(arguments: [false, true])
    func failedCastPreservesSourceLifetime(colorTarget: Bool) {
        let lifetime = Lifetime()
        do {
            let source = Payload(lifetime)
            if colorTarget {
                #expect(cast(source, to: SwiftUI.Color.Resolved.self) == nil)
            } else {
                #expect(cast(source, to: Int.self) == nil)
            }
            #expect(lifetime.releases == 0)
            withExtendedLifetime(source) {}
        }
        #expect(lifetime.releases == 1)
    }

    @Test
    func nativeColorCast() {
        let source = SwiftUI.Color.red.resolve(in: SwiftUI.EnvironmentValues())
        #expect(cast(source, to: SwiftUI.Color.Resolved.self) == source)
    }

    @Test(arguments: [false, true])
    func erasedColorFallback(unconditional: Bool) {
        let source: Any = OpenSwiftUI.Color.Resolved(
            linearRed: 0.25, linearGreen: 0.5, linearBlue: 0.75, opacity: 0.5
        )
        let result = unconditional
            ? forceCast(source, to: SwiftUI.Color.Resolved.self)
            : cast(source, to: SwiftUI.Color.Resolved.self)
        #expect(result?.opacity == 0.5)
    }

    @Test(arguments: GradientKind.allCases)
    func gradientFallback(kind: GradientKind) throws {
        let gradient = OpenSwiftUICore.ResolvedGradient(
            stops: [
                .init(
                    color: .init(linearRed: 0.25, linearGreen: 0.5, linearBlue: 0.75, opacity: 0.5),
                    location: 0.125,
                    interpolation: .init(p1: (0.25, 0.5), p2: (0.75, 1.0))
                ),
                .init(color: .init(linearRed: 1, linearGreen: 0, linearBlue: 0, opacity: 1), location: 0.875),
            ],
            colorSpace: .perceptual
        )
        let center = OpenSwiftUI.UnitPoint(x: 0.25, y: 0.75)
        switch kind {
        case .linear:
            try checkGradientFallback(OpenSwiftUI.LinearGradient._Paint(
                gradient: gradient, startPoint: center, endPoint: .init(x: 1, y: 0)
            ), kind: kind)
        case .radial:
            try checkGradientFallback(OpenSwiftUI.RadialGradient._Paint(
                gradient: gradient, center: center, startRadius: 4, endRadius: 32
            ), kind: kind)
        case .elliptical:
            try checkGradientFallback(OpenSwiftUI.EllipticalGradient._Paint(
                gradient: gradient, center: center, startRadiusFraction: 0.125, endRadiusFraction: 0.875
            ), kind: kind)
        case .angular:
            try checkGradientFallback(OpenSwiftUI.AngularGradient._Paint(
                gradient: gradient, center: center, startAngle: .radians(0.25), endAngle: .radians(1.5)
            ), kind: kind)
        }
    }

    @Test(arguments: GradientKind.allCases)
    func failedGradientCastPreservesSourceLifetime(kind: GradientKind) throws {
        let target = try kind.systemType()
        let lifetime = Lifetime()
        do {
            let source = Payload(lifetime)
            func check<T>(_: T.Type) {
                #expect(cast(source, to: T.self) == nil)
            }
            _openExistential(target, do: check)
            #expect(lifetime.releases == 0)
            withExtendedLifetime(source) {}
        }
        #expect(lifetime.releases == 1)
    }

    private func checkGradientFallback<P: Equatable>(_ source: P, kind: GradientKind) throws {
        func check<T>(_: T.Type) throws {
            try #require(MemoryLayout<T>.size == MemoryLayout<P>.size)
            try #require(MemoryLayout<T>.stride == MemoryLayout<P>.stride)
            try #require(MemoryLayout<T>.alignment == MemoryLayout<P>.alignment)

            let value = try #require(cast(source as Any, to: T.self))
            // Read the payload with the matching local layout; no cast hook runs here.
            #expect(unsafeBitCast(value, to: P.self) == source)
            let forced = forceCast(source as Any, to: T.self)
            #expect(unsafeBitCast(forced, to: P.self) == source)
            let native = try #require(cast(value as Any, to: T.self))
            #expect(unsafeBitCast(native, to: P.self) == source)
        }
        try _openExistential(kind.systemType(), do: check)

        for other in GradientKind.allCases where other != kind {
            func reject<T>(_: T.Type) {
                #expect(cast(source as Any, to: T.self) == nil)
            }
            _openExistential(try other.systemType(), do: reject)
        }
    }

    enum GradientKind: String, CaseIterable {
        case linear = "$s7SwiftUI14LinearGradientV6_PaintVN"
        case radial = "$s7SwiftUI14RadialGradientV6_PaintVN"
        case elliptical = "$s7SwiftUI18EllipticalGradientV6_PaintVN"
        case angular = "$s7SwiftUI15AngularGradientV6_PaintVN"

        func systemType() throws -> Any.Type {
            let image = try #require(dlopen(nil, RTLD_NOW))
            defer { dlclose(image) }
            let metadata = try #require(dlsym(image, rawValue))
            return unsafeBitCast(metadata, to: Any.Type.self)
        }
    }

    @inline(never)
    private func cast<T, U>(_ value: T, to: U.Type) -> U? {
        value as? U
    }

    @inline(never)
    private func forceCast<T, U>(_ value: T, to: U.Type) -> U {
        value as! U
    }

    private final class Lifetime {
        var releases = 0
    }

    private final class Payload {
        let lifetime: Lifetime

        init(_ lifetime: Lifetime) {
            self.lifetime = lifetime
        }

        deinit {
            lifetime.releases += 1
        }
    }
}
#endif
