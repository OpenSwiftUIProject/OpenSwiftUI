//
//  StrokedShape.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenCoreGraphicsShims

// MARK: - _StrokedShape

/// An absolute shape that has been stroked.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _StrokedShape<S>: Shape where S: Shape {
    /// The source shape.
    public var shape: S

    /// The stroke style.
    public var style: StrokeStyle

    @inlinable
    public init(shape: S, style: StrokeStyle) {
        self.shape = shape
        self.style = style
    }

    nonisolated public func path(in rect: CGRect) -> Path {
        shape.path(in: rect).strokedPath(style)
    }

    @available(OpenSwiftUI_v3_0, *)
    nonisolated public static var role: ShapeRole {
        .stroke
    }

    @available(OpenSwiftUI_v5_0, *)
    nonisolated public var layoutDirectionBehavior: LayoutDirectionBehavior {
        shape.layoutDirectionBehavior
    }

    public var animatableData: AnimatablePair<S.AnimatableData, StrokeStyle.AnimatableData> {
        get {
            AnimatablePair(shape.animatableData, style.animatableData)
        }
        set {
            shape.animatableData = newValue.first
            style.animatableData = newValue.second
        }
    }

    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        shape.sizeThatFits(proposal)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Shape {
    /// Returns a new shape that is a stroked copy of `self`, using the
    /// contents of `style` to define the stroke characteristics.
    @inlinable
    nonisolated public func stroke(style: StrokeStyle) -> some Shape {
        return _StrokedShape(shape: self, style: style)
    }

    /// Returns a new shape that is a stroked copy of `self` with
    /// line-width defined by `lineWidth` and all other properties of
    /// `StrokeStyle` having their default values.
    @inlinable
    nonisolated public func stroke(lineWidth: CGFloat = 1) -> some Shape {
        return stroke(style: StrokeStyle(lineWidth: lineWidth))
    }
}
