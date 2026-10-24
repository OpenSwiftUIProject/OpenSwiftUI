//
//  LinkShapeStyleTests.swift
//  OpenSwiftUITests

@testable import OpenSwiftUI
import OpenSwiftUITestsSupport
import Testing

@Suite(.tags(.aigc))
struct LinkShapeStyleTests {
    #if os(macOS) && OPENSWIFTUI_LINK_COREUI
    @Test(arguments: [ColorScheme.light, .dark])
    func resolvesCatalogFallbackColor(_ colorScheme: ColorScheme) throws {
        var environment = EnvironmentValues()
        environment.colorScheme = colorScheme
        var shape = _ShapeStyle_Shape(operation: .fallbackColor(level: 0), environment: environment)
        LinkShapeStyle()._apply(to: &shape)
        guard case let .color(color) = shape.result else {
            Issue.record("Expected a link fallback color")
            return
        }
        let resolved = color.resolve(in: environment)
        #expect(resolved.opacity == 1)
        #expect(resolved.linearBlue > resolved.linearRed)
        #expect(resolved.linearBlue > resolved.linearGreen)
    }
    #endif
}
