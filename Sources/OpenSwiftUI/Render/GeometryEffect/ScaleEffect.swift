//
//  ScaleEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenCoreGraphicsShims
public import OpenSwiftUICore

// MARK: - View + repeatingScaleEffect

@available(OpenSwiftUI_v2_0, *)
extension View {
    @_spi(Private)
    nonisolated public func repeatingScaleEffect(
        from: CGFloat,
        to: CGFloat,
        anchor: UnitPoint = .center,
        animation: Animation = Animation.default
    ) -> some View {
        repeatingScaleEffect(
            from: CGSize(width: from, height: from),
            to: CGSize(width: to, height: to),
            anchor: anchor,
            animation: animation
        )
    }

    @_spi(Private)
    nonisolated public func repeatingScaleEffect(
        from: CGSize,
        to: CGSize,
        anchor: UnitPoint = .center,
        animation: Animation = Animation.default
    ) -> some View {
        appearanceAnimation(animation: animation.repeatForever()) { view, isActive in
            view.scaleEffect(isActive ? to : from, anchor: anchor)
        }
    }
}

// MARK: - VisualEffect + scaleEffect

@available(OpenSwiftUI_v5_0, *)
extension VisualEffect {
    /// Scales the view's rendered output by the given vertical and horizontal
    /// size amounts, relative to an anchor point.
    ///
    /// - Parameters:
    ///   - scale: A [CGSize](https://developer.apple.com/documentation/corefoundation/cgsize) that
    ///     represents the horizontal and vertical amount to scale the view.
    ///   - anchor: The point with a default of ``UnitPoint/center`` that
    ///     defines the location within the view from which to apply the
    ///     transformation.
    ///
    /// - Returns: An effect that scales the view's rendered output.
    public func scaleEffect(_ scale: CGSize, anchor: UnitPoint = .center) -> some VisualEffect {
        scaleEffect(x: scale.width, y: scale.height, anchor: anchor)
    }

    /// Scales the view's rendered output by the given amount in both the
    /// horizontal and vertical directions, relative to an anchor point.
    ///
    /// - Parameters:
    ///   - scale: The amount to scale the view in the view in both the horizontal
    ///     and vertical directions.
    ///   - anchor: The point with a default of ``UnitPoint/center`` that
    ///     defines the location within the view from which to apply the
    ///     transformation.
    ///
    /// - Returns: An effect that scales the view's rendered output.
    public func scaleEffect(_ scale: CGFloat, anchor: UnitPoint = .center) -> some VisualEffect {
        geometryEffect(_ScaleEffect(scale: CGSize(width: scale, height: scale), anchor: anchor))
    }

    /// Scales the view's rendered output by the given horizontal and vertical
    /// amounts, relative to an anchor point.
    ///
    /// - Parameters:
    ///   - x: An amount that represents the horizontal amount to scale the
    ///     view. The default value is `1.0`.
    ///   - y: An amount that represents the vertical amount to scale the view.
    ///     The default value is `1.0`.
    ///   - anchor: The point with a default of ``UnitPoint/center`` that
    ///     defines the location within the view from which to apply the
    ///     transformation.
    ///
    /// - Returns: An effect that scales the view's rendered output.
    public func scaleEffect(x: CGFloat = 1.0, y: CGFloat = 1.0, anchor: UnitPoint = .center) -> some VisualEffect {
        geometryEffect(_ScaleEffect(scale: CGSize(width: x, height: y), anchor: anchor))
    }
}

@_spi(_)
@available(OpenSwiftUI_v5_0, *)
@available(*, deprecated, message: "Use scaleEffect instead")
extension VisualEffect {
    public func scale(_ scale: CGSize, anchor: UnitPoint = .center) -> some VisualEffect {
        scaleEffect(x: scale.width, y: scale.height, anchor: anchor)
    }

    public func scale(_ scale: CGFloat, anchor: UnitPoint = .center) -> some VisualEffect {
        scaleEffect(scale, anchor: anchor)
    }

    public func scale(x: CGFloat = 1.0, y: CGFloat = 1.0, anchor: UnitPoint = .center) -> some VisualEffect {
        scaleEffect(x: x, y: y, anchor: anchor)
    }
}

// MARK: - HoverEffectContent + scaleEffect

@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension HoverEffectContent {
    /// Scales the view's rendered output by the given vertical and horizontal
    /// size amounts, relative to an anchor point.
    ///
    /// - Parameters:
    ///   - scale: A [CGSize](https://developer.apple.com/documentation/corefoundation/cgsize) that
    ///     represents the horizontal and vertical amount to scale the view.
    ///   - anchor: The point with a default of ``UnitPoint/center`` that
    ///     defines the location within the view from which to apply the
    ///     transformation.
    ///
    /// - Returns: An effect that scales the view's rendered output.
    public func scaleEffect(_ scale: CGSize, anchor: UnitPoint = .center) -> some HoverEffectContent {
        scaleEffect(x: scale.width, y: scale.height, anchor: anchor)
    }

    /// Scales the view's rendered output by the given amount in both the
    /// horizontal and vertical directions, relative to an anchor point.
    ///
    /// - Parameters:
    ///   - scale: The amount to scale the view in the view in both the horizontal
    ///     and vertical directions.
    ///   - anchor: The point with a default of ``UnitPoint/center`` that
    ///     defines the location within the view from which to apply the
    ///     transformation.
    ///
    /// - Returns: An effect that scales the view's rendered output.
    public func scaleEffect(_ scale: CGFloat, anchor: UnitPoint = .center) -> some HoverEffectContent {
        geometryEffect(_ScaleEffect(scale: CGSize(width: scale, height: scale), anchor: anchor))
    }

    /// Scales the view's rendered output by the given horizontal and vertical
    /// amounts, relative to an anchor point.
    ///
    /// - Parameters:
    ///   - x: An amount that represents the horizontal amount to scale the
    ///     view. The default value is `1.0`.
    ///   - y: An amount that represents the vertical amount to scale the view.
    ///     The default value is `1.0`.
    ///   - anchor: The point with a default of ``UnitPoint/center`` that
    ///     defines the location within the view from which to apply the
    ///     transformation.
    ///
    /// - Returns: An effect that scales the view's rendered output.
    public func scaleEffect(x: CGFloat = 1.0, y: CGFloat = 1.0, anchor: UnitPoint = .center) -> some HoverEffectContent {
        geometryEffect(_ScaleEffect(scale: CGSize(width: x, height: y), anchor: anchor))
    }
}
