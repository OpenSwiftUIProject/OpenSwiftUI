//
//  OffsetEffect.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: 72FB21917F353796516DFC9915156779 (SwiftUICore)

public import OpenCoreGraphicsShims
import OpenAttributeGraphShims

/// Allows you to redefine origin of the child within its coordinate
/// space
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _OffsetEffect: GeometryEffect, Equatable {
    public var offset: CGSize

    @inlinable
    nonisolated public init(offset: CGSize) {
        self.offset = offset
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: offset.width,
                y: offset.height
            )
        )
    }

    public var animatableData: CGSize.AnimatableData {
        get { offset.animatableData }
        set { offset.animatableData = newValue }
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<_OffsetEffect>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var inputs = inputs
        inputs.position = Attribute(
            OffsetPosition(
                effect: modifier.value,
                position: inputs.position,
                layoutDirection: inputs.layoutDirection
            )
        )
        return body(_Graph(), inputs)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Offset this view by the horizontal and vertical amount specified in the
    /// offset parameter.
    ///
    /// Use `offset(_:)` to shift the displayed contents by the amount
    /// specified in the `offset` parameter.
    ///
    /// The original dimensions of the view aren't changed by offsetting the
    /// contents; in the example below the gray border drawn by this view
    /// surrounds the original position of the text:
    ///
    ///     Text("Offset by passing CGSize()")
    ///         .border(Color.green)
    ///         .offset(CGSize(width: 20, height: 25))
    ///         .border(Color.gray)
    ///
    /// ![A screenshot showing a view that offset from its original position a
    /// CGPoint to specify the x and y offset.](OpenSwiftUI-View-offset.png)
    ///
    /// - Parameter offset: The distance to offset this view.
    ///
    /// - Returns: A view that offsets this view by `offset`.
    @inlinable
    nonisolated public func offset(_ offset: CGSize) -> some View {
        modifier(_OffsetEffect(offset: offset))
    }

    /// Offset this view by the specified horizontal and vertical distances.
    ///
    /// Use `offset(x:y:)` to shift the displayed contents by the amount
    /// specified in the `x` and `y` parameters.
    ///
    /// The original dimensions of the view aren't changed by offsetting the
    /// contents; in the example below the gray border drawn by this view
    /// surrounds the original position of the text:
    ///
    ///     Text("Offset by passing horizontal & vertical distance")
    ///         .border(Color.green)
    ///         .offset(x: 20, y: 50)
    ///         .border(Color.gray)
    ///
    /// ![A screenshot showing a view that offset from its original position
    /// using and x and y offset.](openswiftui-offset-xy.png)
    ///
    /// - Parameters:
    ///   - x: The horizontal distance to offset this view.
    ///   - y: The vertical distance to offset this view.
    ///
    /// - Returns: A view that offsets this view by `x` and `y`.
    @inlinable
    nonisolated public func offset(x: CGFloat = 0, y: CGFloat = 0) -> some View {
        offset(CGSize(width: x, height: y))
    }
}

private struct OffsetPosition: Rule, AsyncAttribute {
    @Attribute var effect: _OffsetEffect
    @Attribute var position: CGPoint
    @Attribute var layoutDirection: LayoutDirection

    var value: CGPoint {
        position.resolved(in: layoutDirection) + effect.offset
    }
}

extension CGPoint {
    @inline(__always)
    fileprivate func resolved(in layoutDirection: LayoutDirection) -> CGPoint {
        switch layoutDirection {
        case .leftToRight: CGPoint(x: x, y: y)
        case .rightToLeft: CGPoint(x: -x, y: y)
        }
    }
}
