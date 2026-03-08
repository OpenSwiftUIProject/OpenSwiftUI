//
//  ImageInterpolation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: B65D626E77C8D6CB107EB45FECFC60F0 (SwiftUICore?)

// MARK: - Image.Interpolation

@available(OpenSwiftUI_v1_0, *)
extension Image {

    /// The level of quality for rendering an image that requires interpolation,
    /// such as a scaled image.
    ///
    /// The ``Image/interpolation(_:)`` modifier specifies the interpolation
    /// behavior when using the ``Image/resizable(capInsets:resizingMode:)``
    /// modifier on an ``Image``. Use this behavior to prioritize rendering
    /// performance or image quality.
    public enum Interpolation: Sendable {

        /// A value that indicates OpenSwiftUI doesn't interpolate image data.
        case none

        /// A value that indicates a low level of interpolation quality, which may
        /// speed up image rendering.
        case low

        /// A value that indicates a medium level of interpolation quality,
        /// between the low- and high-quality values.
        case medium

        /// A value that indicates a high level of interpolation quality, which
        /// may slow down image rendering.
        case high
    }
}

// MARK: - InterpolatedProvider & AntialiasedProvider

private struct InterpolatedProvider: ImageProvider {
    var base: Image

    var interpolation: Image.Interpolation

    func resolve(in context: ImageResolutionContext) -> Image.Resolved {
        var resolved = base.resolve(in: context)
        resolved.image.interpolation = interpolation
        return resolved
    }

    func resolveNamedImage(in context: ImageResolutionContext) -> Image.NamedResolved? {
        base.resolveNamedImage(in: context)
    }
}

private struct AntialiasedProvider: ImageProvider {
    var base: Image

    var isAntialiased: Bool

    func resolve(in context: ImageResolutionContext) -> Image.Resolved {
        var resolved = base.resolve(in: context)
        resolved.image.isAntialiased = isAntialiased
        return resolved
    }

    func resolveNamedImage(in context: ImageResolutionContext) -> Image.NamedResolved? {
        base.resolveNamedImage(in: context)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Image {

    /// Specifies the current level of quality for rendering an
    /// image that requires interpolation.
    ///
    /// See the article <doc:Fitting-Images-into-Available-Space> for examples
    /// of using `interpolation(_:)` when scaling an ``Image``.
    /// - Parameter interpolation: The quality level, expressed as a value of
    /// the `Interpolation` type, that OpenSwiftUI applies when interpolating
    /// an image.
    /// - Returns: An image with the given interpolation value set.
    public func interpolation(_ interpolation: Image.Interpolation) -> Image {
        Image(
            InterpolatedProvider(
                base: self,
                interpolation: interpolation
            )
        )
    }

    /// Specifies whether OpenSwiftUI applies antialiasing when rendering
    /// the image.
    /// - Parameter isAntialiased: A Boolean value that specifies whether to
    /// allow antialiasing. Pass `true` to allow antialising, `false` otherwise.
    /// - Returns: An image with the antialiasing behavior set.
    public func antialiased(_ isAntialiased: Bool) -> Image {
        Image(
            AntialiasedProvider(
                base: self,
                isAntialiased: isAntialiased
            )
        )
    }
}

// MARK: - Image.Interpolation + ProtobufEnum

extension Image.Interpolation: ProtobufEnum {
    package var protobufValue: UInt {
        switch self {
        case .none: 0
        case .low: 1
        case .medium: 2
        case .high: 3
        }
    }

    package init?(protobufValue value: UInt) {
        switch value {
        case 0: self = .none
        case 1: self = .low
        case 2: self = .medium
        case 3: self = .high
        default: return nil
        }
    }
}
