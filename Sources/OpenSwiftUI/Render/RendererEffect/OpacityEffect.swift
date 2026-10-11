//
//  OpacityEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Blocked by AppearanceAnimationView

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

@_spi(CustomHoverEffects)
@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension HoverEffectContent {
    public func _opacity(_ opacity: Double) -> some HoverEffectContent {
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

// MARK: - Placeholder types [WIP]

// TODO: Move these dependencies to OpenSwiftUICore when their rendering is implemented.

extension View {
    nonisolated fileprivate func appearanceAnimation<Modified>(
        animation: Animation = Animation.default,
        strategy: AppearanceAnimationStrategy = .withAnimation,
        modifier: (Self, Bool) -> Modified
    ) -> some View where Modified: View {
        AppearanceAnimationView(
            content: self,
            from: modifier(self, false),
            to: modifier(self, true),
            animation: animation,
            strategy: strategy
        )
    }
}

private enum AppearanceAnimationStrategy {
    case withAnimation
    case animationValue
}

private struct AppearanceAnimationView<Content, Modified> where Content: View, Modified: View {
    var content: Content
    var from: Modified
    var to: Modified
    var animation: Animation
    var strategy: AppearanceAnimationStrategy
}

extension AppearanceAnimationView: View {
    var body: some View {
        _openSwiftUIUnimplementedFailure()
    }
}

/// Visual Effects change the visual appearance of a view without changing its
/// ancestors or descendents.
///
/// Because effects do not impact layout, they are safe to use in situations
/// where layout modification is not allowed. For example, effects may be
/// applied as a function of position, accessed through a geometry proxy:
///
///     var body: some View {
///         ContentRow()
///             .visualEffect { content, geometryProxy in
///                 content.offset(x: geometryProxy.frame(in: .global).origin.y)
///             }
///     }
///
/// You don't conform to this protocol yourself. Instead, visual effects are
/// created by calling modifier functions (such as `.offset(x:y:)` on other
/// effects, as seen in the example above.
@available(OpenSwiftUI_v5_0, *)
public protocol VisualEffect {}

@available(OpenSwiftUI_v5_0, *)
extension VisualEffect {
    fileprivate func rendererEffect(_ effect: some RendererEffect & Sendable) -> some VisualEffect {
        CombinedVisualEffect(first: self, second: RendererVisualEffect(base: effect))
    }
}

@available(OpenSwiftUI_v5_0, *)
private struct CombinedVisualEffect<First, Second>: VisualEffect where First: VisualEffect, Second: VisualEffect {
    var first: First
    var second: Second
}

@available(OpenSwiftUI_v5_0, *)
private struct RendererVisualEffect<Effect>: VisualEffect where Effect: RendererEffect & Sendable {
    var base: Effect
}

/// A type that describes the effects of a view for a particular hover
/// effect phase.
///
///     Color.red
///         .hoverEffect { effect, isActive, proxy in
///             effect.opacity(isActive ? 1 : 0.5)
///         }
///
///
/// You don't conform to this protocol yourself. Instead, effects are described
/// by calling modifier functions on other effects, like the `opacity(_:)`
/// modifier used in the example above.
@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
public protocol HoverEffectContent {}

@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension HoverEffectContent {
    fileprivate func rendererEffect(_ effect: some RendererEffect) -> some HoverEffectContent {
        ModifiedContent(content: self, modifier: RendererHoverEffectContent(base: effect))
    }
}

@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension ModifiedContent: HoverEffectContent where Content: HoverEffectContent, Modifier: HoverEffectContent {}

@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
private struct RendererHoverEffectContent<Effect>: HoverEffectContent where Effect: RendererEffect {
    var base: Effect
}
