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

    package var styleResolverMode: _ShapeStyle_ResolverMode {
        _openSwiftUIUnimplementedFailure()
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

    package static func == (a: GraphicsImage, b: GraphicsImage) -> Bool {
        _openSwiftUIUnimplementedFailure()
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
        _openSwiftUIUnimplementedFailure()
    }
}

// TODO: ResolvedVectorGlyph

package struct ResolvedVectorGlyph {}

extension GraphicsImage {
    package var bitmapOrientation: Image.Orientation {
        _openSwiftUIUnimplementedFailure()
    }

    package func render(at targetSize: CGSize, prefersMask: Bool = false) -> CGImage? {
        _openSwiftUIUnimplementedFailure()
    }
}
