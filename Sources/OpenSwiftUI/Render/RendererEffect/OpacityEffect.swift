//
//  OpacityEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - ShapeStyle + opacity

@available(OpenSwiftUI_v3_0, *)
extension ShapeStyle {
    /// Returns a new style based on `self` that multiplies by the
    /// specified opacity when drawing.
    @inlinable
    public func opacity(_ opacity: Double) -> some ShapeStyle {
        _OpacityShapeStyle(style: self, opacity: Float(opacity))
    }
}
