//
//  NSImageConversions.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
public import AppKit
public import OpenSwiftUICore
import OpenRenderBoxShims

// MARK: - Image + NSImage

@available(OpenSwiftUI_v1_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension Image {

    /// Creates a OpenSwiftUI image from an AppKit image instance.
    /// - Parameter nsImage: The AppKit image to wrap with a OpenSwiftUI ``Image``.
    /// instance.
    public init(nsImage: NSImage) {
        self.init(nsImage)
    }
}

// MARK: - NSImage + ImageProvider

extension NSImage: ImageProvider {

    package func resolve(in context: ImageResolutionContext) -> Image.Resolved {
        let displayScale = context.environment.displayScale
        let layer = VectorImageLayer(nsImage: self, scale: displayScale)
        let isTemplate = context.environment.imageIsTemplate(renderingMode: isTemplate ? .template : nil)
        var graphicsImage = GraphicsImage(
            contents: .vectorLayer(layer),
            scale: displayScale,
            unrotatedPixelSize: size * displayScale,
            orientation: .up,
            isTemplate: isTemplate,
            resizingInfo: nil
        )
        graphicsImage.allowedDynamicRange = context.effectiveAllowedDynamicRange(for: graphicsImage)
        if context.environment.shouldRedactContent {
            graphicsImage.redact(in: context.environment)
        }
        let label = AccessibilityImageLabel(resolvedAccessibilityDescription)
        return Image.Resolved(
            image: graphicsImage,
            decorative: false,
            label: label,
            basePlatformItemImage: self
        )
    }

    package var resolvedAccessibilityDescription: String? {
        guard let description = accessibilityDescription, !description.isEmpty else {
            return _defaultAccessibilityDescription
        }
        return description
    }

    package func resolveNamedImage(in context: ImageResolutionContext) -> Image.NamedResolved? {
        nil
    }
}
#endif
