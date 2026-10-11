//
//  BlurEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore
public import OpenCoreGraphicsShims

// MARK: - VisualEffect + blur

@available(OpenSwiftUI_v5_0, *)
extension VisualEffect {
    /// Applies a Gaussian blur to the view.
    ///
    /// Use `blur(radius:opaque:)` to apply a gaussian blur effect to the
    /// rendering of the view.
    ///
    /// - Parameters:
    ///   - radius: The radial size of the blur. A blur is more diffuse when its
    ///     radius is large.
    ///   - opaque: A Boolean value that indicates whether the blur renderer
    ///     permits transparency in the blur output. Set to `true` to create an
    ///     opaque blur, or set to `false` to permit transparency.
    ///
    /// - Returns: An effect that blurs the view.
    public func blur(radius: CGFloat, opaque: Bool = false) -> some VisualEffect {
        rendererEffect(_BlurEffect(radius: radius, opaque: opaque))
    }
}
