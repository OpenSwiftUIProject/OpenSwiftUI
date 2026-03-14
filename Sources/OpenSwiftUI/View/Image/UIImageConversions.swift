//
//  UIImageConversions.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 47E85C485E11398B3F3140DCB9554BB7 (SwiftUI)

#if canImport(UIKit)
public import UIKit
public import OpenSwiftUICore

// MARK: - Image + UIImage

@available(OpenSwiftUI_v1_0, *)
@available(macOS, unavailable)
extension Image {

    /// Creates a OpenSwiftUI image from a UIKit image instance.
    /// - Parameter uiImage: The UIKit image to wrap with a OpenSwiftUI ``Image``
    /// instance.
    public init(uiImage: UIImage) {
        self.init(uiImage)
    }
}

// MARK: - UIImage + ImageProvider

extension UIImage: ImageProvider {

    package func resolve(in context: ImageResolutionContext) -> Image.Resolved {
        let resolvedImage: UIImage
        if !isSymbolImage, _hasImageAsset, let imageAsset {
            let overridden = traitCollection.resolvedImageAssetOnlyTraitCollection(environment: context.environment)
            resolvedImage = imageAsset.image(with: overridden)
        } else {
            resolvedImage = self
        }
        return resolvedImage._resolve(in: context)
    }

    package func resolveNamedImage(in context: ImageResolutionContext) -> Image.NamedResolved? {
        nil
    }

    // MARK: - Private

    private func _resolve(in context: ImageResolutionContext) -> Image.Resolved {
        let orientation = Image.Orientation(imageOrientation)
        let contents: GraphicsImage.Contents?
        if let cgImage {
            contents = .cgImage(cgImage)
        } else if let ioSurface {
            contents = .ioSurface(ioSurface)
        } else {
            contents = nil
        }

        let scale = scale
        var imageSize = size
        var layoutMetrics: Image.LayoutMetrics?
        if isSymbolImage {
            let insets = contentInsets
            let baselineOffset = baselineOffsetFromBottom ?? 0.0
            let capHeight = imageSize.height - (insets.top + baselineOffset)
            layoutMetrics = Image.LayoutMetrics(
                baselineOffset: baselineOffset,
                capHeight: capHeight,
                contentSize: imageSize,
                alignmentOrigin: CGPoint(x: insets.leading, y: insets.top)
            )
            imageSize.width -= insets.leading + insets.trailing
            imageSize.height -= insets.top + insets.bottom
        }
        let unrotatedSize = imageSize.unapply(orientation)
        let isTemplate = context.environment.imageIsTemplate(renderingMode: .init(renderingMode))
        var graphicsImage = GraphicsImage(
            contents: contents,
            scale: scale,
            unrotatedPixelSize: unrotatedSize * scale,
            orientation: orientation,
            isTemplate: isTemplate,
            resizingInfo: resizingInfo
        )
        graphicsImage.allowedDynamicRange = context.effectiveAllowedDynamicRange(for: graphicsImage)
        if context.environment.shouldRedactContent {
            graphicsImage.redact(in: context.environment)
        }
        let label = AccessibilityImageLabel(accessibilityLabel)
        var resolved = Image.Resolved(
            image: graphicsImage,
            decorative: false,
            label: label,
            basePlatformItemImage: self
        )
        if let layoutMetrics {
            resolved.layoutMetrics = layoutMetrics
        }
        return resolved
    }

    private var resizingInfo: Image.ResizingInfo? {
        guard capInsets != .zero else { return nil }
        let mode: Image.ResizingMode = (resizingMode == .tile) ? .tile : .stretch
        let edgeInsets = EdgeInsets(
            top: capInsets.top, leading: capInsets.left,
            bottom: capInsets.bottom, trailing: capInsets.right
        )
        return Image.ResizingInfo(capInsets: edgeInsets, mode: mode)
    }
}

// MARK: - GraphicsImage + UIImage

extension GraphicsImage {
    private func image(with name: String, variableValue: Float?, at location: Image.Location) -> UIImage? {
        if let variableValue {
            switch location {
            case .bundle(let bundle):
                return UIImage(named: name, in: bundle, variableValue: Double(variableValue), configuration: nil)
            case .system:
                return UIImage(systemName: name, variableValue: Double(variableValue), configuration: nil)
            case .privateSystem:
                return UIImage(_systemName: name, variableValue: Double(variableValue), configuration: nil)
            }
        } else {
            switch location {
            case .bundle(let bundle):
                return UIImage(named: name, in: bundle)
            case .system:
                return UIImage(systemName: name)
            case .privateSystem:
                return UIImage(_systemName: name)
            @unknown default:
                _openSwiftUIUnimplementedFailure()
            }
        }
    }
}

// MARK: - Image.TemplateRenderingMode + UIImage.RenderingMode

extension Image.TemplateRenderingMode {
    @inline(__always)
    fileprivate init?(_ renderingMode: UIImage.RenderingMode) {
        switch renderingMode {
        case .alwaysOriginal: self = .original
        case .alwaysTemplate: self = .template
        default: return nil
        }
    }
}

// MARK: - Image.Orientation + UIImage.Orientation

extension Image.Orientation {
    @inline(__always)
    fileprivate init(_ uiImageOrientation: UIImage.Orientation) {
        switch uiImageOrientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
#endif
