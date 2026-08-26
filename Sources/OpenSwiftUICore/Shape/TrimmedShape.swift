//
//  TrimmedShape.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenCoreGraphicsShims

// MARK: - _TrimmedShape

/// An absolute shape that has been trimmed to a fractional section.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _TrimmedShape<S>: Shape where S: Shape {
    /// The source shape.
    public var shape: S

    /// The start point of the trimmed shape, as a fraction between
    /// zero and one.
    public var startFraction: CGFloat

    /// The end point of the trimmed shape, as a fraction between zero
    /// and one.
    public var endFraction: CGFloat

    @inlinable
    public init(
        shape: S,
        startFraction: CGFloat = 0,
        endFraction: CGFloat = 1
    ) {
        self.shape = shape
        self.startFraction = startFraction
        self.endFraction = endFraction
    }

    nonisolated public func path(in rect: CGRect) -> Path {
        shape.path(in: rect).trimmedPath(
            from: startFraction,
            to: endFraction
        )
    }

    @available(OpenSwiftUI_v3_0, *)
    nonisolated public static var role: ShapeRole {
        S.role
    }

    @available(OpenSwiftUI_v5_0, *)
    nonisolated public var layoutDirectionBehavior: LayoutDirectionBehavior {
        shape.layoutDirectionBehavior
    }

    public typealias AnimatableData = AnimatablePair<
        S.AnimatableData,
        AnimatablePair<CGFloat, CGFloat>
    >

    public var animatableData: AnimatableData {
        get {
            AnimatablePair(
                shape.animatableData,
                AnimatablePair(startFraction, endFraction)
            )
        }
        set {
            shape.animatableData = newValue.first
            startFraction = newValue.second.first
            endFraction = newValue.second.second
        }
    }

    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        shape.sizeThatFits(proposal)
    }
}

// MARK: - Shape + Trim

@available(OpenSwiftUI_v1_0, *)
extension Shape {
    /// Trims this shape by a fractional amount based on its representation as a
    /// path.
    ///
    /// To create a `Shape` instance, you define the shape's path using lines and
    /// curves. Use the `trim(from:to:)` method to draw a portion of a shape by
    /// ignoring portions of the beginning and ending of the shape's path.
    ///
    /// For example, if you're drawing a figure eight or infinity symbol (∞)
    /// starting from its center, setting the `startFraction` and `endFraction`
    /// to different values determines the parts of the overall shape.
    ///
    /// The following example shows a simplified infinity symbol that draws
    /// only three quarters of the full shape. That is, of the two lobes of the
    /// symbol, one lobe is complete and the other is half complete.
    ///
    ///     Path { path in
    ///         path.addLines([
    ///             .init(x: 2, y: 1),
    ///             .init(x: 1, y: 0),
    ///             .init(x: 0, y: 1),
    ///             .init(x: 1, y: 2),
    ///             .init(x: 3, y: 0),
    ///             .init(x: 4, y: 1),
    ///             .init(x: 3, y: 2),
    ///             .init(x: 2, y: 1)
    ///         ])
    ///     }
    ///     .trim(from: 0.25, to: 1.0)
    ///     .scale(50, anchor: .topLeading)
    ///     .stroke(Color.black, lineWidth: 3)
    ///
    /// Changing the parameters of `trim(from:to:)` to
    /// `.trim(from: 0, to: 1)` draws the full infinity symbol, while
    /// `.trim(from: 0, to: 0.5)` draws only the left lobe of the symbol.
    ///
    /// - Parameters:
    ///   - startFraction: The fraction of the way through drawing this shape
    ///     where drawing starts.
    ///   - endFraction: The fraction of the way through drawing this shape
    ///     where drawing ends.
    /// - Returns: A shape built by capturing a portion of this shape's path.
    @inlinable
    nonisolated public func trim(
        from startFraction: CGFloat = 0,
        to endFraction: CGFloat = 1
    ) -> some Shape {
        _TrimmedShape(
            shape: self,
            startFraction: startFraction,
            endFraction: endFraction
        )
    }
}
