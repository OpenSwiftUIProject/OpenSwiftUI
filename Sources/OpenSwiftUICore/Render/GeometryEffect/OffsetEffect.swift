//
//  OffsetEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by appearanceAnimation
//  ID: 72FB21917F353796516DFC9915156779 (SwiftUICore)

public import OpenCoreGraphicsShims
import OpenAttributeGraphShims

// MARK: - _OffsetEffect

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
        let transform = CGAffineTransform(
            translationX: offset.width,
            y: offset.height
        )
        return ProjectionTransform(transform)
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

// MARK: - OffsetPosition

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

// MARK: - View + offset

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

    // TODO: appearanceAnimation
    @_spi(Private)
    @available(OpenSwiftUI_v2_0, *)
    nonisolated public func repeatingOffset(
        from: CGSize,
        to: CGSize,
        animation: Animation = Animation.default
    ) -> some View {
        _openSwiftUIUnimplementedFailure()
    }
}


// MARK: - AnyTransition + offset

@available(OpenSwiftUI_v1_0, *)
extension AnyTransition {

    public static func offset(_ offset: CGSize) -> AnyTransition {
        .init(OffsetTransition(offset))
    }

    public static func offset(x: CGFloat = 0, y: CGFloat = 0) -> AnyTransition {
        offset(CGSize(width: x, height: y))
    }
}

// MARK: - Transition + offset

@available(OpenSwiftUI_v5_0, *)
extension Transition where Self == OffsetTransition {

    /// Returns a transition that offset the view by the specified amount.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static func offset(_ offset: CGSize) -> Self {
        Self(offset)
    }

    /// Returns a transition that offset the view by the specified x and y
    /// values.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static func offset(x: CGFloat = 0, y: CGFloat = 0) -> Self {
        offset(CGSize(width: x, height: y))
    }
}

// MARK: - OffsetTransition

/// Returns a transition that offset the view by the specified amount.
@available(OpenSwiftUI_v5_0, *)
public struct OffsetTransition: Transition {
    /// The amount to offset the view by.
    public var offset: CGSize

    /// Creates a transition that offset the view by the specified amount.
    public init(_ offset: CGSize) {
        self.offset = offset
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.offset(phase.isIdentity ? .zero : offset)
    }

    public func _makeContentTransition(transition: inout _Transition_ContentTransition) {
        guard case .effects = transition.operation else {
            transition.result = .bool(true)
            return
        }
        let effect = ContentTransition.Effect(.translation(offset))
        transition.result = .effects([effect])
    }
}

@available(*, unavailable)
extension OffsetTransition: Sendable {}

// MARK: - _OffsetEffect + ProtobufMessage

extension _OffsetEffect: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, offset, defaultValue: .zero)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var offset: CGSize = .zero
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: offset = try decoder.messageField(field)
            default: try decoder.skipField(field)
            }
        }
        self.init(offset: offset)
    }
}
