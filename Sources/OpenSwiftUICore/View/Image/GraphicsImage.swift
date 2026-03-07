//
//  GraphicsImage.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: B4F00EDEBAA4ECDCB2CAB650A00E4160 (SwiftUICore)

package import OpenCoreGraphicsShims
package import OpenRenderBoxShims
#if canImport(CoreGraphics)
import CoreGraphics_Private
#endif

#if OPENSWIFTUI_LINK_COREUI
package import CoreUI
#endif

// MARK: - GraphicsImage

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
        return pixelSize * (1.0 / scale)
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
        guard size != extent, let resizingInfo else {
            return nil
        }
        guard !resizingInfo.capInsets.isEmpty || resizingInfo.mode == .tile else {
            return nil
        }
        if case .color = contents {
            return nil
        }
        return resizingInfo
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

// MARK: - GraphicsImage + ProtobufMessage [WIP]

extension GraphicsImage: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        _openSwiftUIUnimplementedFailure()
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - GraphicsImage.Contents + Equatable

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

// MARK: - ResolvedVectorGlyph

package struct ResolvedVectorGlyph: Equatable {
    package let animator: ORBSymbolAnimator
    package let layoutDirection: LayoutDirection
    package let location: Image.Location
    package var animatorVersion: UInt32
    package var allowsContentTransitions: Bool
    package var preservesVectorRepresentation: Bool
    package let catalog: CUICatalog

    package init(
        glyph: CUINamedVectorGlyph,
        value: Float?,
        flipsRightToLeft: Bool,
        in context: ImageResolutionContext,
        at location: Image.Location,
        catalog: CUICatalog
    ) {
        let variableValue: CGFloat
        let animator: ORBSymbolAnimator
        let allowsContentTransitions: Bool
        if let existingAnimator = context.symbolAnimator {
            variableValue = value.map { CGFloat($0) } ?? .infinity
            animator = existingAnimator
            allowsContentTransitions = context.willUpdateVectorGlyph(
                to: glyph,
                variableValue: variableValue
            )
        } else {
            animator = ORBSymbolAnimator()
            animator.anchorPoint = .zero
            allowsContentTransitions = false
            variableValue = value.map { CGFloat($0) } ?? .infinity
        }
        animator.glyph = glyph
        animator.variableValue = variableValue
        animator.flipsRightToLeft = flipsRightToLeft
        animator.renderingMode = context.effectiveSymbolRenderingMode?.rbRenderingMode ?? 255
        let direction = context.environment.layoutDirection
        let version = animator.version
        let options = context.options
        self.animator = animator
        self.layoutDirection = direction
        self.location = location
        self.animatorVersion = version
        self.allowsContentTransitions = allowsContentTransitions
        self.preservesVectorRepresentation = options.contains(.preservesVectors)
        self.catalog = catalog
    }

    // MARK: - Computed properties

    package var flipsRightToLeft: Bool {
        animator.flipsRightToLeft
    }

    #if OPENSWIFTUI_LINK_COREUI
    package var glyph: CUINamedVectorGlyph? {
        animator.glyph
    }
    #endif

    package var value: Float? {
        let v = animator.variableValue
        guard v.isFinite else { return nil }
        return Float(v)
    }

    package var renderingMode: SymbolRenderingMode.Storage? {
        SymbolRenderingMode(rbRenderingMode: animator.renderingMode)?.storage
    }

    package var resolvedRenderingMode: SymbolRenderingMode.Storage? {
        #if OPENSWIFTUI_LINK_COREUI && OPENSWIFTUI_RENDERBOX
        let rbMode = animator.renderingMode
        guard rbMode == 0 else {
            return SymbolRenderingMode(rbRenderingMode: rbMode)?.storage
        }
        guard let glyph = animator.glyph else {
            return .preferred
        }
        switch glyph.preferredRenderingMode {
        case 2: return .multicolor
        case 3: return .hierarchical
        default: return nil
        }
        #else
        _openSwiftUIUnimplementedFailure()
        #endif
    }

    package var alignmentRect: CGRect {
        animator.alignmentRect
    }

    package var styleResolverMode: ShapeStyle.ResolverMode {
        .init(rbSymbolStyleMask: animator.styleMask, location: location)
    }

    // MARK: - Methods

    package func isClear(styles: ShapeStyle.Pack) -> Bool {
        guard animator.styleMask & 0x1200 == 0 else {
            return false
        }
        return styles.isClear(name: .foreground)
    }

    // MARK: - ResolvedVectorGlyph + Equatable

    package static func == (lhs: ResolvedVectorGlyph, rhs: ResolvedVectorGlyph) -> Bool {
        lhs.animator === rhs.animator
            && lhs.animatorVersion == rhs.animatorVersion
            && lhs.layoutDirection == rhs.layoutDirection
            && lhs.location == rhs.location
    }
}

// MARK: - GraphicsImage + Extension [WIP]

extension GraphicsImage {
    package var bitmapOrientation: Image.Orientation {
        guard case let .vectorGlyph(vectorGlyph) = contents else {
            return orientation
        }
        return vectorGlyph.flipsRightToLeft ? orientation.mirrored : orientation
    }

    package func render(at targetSize: CGSize, prefersMask: Bool = false) -> CGImage? {
        _openSwiftUIUnimplementedFailure()
    }
}
