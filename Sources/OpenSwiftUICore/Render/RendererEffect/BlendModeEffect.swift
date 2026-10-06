//
//  BlendModeEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

// MARK: - _BlendModeEffect

@available(OpenSwiftUI_v1_0, *)
@frozen
@MainActor
@preconcurrency
public struct _BlendModeEffect: RendererEffect, Equatable {
    public var blendMode: BlendMode

    @inlinable
    nonisolated public init(blendMode: BlendMode) {
        self.blendMode = blendMode
    }

    package func effectValue(size: CGSize) -> DisplayList.Effect {
        .blendMode(GraphicsBlendMode(blendMode))
    }
}

@available(*, unavailable)
extension _BlendModeEffect: Sendable {}

// MARK: - _ExtendedBlendModeEffect

@_spi(Private)
@available(OpenSwiftUI_v3_0, *)
@frozen
@MainActor
@preconcurrency
public struct _ExtendedBlendModeEffect: RendererEffect, Equatable {
    public var blendMode: GraphicsContext.BlendMode

    @inlinable
    public init(blendMode: GraphicsContext.BlendMode) {
        self.blendMode = blendMode
    }

    package func effectValue(size: CGSize) -> DisplayList.Effect {
        .blendMode(.blendMode(blendMode))
    }
}

// MARK: - View + blendMode

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Sets the blend mode for compositing this view with overlapping views.
    ///
    /// Use `blendMode(_:)` to combine overlapping views and use a different
    /// visual effect to produce the result. The ``BlendMode`` enumeration
    /// defines many possible effects.
    ///
    /// In the example below, the two overlapping rectangles have a
    /// ``BlendMode/colorBurn`` effect applied, which effectively removes the
    /// non-overlapping portion of the second image:
    ///
    ///     HStack {
    ///         Color.yellow.frame(width: 50, height: 50, alignment: .center)
    ///
    ///         Color.red.frame(width: 50, height: 50, alignment: .center)
    ///             .rotationEffect(.degrees(45))
    ///             .padding(-20)
    ///             .blendMode(.colorBurn)
    ///     }
    ///
    /// ![Two overlapping rectangles showing the effect of the blend mode view
    /// modifier applying the colorBurn effect.](OpenSwiftUI-blendMode)
    ///
    /// - Parameter blendMode: The ``BlendMode`` for compositing this view.
    ///
    /// - Returns: A view that applies `blendMode` to this view.
    @inlinable
    nonisolated public func blendMode(_ blendMode: BlendMode) -> some View {
        modifier(_BlendModeEffect(blendMode: blendMode))
    }
}

// MARK: - View + extendedBlendMode

@_spi(Private)
@available(OpenSwiftUI_v3_0, *)
extension View {
    @inlinable
    nonisolated public func extendedBlendMode(_ blendMode: GraphicsContext.BlendMode) -> some View {
        modifier(_ExtendedBlendModeEffect(blendMode: blendMode))
    }
}

// MARK: - View + graphicsBlendMode

extension View {
    @MainActor
    @preconcurrency
    package func graphicsBlendMode(_ blendMode: GraphicsBlendMode) -> some View {
        modifier(GraphicsBlendModeEffect(blendMode: blendMode))
    }
}

// MARK: - GraphicsBlendModeEffect

@MainActor
@preconcurrency
struct GraphicsBlendModeEffect: RendererEffect {
    var blendMode: GraphicsBlendMode

    func effectValue(size: CGSize) -> DisplayList.Effect {
        .blendMode(blendMode)
    }
}
