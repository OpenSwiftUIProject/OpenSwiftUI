//
//  PlatformDrawable.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

import OpenAttributeGraphShims
@_spiOnly public import OpenRenderBoxShims
public import OpenCoreGraphicsShims
public import OpenQuartzCoreShims
#if canImport(QuartzCore)
import QuartzCore_Private
#endif

// MARK: - PlatformDrawable

@_spi(DisplayList_ViewSystem)
@available(OpenSwiftUI_v6_0, *)
public protocol PlatformDrawable: AnyObject {
    var options: PlatformDrawableOptions { get set }

    static var allowsContentsMultiplyColor: Bool { get }

    func update(content: PlatformDrawableContent?, required: Bool) -> Bool

    func makeAsyncUpdate(
        content: PlatformDrawableContent,
        required: Bool,
        layer: CALayer,
        bounds: CGRect
    ) -> (() -> Void)?

    func setContentsScale(_ scale: CGFloat)

    func drawForTesting(in: ORBDisplayList) -> ()
}

// MARK: - PlatformDrawableContent [WIP]

@_spi(DisplayList_ViewSystem)
@available(OpenSwiftUI_v6_0, *)
public struct PlatformDrawableContent: @unchecked Sendable {
    enum Storage {
        case graphicsCallback((inout GraphicsContext, CGSize) -> ())
        case platformCallback((CGSize) -> ())
        case displayList(DisplayList, CGPoint, Time)
        case rbDisplayList(any RBDisplayListContents, CGPoint)
        case rbInterpolator(RBDisplayListInterpolator, Float, CGPoint)
        case empty
    }

    private var storage: Storage = .empty

    public struct State {
        package var mode: DisplayList.GraphicsRenderer.PlatformViewMode

        package var _renderer: DisplayList.GraphicsRenderer?

        package init() {
            mode = .unsupported
            _renderer = nil
        }

        package init(platformViewMode: DisplayList.GraphicsRenderer.PlatformViewMode) {
            mode = platformViewMode
            _renderer = nil
        }

        package mutating func renderer() -> DisplayList.GraphicsRenderer {
            guard let _renderer else {
                let render = DisplayList.GraphicsRenderer(platformViewMode: mode)
                _renderer = render
                return render
            }
            return _renderer
        }
    }

    public init() {
        _openSwiftUIEmptyStub()
    }

    #if canImport(CoreGraphics)
    public func draw(
        in ctx: CGContext,
        size: CGSize,
        contentsScale: CGFloat,
        state: inout PlatformDrawableContent.State
    ) {
        _openSwiftUIUnimplementedFailure()
    }
    #endif

    public func draw(
        in list: ORBDisplayList,
        size: CGSize,
        state: inout PlatformDrawableContent.State
    ) {
        _openSwiftUIUnimplementedFailure()
    }
}

@_spi(DisplayList_ViewSystem)
@available(*, unavailable)
extension PlatformDrawableContent.State: Sendable {}

// MARK: - PlatformDrawableOptions [Blocked by RBLayer]

@_spi(DisplayList_ViewSystem)
@available(OpenSwiftUI_v6_0, *)
public struct PlatformDrawableOptions: Equatable, Sendable {
    var base: RasterizationOptions

    public var isAccelerated: Bool {
        base.isAccelerated
    }

    public var isOpaque: Bool {
        base.isOpaque
    }

    public var rendersAsynchronously: Bool {
        base.rendersAsynchronously
    }

    public var rendersFirstFrameAsynchronously: Bool {
        base.rendersFirstFrameAsynchronously
    }

    #if canImport(QuartzCore)
    public var caLayerContentsFormat: CALayerContentsFormat {
        var format = CALayerContentsFormat.automatic
        if base.flags.contains(.rgbaContext) {
            format = .RGBA8Uint
        }
        if base.flags.contains(.alphaOnly) {
            format = .A8
        }
        return format
    }
    #endif

    public func update(rbLayer: AnyObject) {
        #if canImport(Darwin)
        let layer = rbLayer as! ORBLayer
        layer.colorMode = base.resolvedColorMode
        layer.rendersAsynchronously = rendersAsynchronously
        layer.maxDrawableCount = Int(base.maxDrawableCount)
        layer.allowsDisplayCompositing = base.prefersDisplayCompositing
        layer.allowsPackedDrawable = base.allowsPackedDrawable
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        #endif
    }
}
