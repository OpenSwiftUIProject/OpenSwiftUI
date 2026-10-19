//
//  HierarchicalShapeStyleTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing

struct HierarchicalShapeStyleTests {
    @Test
    func secondaryColorUsesBaseColor() {
        var environment = EnvironmentValues()
        environment.setTestSystemColorDefinition()
        var shape = _ShapeStyle_Shape(
            operation: .fallbackColor(level: 0),
            environment: environment
        )

        Color.red.secondary._apply(to: &shape)

        guard case let .color(color) = shape.result else {
            Issue.record("Expected secondary fallback color")
            return
        }
        #expect(color == .red.opacity(0.75))
    }

    @Test
    func nestedStyleUsesPrimaryBaseColor() {
        var environment = EnvironmentValues()
        environment.setTestSystemColorDefinition()
        var shape = _ShapeStyle_Shape(
            operation: .fallbackColor(level: 0),
            environment: environment
        )

        Color.red.tertiary.secondary._apply(to: &shape)

        guard case let .color(color) = shape.result else {
            Issue.record("Expected secondary fallback color")
            return
        }
        #expect(color == .red.opacity(0.75))
    }
}
