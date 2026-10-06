//
//  CompositingGroupEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

// MARK: - _CompositingGroupEffect

/// A renderer effect that wraps a view in a compositing group, i.e.
/// any changes to opacity or the current blend mode in ancestor views
/// will be applied before rendering any content created by child
/// views.
@available(OpenSwiftUI_v1_0, *)
@frozen
@MainActor
@preconcurrency
public struct _CompositingGroupEffect: RendererEffect, Equatable {
    @inlinable
    nonisolated public init() {}

    package func effectValue(size: CGSize) -> DisplayList.Effect {
        .compositingGroup
    }
}

@available(*, unavailable)
extension _CompositingGroupEffect: Sendable {}

// MARK: - View + compositingGroup

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Wraps this view in a compositing group.
    ///
    /// A compositing group makes compositing effects in this view's ancestor
    /// views, such as opacity and the blend mode, take effect before this view
    /// is rendered.
    ///
    /// Use `compositingGroup()` to apply effects to a parent view before
    /// applying effects to this view.
    ///
    /// In the example below the `compositingGroup()` modifier separates the
    /// application of effects into stages. It applies the ``View/opacity(_:)``
    /// effect to the VStack before the `blur(radius:)` effect is applied to the
    /// views inside the enclosed ``ZStack``. This limits the scope of the
    /// opacity change to the outermost view.
    ///
    ///     VStack {
    ///         ZStack {
    ///             Text("CompositingGroup")
    ///                 .foregroundColor(.black)
    ///                 .padding(20)
    ///                 .background(Color.red)
    ///             Text("CompositingGroup")
    ///                 .blur(radius: 2)
    ///         }
    ///         .font(.largeTitle)
    ///         .compositingGroup()
    ///         .opacity(0.9)
    ///     }
    ///
    /// ![A view showing the effect of the compositingGroup modifier in applying
    /// compositing effects to parent views before child views are
    /// rendered.](OpenSwiftUI-View-compositingGroup)
    ///
    /// - Returns: A view that wraps this view in a compositing group.
    @inlinable
    nonisolated public func compositingGroup() -> some View {
        modifier(_CompositingGroupEffect())
    }
}
