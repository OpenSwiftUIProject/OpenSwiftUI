//
//  PlatformDrawable.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by GraphicsContext.Storage + RenderBox
//  ID: E2A63CF3FB15FAD08FBE4CE6D0C83E51 (SwiftUICore)

import OpenAttributeGraphShims
@_spiOnly public import OpenRenderBoxShims
public import OpenCoreGraphicsShims
public import OpenQuartzCoreShims
#if canImport(QuartzCore)
import QuartzCore_Private
#endif
import OpenSwiftUI_SPI

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
        case rbDisplayList(any ORBDisplayListContents, CGPoint)
        case rbInterpolator(ORBDisplayListInterpolator, Float, CGPoint)
        case empty
    }

    var storage: Storage = .empty

    // MARK: - PlatformDrawableContent.State

    public struct State {
        package var mode: DisplayList.GraphicsRenderer.PlatformViewMode = .unsupported

        package var _renderer: DisplayList.GraphicsRenderer?

        package init() {
            _openSwiftUIEmptyStub()
        }

        package init(platformViewMode: DisplayList.GraphicsRenderer.PlatformViewMode) {
            mode = platformViewMode
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
        switch storage {
        case .graphicsCallback(let callback):
            let environment = EnvironmentValues()
            GraphicsContext.renderingTo(
                cgContext: ctx,
                environment: environment,
                deviceScale: contentsScale
            ) { graphicsContext in
                callback(&graphicsContext, size)
            }
        case .platformCallback(let callback):
            #if canImport(Darwin)
            let cgContext = CoreGraphicsContext(cgContext: ctx)
            cgContext.push()
            callback(size)
            cgContext.pop()
            #else
            _openSwiftUIPlatformUnimplementedFailure()
            #endif
        case .displayList(let displayList, let offset, let time):
            let environment = EnvironmentValues()
            GraphicsContext.renderingTo(
                cgContext: ctx,
                environment: environment,
                deviceScale: contentsScale
            ) { graphicsContext in
                graphicsContext
                    .translateBy(x: -offset.x, y: -offset.y)
                state.renderer()
                    .renderDisplayList(displayList, at: time, in: &graphicsContext)
            }
        case .rbDisplayList(let contents, let offset):
            ctx.translateBy(x: -offset.x, y: -offset.y)
            // TODO: RBDisplayListKey
            // contents.render(in: ctx, options: [RBDisplayListRenderRasterizationScale: contentsScale])
        case .rbInterpolator(let interpolator, let fraction, let offset):
            let environment = EnvironmentValues()
            GraphicsContext.renderingTo(
                cgContext: ctx,
                environment: environment,
                deviceScale: contentsScale
            ) { graphicsContext in
                graphicsContext.translateBy(x: -offset.x, y: -offset.y)
                // TODO: GraphicsContext
                // interpolator.draw(inState: graphicsContext.drawingState, by: fraction)
            }
        case .empty:
            break
        }
    }
    #endif

    public func draw(
        in list: ORBDisplayList,
        size: CGSize,
        state: inout PlatformDrawableContent.State
    ) {
        switch storage {
        case .rbDisplayList(let contents, let offset):
            list.translateBy(x: -offset.x, y: -offset.y)
            list.draw(contents)
        case .rbInterpolator(let interpolator, let fraction, let offset):
            list.translateBy(x: -offset.x, y: -offset.y)
            // TODO: Blocked by RBDisplayListGetState (C function not exposed in OpenRenderBox)
            // interpolator.draw(inState: RBDisplayListGetState(list), by: fraction)
        default:
            _openSwiftUIUnimplementedFailure()
        }
    }
}

@_spi(DisplayList_ViewSystem)
@available(*, unavailable)
extension PlatformDrawableContent.State: Sendable {}

// MARK: - PlatformDrawableOptions

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
