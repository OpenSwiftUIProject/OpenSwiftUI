//
//  DynamicCastInterposeTests.swift
//  OpenSwiftUI_SPITests

#if canImport(Darwin) && OPENSWIFTUI_SWIFTUI_RENDERER
import OpenSwiftUI
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
