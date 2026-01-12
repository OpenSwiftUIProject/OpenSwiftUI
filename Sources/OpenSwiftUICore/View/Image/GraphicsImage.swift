//
//  GraphicsImage.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Empty
//  ID: B4F00EDEBAA4ECDCB2CAB650A00E4160 (SwiftUICore)

package import OpenCoreGraphicsShims
#if canImport(CoreGraphics)
import CoreGraphics_Private
#endif

// MARK: - GraphicsImage [WIP]

package struct GraphicsImage: Equatable, Sendable {
    package enum Contents: Equatable, @unchecked Sendable {
        case cgImage(CGImage)
        case ioSurface(IOSurfaceRef)
        indirect case vectorGlyph(ResolvedVectorGlyph)
        indirect case vectorLayer(VectorImageLayer)
        indirect case color(Color.Resolved)
        indirect case named(NamedImage.Key)
    }

    package var contents: GraphicsImage.Contents?

    package var scale: CGFloat

    package var unrotatedPixelSize: CGSize

    package var orientation: Image.Orientation

    package var maskColor: Color.Resolved?

    package var resizingInfo: Image.ResizingInfo?

    package var isAntialiased: Bool

    package var interpolation: Image.Interpolation

    package var allowedDynamicRange: Image.DynamicRange?

    package var isTemplate: Bool {
        maskColor != nil
    }

    package var size: CGSize {
        guard scale != .zero else { return .zero }
        return unrotatedPixelSize.apply(orientation) * (1.0 / scale)
    }

    package var pixelSize: CGSize {
        unrotatedPixelSize.apply(orientation)
    }

    package init(
        contents: GraphicsImage.Contents?,
        scale: CGFloat,
        unrotatedPixelSize: CGSize,
        orientation: Image.Orientation,
        isTemplate: Bool,
        resizingInfo: Image.ResizingInfo? = nil,
        antialiased: Bool = true,
        interpolation: Image.Interpolation = .low
    ) {
        self.contents = contents
        self.scale = scale
        self.unrotatedPixelSize = unrotatedPixelSize
        self.orientation = orientation
        self.maskColor = isTemplate ? .white : nil
        self.resizingInfo = resizingInfo
        self.isAntialiased = antialiased
        self.interpolation = interpolation
        self.allowedDynamicRange = nil
    }

    package func slicesAndTiles(at extent: CGSize? = nil) -> Image.ResizingInfo? {
        _openSwiftUIUnimplementedFailure()
    }

    package var styleResolverMode: ShapeStyle.ResolverMode {
        switch contents {
        case .cgImage:
            return .init()
        case let .vectorGlyph(resolvedVectorGlyph):
            return .init(
                rbSymbolStyleMask: resolvedVectorGlyph.animator.styleMask,
                location: resolvedVectorGlyph.location
            )
        default:
            return .init(foregroundLevels: isTemplate ? 1 : 0)
        }
    }

    package var headroom: Image.Headroom {
        #if canImport(CoreGraphics)
        guard case let .cgImage(image) = contents,
                let colorSpace = image.colorSpace,
                CGColorSpaceUsesITUR_2100TF(colorSpace)
        else {
            return .standard
        }
        var headroom: Float = .zero
        guard CGImageGetHeadroom(image, &headroom) || headroom > 0 else {
            if CGColorSpaceIsHLGBased(colorSpace) {
                return .highHLG
            } else {
                return .high
            }
        }
        return .init(rawValue: CGFloat(headroom))
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }
}

extension GraphicsImage: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        _openSwiftUIUnimplementedFailure()
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
}

extension GraphicsImage.Contents {
    package static func == (lhs: GraphicsImage.Contents, rhs: GraphicsImage.Contents) -> Bool {
        switch (lhs, rhs) {
        case let (.cgImage(a), .cgImage(b)): a === b
        case let (.ioSurface(a), .ioSurface(b)): a === b
        case let (.vectorGlyph(a), .vectorGlyph(b)): a == b
        case let (.vectorLayer(a), .vectorLayer(b)): a == b
        case let (.color(a), .color(b)): a == b
        /* OpenSwiftUI Addition Begin */
        // named is omitted on SwiftUI's implementation
        case let (.named(a), .named(b)): a == b
        /* OpenSwiftUI Addition End */
        default: false
        }
    }
}

// TODO: ResolvedVectorGlyph

package struct ResolvedVectorGlyph: Equatable {
    package let animator: ORBSymbolAnimator
    package let layoutDirection: LayoutDirection
    package let location: Image.Location
    package var animatorVersion: UInt32
    package var allowsContentTransitions: Bool
    package var preservesVectorRepresentation: Bool
}

extension GraphicsImage {
    package var bitmapOrientation: Image.Orientation {
        _openSwiftUIUnimplementedFailure()
    }

    package func render(at targetSize: CGSize, prefersMask: Bool = false) -> CGImage? {
        _openSwiftUIUnimplementedFailure()
    }
}

// FIXME

package class ORBSymbolAnimator: Hashable {
    var styleMask: UInt32 {
        .zero
    }

    package func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    package static func == (lhs: ORBSymbolAnimator, rhs: ORBSymbolAnimator) -> Bool {
        lhs === rhs
    }
}
