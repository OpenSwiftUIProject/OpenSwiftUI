//
//  TintTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing

struct TintTests {
    @Test
    func fallbackColorUsesExplicitTint() {
        var environment = EnvironmentValues()
        environment.tint = AnyShapeStyle(Color.red)

        var shape = _ShapeStyle_Shape(
            operation: .fallbackColor(level: 0),
            environment: environment
        )
        TintShapeStyle()._apply(to: &shape)

        guard case let .color(color) = shape.result else {
            Issue.record("Expected tint fallback color")
            return
        }
        #expect(color == .red)
    }

    @Test
    func fallbackColorUsesAccentWhenTintIsUnset() {
        var shape = _ShapeStyle_Shape(
            operation: .fallbackColor(level: 0),
            environment: .init()
        )
        TintShapeStyle()._apply(to: &shape)

        guard case let .color(color) = shape.result else {
            Issue.record("Expected accent fallback color")
            return
        }
        #expect(color == .accent)
    }

    @Test
    func shapeTypeAppliesAsHierarchicalStyle() {
        var type = _ShapeStyle_ShapeType(
            operation: .modifiesBackground,
            result: .none
        )
        TintShapeStyle._apply(to: &type)

        guard case let .bool(result) = type.result else {
            Issue.record("Expected shape type boolean result")
            return
        }
        #expect(result)
    }
}
