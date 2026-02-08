//
//  ImplicitShapeStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

/// A shape style representing the implicit base of style modifiers.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _ImplicitShapeStyle: ShapeStyle, PrimitiveShapeStyle {
    @inlinable
    init() {}
    
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        guard case let .copyStyle(name) = shape.operation else {
            ForegroundStyle()._apply(to: &shape)
            return
        }
        let style = switch name {
            case .background: shape.environment.effectiveBackgroundStyle
            default: shape.effectiveForegroundStyle
        }
        shape.result = .style(style)
    }
}
