//
//  ScaleEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 8AD2EA4DF9F96B2E7AB78754CF15EB14 (SwiftUICore)

public import OpenCoreGraphicsShims

private let leastNonzeroScaleFactor = (2 * CGFloat.leastNormalMagnitude).squareRoot()

// MARK: - ScaleEffect

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _ScaleEffect: GeometryEffect, Equatable {

    public var scale: CGSize

    public var anchor: UnitPoint

    @inlinable
    public init(scale: CGSize, anchor: UnitPoint = .center) {
        self.scale = scale
        self.anchor = anchor
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        var effectScale = scale
        if size.width == 0 {
            effectScale.width = leastNonzeroScaleFactor
        }
        if size.height == 0 {
            effectScale.height = leastNonzeroScaleFactor
        }
        let position = anchor.in(size)
        let negatePosition = -anchor.in(size)
        let transform = CGAffineTransform(translationX: negatePosition.x, y: negatePosition.y)
            .concatenating(.init(scaleX: effectScale.width, y: effectScale.height))
            .concatenating(.init(translationX: position.x, y: position.y))
        return ProjectionTransform(transform)
    }

    public typealias AnimatableData = AnimatablePair<CGSize.AnimatableData, UnitPoint.AnimatableData>

    public var animatableData: AnimatableData {
        get {
            .init(scale.animatableData, anchor.animatableData)
        }
        set {
            scale.animatableData = newValue.first
            anchor.animatableData = newValue.second
        }
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<_ScaleEffect>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeGeometryEffect(modifier: modifier, inputs: inputs, body: body)
    }
}

// MARK: - View + scaleEffect

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Scales this view's rendered output by the given vertical and horizontal
    /// size amounts, relative to an anchor point.
    ///
    /// Use `scaleEffect(_:anchor:)` to scale a view by applying a scaling
    /// transform of a specific size, specified by `scale`.
    ///
    ///     Image(systemName: "envelope.badge.fill")
    ///         .resizable()
    ///         .frame(width: 100, height: 100, alignment: .center)
    ///         .foregroundColor(Color.red)
    ///         .scaleEffect(CGSize(x: 0.9, y: 1.3), anchor: .leading)
    ///         .border(Color.gray)
    ///
    /// ![A screenshot showing a red envelope scaled to a size of 90x130
    /// pixels.](OpenSwiftUI-View-scaleEffect.png)
    ///
    /// - Parameters:
    ///   - scale: A [CGSize](https://developer.apple.com/documentation/coregraphics/cgsize) that
    ///     represents the horizontal and vertical amount to scale the view.
    ///   - anchor: The point with a default of ``UnitPoint/center`` that
    ///     defines the location within the view from which to apply the
    ///     transformation.
    @inlinable
    nonisolated public func scaleEffect(_ scale: CGSize, anchor: UnitPoint = .center) -> some View {
        return modifier(_ScaleEffect(scale: scale, anchor: anchor))
    }

    /// Scales this view's rendered output by the given amount in both the
    /// horizontal and vertical directions, relative to an anchor point.
    ///
    /// Use `scaleEffect(_:anchor:)` to apply a horizontally and vertically
    /// scaling transform to a view.
    ///
    ///     Image(systemName: "envelope.badge.fill")
    ///         .resizable()
    ///         .frame(width: 100, height: 100, alignment: .center)
    ///         .foregroundColor(Color.red)
    ///         .scaleEffect(2, anchor: .leading)
    ///         .border(Color.gray)
    ///
    /// ![A screenshot showing a 100x100 pixel red envelope scaled up to 2x the
    /// size of its view.](OpenSwiftUI-View-scaleEffect-cgfloat.png)
    ///
    /// - Parameters:
    ///   - s: The amount to scale the view in the view in both the horizontal
    ///     and vertical directions.
    ///   - anchor: The anchor point with a default of ``UnitPoint/center`` that
    ///     indicates the starting position for the scale operation.
    @inlinable
    nonisolated public func scaleEffect(_ s: CGFloat, anchor: UnitPoint = .center) -> some View {
        return scaleEffect(CGSize(width: s, height: s), anchor: anchor)
    }

    /// Scales this view's rendered output by the given horizontal and vertical
    /// amounts, relative to an anchor point.
    ///
    /// Use `scaleEffect(x:y:anchor:)` to apply a scaling transform to a view by
    /// a specific horizontal and vertical amount.
    ///
    ///     Image(systemName: "envelope.badge.fill")
    ///         .resizable()
    ///         .frame(width: 100, height: 100, alignment: .center)
    ///         .foregroundColor(Color.red)
    ///         .scaleEffect(x: 0.5, y: 0.5, anchor: .bottomTrailing)
    ///         .border(Color.gray)
    ///
    /// ![A screenshot showing a 100x100 pixel red envelope scaled down 50% in
    /// both the x and y axes.](OpenSwiftUI-View-scaleEffect-xy.png)
    ///
    /// - Parameters:
    ///   - x: An amount that represents the horizontal amount to scale the
    ///     view. The default value is `1.0`.
    ///   - y: An amount that represents the vertical amount to scale the view.
    ///     The default value is `1.0`.
    ///   - anchor: The anchor point that indicates the starting position for
    ///     the scale operation.
    @inlinable
    nonisolated public func scaleEffect(x: CGFloat = 1.0, y: CGFloat = 1.0, anchor: UnitPoint = .center) -> some View {
        return scaleEffect(CGSize(width: x, height: y), anchor: anchor)
    }
}

// MARK: - AnyTransition + ScaleTransition

@available(OpenSwiftUI_v1_0, *)
extension AnyTransition {

    /// Returns a transition that scales the view.
    public static var scale: AnyTransition {
        AnyTransition(ScaleTransition(1e-5))
    }

    /// Returns a transition that scales the view by the specified amount.
    public static func scale(scale: CGFloat, anchor: UnitPoint = .center) -> AnyTransition {
        AnyTransition(ScaleTransition(Double(scale), anchor: anchor))
    }
}

// MARK: - Transition + ScaleTransition

@available(OpenSwiftUI_v5_0, *)
extension Transition where Self == ScaleTransition {

    /// Returns a transition that scales the view.
    @_alwaysEmitIntoClient
    public static var scale: ScaleTransition {
        get { Self(1e-5) }
    }

    /// Returns a transition that scales the view by the specified amount.
    @_alwaysEmitIntoClient
    public static func scale(_ scale: Double, anchor: UnitPoint = .center) -> Self {
        Self(scale, anchor: anchor)
    }
}

// MARK: - ScaleTransition

/// Returns a transition that scales the view.
@available(OpenSwiftUI_v5_0, *)
public struct ScaleTransition: Transition {

    /// The amount to scale the view by.
    public var scale: Double

    /// The anchor point to scale the view around.
    public var anchor: UnitPoint

    /// Creates a transition that scales the view by the specified amount.
    public init(_ scale: Double, anchor: UnitPoint = .center) {
        self.scale = scale
        self.anchor = anchor
    }

    public func body(content: ScaleTransition.Content, phase: TransitionPhase) -> some View {
        content.scaleEffect(phase.isIdentity ? 1.0 : scale, anchor: anchor)
    }

    public func _makeContentTransition(transition: inout _Transition_ContentTransition) {
        guard case .effects = transition.operation else {
            transition.result = .bool(true)
            return
        }
        let effect = ContentTransition.Effect(.scale(scale))
        transition.result = .effects([effect])
    }
}

@available(*, unavailable)
extension ScaleTransition: Sendable {}

// MARK: _ ScaleEffect + ProtobufMessage

extension _ScaleEffect: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, scale, defaultValue: CGSize(width: 1, height: 1))
        try encoder.messageField(2, anchor, defaultValue: .center)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var effect = _ScaleEffect(scale: CGSize(width: 1, height: 1), anchor: .center)
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: effect.scale = try decoder.messageField(field)
            case 2: effect.anchor = try decoder.messageField(field)
            default: try decoder.skipField(field)
            }
        }
        self = effect
    }
}
