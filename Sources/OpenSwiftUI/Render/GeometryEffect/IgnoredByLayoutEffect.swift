//
//  IgnoredByLayoutEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

/// A geometry effect type that prevents another geometry effect
/// affecting coordinate space conversions during layout, i.e. the
/// transform introduced by the other effect is only used when
/// rendering, not when converting locations from one view to another.
/// This is often used to disable layout changes during transitions.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _IgnoredByLayoutEffect<Base>: GeometryEffect where Base: GeometryEffect {
    public var base: Base

    public static var _affectsLayout: Bool { false }

    @inlinable
    public init(_ base: Base) {
        self.base = base
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        base.effectValue(size: size)
    }

    public var animatableData: Base.AnimatableData {
        get { base.animatableData }
        set { base.animatableData = newValue }
    }
}

@available(*, unavailable)
extension _IgnoredByLayoutEffect: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension _IgnoredByLayoutEffect: Equatable where Base: Equatable {}

@available(OpenSwiftUI_v1_0, *)
extension GeometryEffect {
    /// Returns an effect that produces the same geometry transform as this
    /// effect, but only applies the transform while rendering its view.
    ///
    /// Use this method to disable layout changes during transitions. The view
    /// ignores the transform returned by this method while the view is
    /// performing its layout calculations.
    @inlinable
    public func ignoredByLayout() -> _IgnoredByLayoutEffect<Self> {
        return _IgnoredByLayoutEffect(self)
    }
}
