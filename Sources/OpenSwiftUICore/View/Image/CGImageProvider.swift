//
//  CGImageProvider.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: BB7900A03A030BC988C08113497314C3 (SwiftUICore?)

public import OpenCoreGraphicsShims

@available(OpenSwiftUI_v1_0, *)
extension Image {

    /// Creates a labeled image based on a Core Graphics image instance, usable
    /// as content for controls.
    ///
    /// - Parameters:
    ///   - cgImage: The base graphical image.
    ///   - scale: The scale factor for the image,
    ///     with a value like `1.0`, `2.0`, or `3.0`.
    ///   - orientation: The orientation of the image. The default is
    ///     ``Image/Orientation/up``.
    ///   - label: The label associated with the image. OpenSwiftUI uses the label
    ///     for accessibility.
    public init(
        _ cgImage: CGImage,
        scale: CGFloat,
        orientation: Image.Orientation = .up,
        label: Text
    ) {
        self.init(
            CGImageProvider(
                image: cgImage,
                scale: scale,
                orientation: orientation,
                label: label,
                decorative: false
            )
        )
    }

    /// Creates an unlabeled, decorative image based on a Core Graphics image
    /// instance.
    ///
    /// OpenSwiftUI ignores this image for accessibility purposes.
    ///
    /// - Parameters:
    ///   - cgImage: The base graphical image.
    ///   - scale: The scale factor for the image,
    ///     with a value like `1.0`, `2.0`, or `3.0`.
    ///   - orientation: The orientation of the image. The default is
    ///     ``Image/Orientation/up``.
    public init(
        decorative cgImage: CGImage,
        scale: CGFloat,
        orientation: Image.Orientation = .up
    ) {
        self.init(
            CGImageProvider(
                image: cgImage,
                scale: scale,
                orientation: orientation,
                label: nil,
                decorative: true
            )
        )
    }
}

private struct CGImageProvider: ImageProvider {
    var image: CGImage
    var scale: CGFloat
    var orientation: Image.Orientation
    var label: Text?
    var decorative: Bool

    func resolve(in context: ImageResolutionContext) -> Image.Resolved {
        var graphicsImage = GraphicsImage(
            contents: .cgImage(image),
            scale: scale,
            unrotatedPixelSize: image.size,
            orientation: orientation,
            isTemplate: context.environment.imageIsTemplate()
        )
        graphicsImage.allowedDynamicRange = context.effectiveAllowedDynamicRange(for: graphicsImage)
        if context.environment.shouldRedactContent {
            let color = Color.foreground.resolve(in: context.environment)
            graphicsImage.contents = .color(color.multiplyingOpacity(by: 0.16))
        }
        return Image.Resolved(
            image: graphicsImage,
            decorative: decorative,
            label: AccessibilityImageLabel(label)
        )
    }

    func resolveNamedImage(in context: ImageResolutionContext) -> Image.NamedResolved? {
        nil
    }
}

extension CGImage {
    package var size: CGSize {
        #if canImport(CoreGraphics)
        CGSize(width: CGFloat(width), height: CGFloat(height))
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }
}
