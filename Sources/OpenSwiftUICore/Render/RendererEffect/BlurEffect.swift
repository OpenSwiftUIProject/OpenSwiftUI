//
//  BlurEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation

// MARK: - _BlurEffect

/// A blur effect applied to a view.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _BlurEffect: RendererEffect, Equatable {

    public var radius: CGFloat

    public var isOpaque: Bool

    @inlinable
    public init(radius: CGFloat, opaque: Bool) {
        self.radius = radius
        self.isOpaque = opaque
    }

    public var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }

    package var descriptionAttributes: [(name: String, value: String)] {
        var attributes: [(name: String, value: String)] = []
        attributes.append(("radius", radius.description))
        attributes.append(("isOpaque", isOpaque ? "true" : "false"))
        return attributes
    }

    package func effectValue(size: CGSize) -> DisplayList.Effect {
        .filter(.blur(BlurStyle(radius: radius, isOpaque: isOpaque)))
    }

    nonisolated public static func == (a: _BlurEffect, b: _BlurEffect) -> Swift.Bool {
        a.radius == b.radius && a.isOpaque == b.isOpaque
    }
}

// MARK: - View + blur

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Applies a Gaussian blur to this view.
    ///
    /// Use `blur(radius:opaque:)` to apply a gaussian blur effect to the
    /// rendering of this view.
    ///
    /// The example below shows two ``Text`` views, the first with no blur
    /// effects, the second with `blur(radius:opaque:)` applied with the
    /// `radius` set to `2`. The larger the radius, the more diffuse the
    /// effect.
    ///
    ///     struct Blur: View {
    ///         var body: some View {
    ///             VStack {
    ///                 Text("This is some text.")
    ///                     .padding()
    ///                 Text("This is some blurry text.")
    ///                     .blur(radius: 2.0)
    ///             }
    ///         }
    ///     }
    ///
    /// ![A screenshot showing the effect of applying gaussian blur effect to
    /// the rendering of a view.](OpenSwiftUI-View-blurRadius.png)
    ///
    /// - Parameters:
    ///   - radius: The radial size of the blur. A blur is more diffuse when its
    ///     radius is large.
    ///   - opaque: A Boolean value that indicates whether the blur renderer
    ///     permits transparency in the blur output. Set to `true` to create an
    ///     opaque blur, or set to `false` to permit transparency.
    @inlinable
    nonisolated public func blur(radius: CGFloat, opaque: Bool = false) -> some View {
        return modifier(_BlurEffect(radius: radius, opaque: opaque))
    }
}
