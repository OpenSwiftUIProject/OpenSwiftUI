//
//  OpacityEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(Private)
public import OpenSwiftUICore

// MARK: - View + repeatingOpacity

@available(OpenSwiftUI_v2_0, *)
extension View {
    @_spi(Private)
    nonisolated public func repeatingOpacity(
        from: Double,
        to: Double,
        animation: Animation = Animation.default
    ) -> some View {
        appearanceAnimation(animation: animation.repeatForever()) { view, isActive in
            view.opacity(isActive ? to : from)
        }
    }
}

// MARK: - VisualEffect + opacity

@available(OpenSwiftUI_v5_0, *)
extension VisualEffect {
    /// Sets the transparency of the view.
    ///
    /// When applying the `opacity(_:)` effect to a view that has already had
    /// its opacity transformed, the effect of the underlying opacity
    /// transformation is multiplied.
    ///
    /// - Parameter opacity: A value between 0 (fully transparent) and 1 (fully
    ///   opaque).
    ///
    /// - Returns: An effect that sets the transparency of the view.
    public func opacity(_ opacity: Double) -> some VisualEffect {
        rendererEffect(_OpacityEffect(opacity: opacity))
    }
}

// MARK: - HoverEffectContent + opacity

@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension HoverEffectContent {
    /// Sets the transparency of the view.
    ///
    /// When applying the `opacity(_:)` effect to a view that has already had
    /// its opacity transformed, the effect of the underlying opacity
    /// transformation is multiplied.
    ///
    /// - Parameter opacity: A value between 0 (fully transparent) and 1 (fully
    ///   opaque).
    ///
    /// - Returns: An effect that sets the transparency of the view.
    public func opacity(_ opacity: Double) -> some HoverEffectContent {
        rendererEffect(_OpacityEffect(opacity: opacity))
    }
}

// MARK: - ShapeStyle + opacity

@available(OpenSwiftUI_v3_0, *)
extension ShapeStyle {
    /// Returns a new style based on `self` that multiplies by the
    /// specified opacity when drawing.
    @inlinable
    public func opacity(_ opacity: Double) -> some ShapeStyle {
        _OpacityShapeStyle(style: self, opacity: Float(opacity))
    }

    @_spi(Private)
    @inlinable
    public func opacities(_ array: [Double]) -> some ShapeStyle {
        _OpacitiesShapeStyle(style: self, opacities: array)
    }

    @_spi(Private)
    @inlinable
    public func opacities(_ array: Double...) -> some ShapeStyle {
        _OpacitiesShapeStyle(style: self, opacities: array)
    }
}
